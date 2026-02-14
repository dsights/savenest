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

    def safe_float(val):
        if val is None: return 0.0
        try:
            # Remove currency symbols and commas before converting
            clean_val = str(val).replace('$', '').replace(',', '').strip()
            return float(clean_val)
        except:
            return 0.0

    with open(CSV_PATH, mode='r', encoding='utf-8') as f:
        # Read lines and handle the strange wrapping quotes
        content = f.read().splitlines()
        clean_lines = []
        for line in content:
            line = line.strip()
            if line.startswith('"') and line.endswith('"'):
                line = line[1:-1].replace('""', '"')
            clean_lines.append(line)
        
        import io
        reader = csv.DictReader(io.StringIO('\n'.join(clean_lines)))
        
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

            # Parse features (handle both pipe and comma if not piped)
            raw_features = row.get('keyFeatures') or ""
            if '|' in raw_features:
                features = [f.strip() for f in raw_features.split('|') if f.strip()]
            else:
                features = [f.strip() for f in raw_features.split(',') if f.strip()]

            # Build Deal Object
            color = (row.get('providerColor') or "").strip()
            if color and not color.startswith('0x'):
                if color.startswith('#'):
                    color = color.replace('#', '0xFF')
                else:
                    color = '0xFF' + color

            def safe_bool(val):
                if val is None: return False
                v = str(val).strip().upper()
                return v == 'TRUE' or v == '1' or v == 'YES'

            deal = {
                "id": (row.get('id') or "").strip(),
                "providerName": (row.get('providerName') or "").strip(),
                "logoUrl": (row.get('logoUrl') or "").strip(),
                "providerColor": color or "0xFF002A54",
                "planName": (row.get('planName') or "").strip(),
                "description": (row.get('description') or "").strip(),
                "keyFeatures": features,
                "price": safe_float(row.get('price')),
                "priceUnit": (row.get('priceUnit') or "").strip(),
                "affiliateUrl": f"https://savenest.au/provider/{get_provider_slug((row.get('providerName') or '').strip())}",
                "directUrl": (row.get('directUrl') or "").strip(),
                "rating": safe_float(row.get('rating')),
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
