#!/usr/bin/env python3
"""
SaveNest Price Update Pipeline
================================
Fetches current energy plan data from the Australian CDR (Consumer Data Right)
API and the Energy Made Easy comparison service, diffs against the curated
products.json, and updates prices + metadata in place.

Usage
-----
  python scripts/update_prices.py              # Live update
  python scripts/update_prices.py --dry-run    # Show what would change, write nothing
  python scripts/update_prices.py --report     # Print staleness report only

Environment variables
---------------------
  EME_API_KEY   (optional) API key for api.energymadeeasy.gov.au
"""

import argparse
import json
import os
import sys
import time
import difflib
from datetime import date, datetime
from typing import Optional

import requests

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
PRODUCTS_JSON = os.path.join(SCRIPT_DIR, "..", "assets", "data", "products.json")
LOG_DIR = os.path.join(SCRIPT_DIR, "..", "logs")
STALE_DAYS = 7          # Flag deals whose prices haven't been confirmed in this many days
REQUEST_TIMEOUT = 15    # seconds

EME_BASE = "https://api.energymadeeasy.gov.au"
EME_API_KEY = os.environ.get("EME_API_KEY", "")

# CDR (Consumer Data Right) retailer API base URIs.
# Each retailer exposes a standardised /cds-au/v1/energy/plans endpoint.
CDR_RETAILERS = {
    "AGL":             "https://cdr.agl.com.au",
    "Origin Energy":   "https://cdr.originenergy.com.au",
    "EnergyAustralia": "https://cdr.energyaustralia.com.au",
    "Red Energy":      "https://cdr.redenergy.com.au",
    "Alinta Energy":   "https://cdr.alintaenergy.com.au",
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def load_products() -> dict:
    with open(PRODUCTS_JSON, "r", encoding="utf-8") as f:
        return json.load(f)


def save_products(data: dict) -> None:
    data["metadata"]["lastUpdated"] = date.today().isoformat()
    data["metadata"]["lastPipelineRun"] = datetime.utcnow().isoformat() + "Z"
    with open(PRODUCTS_JSON, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"  ✓ products.json saved (lastUpdated = {data['metadata']['lastUpdated']})")


def fuzzy_match(name_a: str, name_b: str) -> float:
    """Return similarity ratio between two plan/provider name strings."""
    return difflib.SequenceMatcher(
        None,
        name_a.lower().strip(),
        name_b.lower().strip()
    ).ratio()


def get_json(url: str, headers: Optional[dict] = None, timeout: int = REQUEST_TIMEOUT) -> Optional[dict]:
    try:
        resp = requests.get(url, headers=headers or {}, timeout=timeout)
        resp.raise_for_status()
        return resp.json()
    except requests.RequestException as e:
        print(f"  ✗ GET {url} — {e}")
        return None

# ---------------------------------------------------------------------------
# CDR API fetcher (electricity / gas)
# ---------------------------------------------------------------------------

def fetch_cdr_plans(retailer_name: str, base_uri: str) -> list[dict]:
    """
    Calls the CDR /energy/plans endpoint for a retailer.
    Returns a flat list of plan dicts with keys: planId, displayName, estimatedAnnualCost.
    CDR v1 spec: https://consumerdatastandardsaustralia.github.io/standards
    """
    url = f"{base_uri}/cds-au/v1/energy/plans"
    headers = {"x-v": "2", "Accept": "application/json"}
    data = get_json(url, headers)
    if not data:
        return []

    plans = data.get("data", {}).get("plans", [])
    print(f"  → {retailer_name}: {len(plans)} CDR plans found")
    return plans


def extract_cdr_price(plan: dict) -> Optional[float]:
    """
    Pull an estimated monthly price from a CDR plan object.
    CDR plans use annualEstimatedCost or electricityContract.tariffPeriod.
    Returns monthly figure (AUD) or None if not determinable.
    """
    # Preferred: top-level annualEstimatedCost
    annual = plan.get("annualEstimatedCost")
    if annual:
        try:
            return round(float(annual) / 12, 2)
        except (TypeError, ValueError):
            pass

    # Fallback: electricityContract usage tariff (sum flat rates → estimate)
    contract = plan.get("electricityContract") or plan.get("gasContract") or {}
    for period in contract.get("tariffPeriod", []):
        rates = period.get("singleRate", {}).get("rates", [])
        if rates:
            try:
                # Rough: daily supply + 500 kWh/month at flat rate
                unit_rate = float(rates[0].get("unitPrice", 0))
                daily_supply = float(
                    contract.get("intrinsicGreenPower", {})
                    .get("greenPowerCharges", [{}])[0]
                    .get("dailyCharge", 0)
                ) or 1.2  # AUD/day fallback
                estimated = (unit_rate * 500 / 100) + (daily_supply * 30)
                return round(estimated, 2)
            except (TypeError, ValueError, IndexError):
                pass

    return None

# ---------------------------------------------------------------------------
# Energy Made Easy API fetcher (requires EME_API_KEY)
# ---------------------------------------------------------------------------

def fetch_eme_plans(state: str = "NSW", fuel_type: str = "electricity") -> list[dict]:
    """
    Calls the Energy Made Easy API for a given state and fuel type.
    Returns raw plan list or empty list if API key not set.
    EME docs: https://api.energymadeeasy.gov.au/swagger
    """
    if not EME_API_KEY:
        return []

    url = f"{EME_BASE}/api/v4/plans?fuelType={fuel_type}&state={state}&sortBy=price"
    headers = {"Authorization": f"Bearer {EME_API_KEY}", "Accept": "application/json"}
    data = get_json(url, headers)
    if not data:
        return []

    plans = data.get("plans", [])
    print(f"  → EME {state} {fuel_type}: {len(plans)} plans")
    return plans

# ---------------------------------------------------------------------------
# Core diff + update logic
# ---------------------------------------------------------------------------

def match_deal_to_cdr(deal: dict, cdr_plans: list[dict], retailer_name: str) -> Optional[dict]:
    """
    Find the best CDR plan match for a curated deal.
    Uses fuzzy matching on provider + plan name (threshold 0.6).
    """
    if deal.get("providerName", "").lower() != retailer_name.lower():
        return None

    best_score = 0.0
    best_plan = None
    deal_plan_name = deal.get("planName", "")

    for cdr_plan in cdr_plans:
        cdr_name = cdr_plan.get("displayName", "")
        score = fuzzy_match(deal_plan_name, cdr_name)
        if score > best_score and score >= 0.6:
            best_score = score
            best_plan = cdr_plan

    return best_plan


def update_category(
    products: dict,
    category_key: str,
    cdr_plans_by_retailer: dict[str, list],
    dry_run: bool,
) -> int:
    """
    Update prices for all deals in a category.
    Returns the number of deals whose price was updated.
    """
    updates = 0
    deals: list[dict] = products.get(category_key, [])

    for deal in deals:
        if not deal.get("isEnabled", True):
            continue

        retailer = deal.get("providerName", "")
        cdr_plans = cdr_plans_by_retailer.get(retailer, [])
        matched = match_deal_to_cdr(deal, cdr_plans, retailer)

        if not matched:
            continue

        new_price = extract_cdr_price(matched)
        if new_price is None or new_price <= 0:
            continue

        old_price = deal.get("price", 0)
        diff = abs(new_price - old_price)

        if diff < 0.50:  # ignore sub-50c changes (rounding noise)
            continue

        direction = "↑" if new_price > old_price else "↓"
        print(
            f"  {direction} {retailer} / {deal.get('planName')} : "
            f"${old_price:.2f} → ${new_price:.2f} (delta ${diff:.2f})"
        )

        if not dry_run:
            deal["price"] = new_price
            deal["priceVerifiedAt"] = date.today().isoformat()
        updates += 1

    return updates


def run_staleness_report(products: dict) -> None:
    """Print deals that haven't had their price verified recently."""
    today = date.today()
    print("\n── Staleness Report ─────────────────────────────────────────")
    stale_count = 0
    for key, deals in products.items():
        if key == "metadata" or not isinstance(deals, list):
            continue
        for deal in deals:
            if not deal.get("isEnabled", True):
                continue
            verified = deal.get("priceVerifiedAt", "")
            if not verified:
                age_label = "never verified"
                stale_count += 1
            else:
                try:
                    age_days = (today - date.fromisoformat(verified)).days
                    if age_days >= STALE_DAYS:
                        age_label = f"{age_days}d ago"
                        stale_count += 1
                    else:
                        continue
                except ValueError:
                    age_label = f"invalid date: {verified}"
                    stale_count += 1
            print(
                f"  ⚠  [{key}] {deal.get('providerName')} / "
                f"{deal.get('planName')} — {age_label}"
            )
    print(f"\n  Total stale deals: {stale_count}")
    print("─────────────────────────────────────────────────────────────\n")

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="SaveNest price update pipeline")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would change without writing anything")
    parser.add_argument("--report", action="store_true",
                        help="Print staleness report and exit")
    args = parser.parse_args()

    print(f"\n{'[DRY RUN] ' if args.dry_run else ''}SaveNest Price Updater — {date.today()}\n")

    products = load_products()
    meta = products.get("metadata", {})
    print(f"  products.json v{meta.get('version')} last updated {meta.get('lastUpdated')}")

    if args.report:
        run_staleness_report(products)
        return

    # ── Fetch CDR plans for all configured retailers ─────────────
    print("\n── Fetching CDR plans ───────────────────────────────────────")
    cdr_plans_by_retailer: dict[str, list] = {}
    for retailer, base_uri in CDR_RETAILERS.items():
        plans = fetch_cdr_plans(retailer, base_uri)
        if plans:
            cdr_plans_by_retailer[retailer] = plans
        time.sleep(0.5)  # be polite to the CDR endpoints

    # ── Update categories ─────────────────────────────────────────
    print("\n── Updating prices ──────────────────────────────────────────")
    total_updates = 0
    for category in ("electricity", "gas"):
        print(f"\n  [{category}]")
        n = update_category(products, category, cdr_plans_by_retailer, args.dry_run)
        total_updates += n
        if n == 0:
            print("  No price changes detected.")

    # ── Staleness report (always shown) ──────────────────────────
    run_staleness_report(products)

    # ── Write ─────────────────────────────────────────────────────
    print(f"\n── Summary ──────────────────────────────────────────────────")
    print(f"  Prices updated: {total_updates}")

    if args.dry_run:
        print("  DRY RUN — products.json was NOT modified.")
    elif total_updates > 0:
        os.makedirs(LOG_DIR, exist_ok=True)
        log_file = os.path.join(LOG_DIR, f"price_update_{date.today()}.log")
        with open(log_file, "w") as lf:
            lf.write(f"Run: {datetime.utcnow().isoformat()}Z\n")
            lf.write(f"Updates: {total_updates}\n")
        save_products(products)
        print(f"  Log written to {log_file}")
    else:
        print("  No changes — products.json not rewritten.")

    print()


if __name__ == "__main__":
    main()
