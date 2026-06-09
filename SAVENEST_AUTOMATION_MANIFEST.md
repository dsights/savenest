# 🚀 SaveNest Automation Manifest

This document tracks all active automated systems and scripts that power the SaveNest business engine.

## 1. Organic Growth & Social Media
*   **`scripts/organic_strike_launcher.py`**: Automated "One-Button" posting across 100+ Facebook Groups, Instagram, LinkedIn, and Twitter.
*   **`marketing/social_strike_config.json`**: Central brain for social targets and viral content rotation.

## 2. Partnership & Vendor Acquisition
*   **`scripts/automate_vendor_outreach.py`**: Cold outreach strike to Tier-1 Solar installers with Pay-Per-Close proposals.
*   **`scripts/automate_jv_outreach.py`**: Pitching Real Estate agencies for referral partnerships.
*   **`scripts/automate_trades_jv_outreach.py`**: Pitching Trades/Roofers for "Spotter Fee" partnerships.

## 3. Data Integrity & Maintenance
*   **`scripts/update_prices.py`**: Scrapes and updates energy utility plan prices using CDR and EME APIs.
*   **`scripts/update_official_csv.py`**: (NEW) Curates "Hero Deals" and EOFY offers from official Telecom/NBN providers.
*   **`scripts/automate_telecom_discovery.py`**: (NEW) AI-assisted discovery tool for finding new providers and price drops.
*   **`scripts/sync_products.py`**: Synchronizes the master CSV database with the live website JSON.
*   **`scripts/validate_deployment.py`**: (NEW) Mandatory Quality Control gate ensuring no blank categories or short blog posts.
*   **`.github/workflows/update-prices.yml`**: GitHub Action that runs price updates automatically every Monday & Thursday.

## 4. CRM & Lead Management
*   **`scripts/hubspot_manager.py`**: Automated read/write bridge between SaveNest and HubSpot CRM.
*   **`scripts/handoff_lead.py`**: Professional branded email system for passing high-intent leads to vendors.
*   **`scripts/process_marketing_leads.py`**: (NEW) Parses raw client lists, updates HubSpot, and sends educational engagement emails.

## 5. Website Backend & Intelligence
*   **`backend/main.py`**: FastAPI server handling CORS, HubSpot secret management, and OCR.
*   **`backend/ocr_service.py`**: AI-powered bill scanning that extracts usage data for the calculator.

## 6. Daily Operations
*   **`ceo_daily_sync.py`**: The "Single Command" dashboard for the Director to manage the entire business in 15 minutes.

---
**Status:** All systems are OPERATIONAL.
**Last Manifest Update:** 2026-06-09
