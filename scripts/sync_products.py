import csv
import json
import os
import re

def slugify(text):
    text = text.lower()
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[\s_-]+', '-', text)
    return text.strip('-')

CSV_PATH = 'assets/data/products_master - Sheet3.csv'
JSON_PATH = 'assets/data/products.json'

# Special slug mapping for provider directory consistency
slug_overrides = {
    "agl energy": "agl",
    "dodo power": "dodo",
    "globird energy": "globird-energy",
    "everyday mobile (woolworths)": "everyday-mobile",
}

def get_provider_slug(name):
    low_name = name.lower()
    if low_name in slug_overrides:
        return slug_overrides[low_name]
    return slugify(name)

def sync():
    if not os.path.exists(CSV_PATH):
        print(f"Error: {CSV_PATH} not found.")
        return

    products = {
        "metadata": {
            "version": "1.5",
            "lastUpdated": "2026-02-14",
            "currency": "AUD",
            "market": "Australia"
        }
    }
    updated_count = 0

    with open(CSV_PATH, mode='r', encoding='utf-8') as f:
        # Read lines and strip leading/trailing quotes if they wrap the entire line
        lines = []
        for line in f:
            clean_line = line.strip()
            if clean_line.startswith('"') and clean_line.endswith('"'):
                # Check if it's a single quoted field that should be split
                # Or just strip outer quotes
                clean_line = clean_line[1:-1].replace('""', '"')
            lines.append(clean_line)
        
        reader = csv.DictReader(lines)
        for row in reader:
            if not row.get('category'): continue
            raw_category = row['category'].strip().lower()
            
            # Map Category to JSON keys
            category = raw_category
            if raw_category in ['5g broadband', 'nbn']:
                category = 'internet'
            elif raw_category == 'financial':
                category = 'financial'
            
            if category not in products:
                products[category] = []

            # Parse features
            features = [f.strip() for f in row['keyFeatures'].split(',') if f.strip()]
            if '|' in row['keyFeatures']:
                features = [f.strip() for f in row['keyFeatures'].split('|') if f.strip()]

            # Build Deal Object
            color = (row.get('providerColor') or "").strip()
            if color and not color.startswith('0x'):
                if color.startswith('#'):
                    color = color.replace('#', '0xFF')
                else:
                    color = '0xFF' + color

            def safe_bool(val):
                if val is None: return False
                return val.strip().upper() == 'TRUE'

            deal = {
                "id": (row.get('id') or "").strip(),
                "providerName": (row.get('providerName') or "").strip(),
                "logoUrl": (row.get('logoUrl') or "").strip(),
                "providerColor": color or "0xFF002A54",
                "planName": (row.get('planName') or "").strip(),
                "description": (row.get('description') or "").strip(),
                "keyFeatures": features,
                "price": float(row['price']) if row.get('price') else 0.0,
                "priceUnit": (row.get('priceUnit') or "").strip(),
                # Auto-generate internal affiliate URL
                "affiliateUrl": f"https://savenest.au/provider/{get_provider_slug((row.get('providerName') or '').strip())}",
                "directUrl": (row.get('directUrl') or "").strip(),
                "rating": float(row['rating']) if row.get('rating') else 0.0,
                "isSponsored": safe_bool(row.get('isSponsored')),
                "isGreen": safe_bool(row.get('isGreen'))
            }
            
            products[category].append(deal)
            updated_count += 1

    with open(JSON_PATH, 'w', encoding='utf-8') as f:
        json.dump(products, f, indent=2)

    print(f"Successfully synced {updated_count} deals from {CSV_PATH} to {JSON_PATH}")

if __name__ == "__main__":
    sync()
