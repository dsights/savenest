import csv
import json
import os
import re
import datetime

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

    # Load existing products to apply safety checks
    old_products = {}
    if os.path.exists(JSON_PATH):
        try:
            with open(JSON_PATH, 'r', encoding='utf-8') as f:
                old_products = json.load(f)
        except Exception as e:
            print(f"Warning: Could not load existing {JSON_PATH}: {e}")

    new_products_data = {}
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
        
        # Get fieldnames to check for shifts
        fieldnames = reader.fieldnames or []

        for row in reader:
            if not row.get('category'): continue
            raw_category = row['category'].strip().lower()

            # Handle shifted columns for rows missing keyFeatures (common in solar/nbn)
            # A correct row has 14 columns. If DictReader sees fewer fields for this row
            # (which it might not if it uses fieldnames as keys, it just leaves missing ones as None)
            # Actually, DictReader will fill missing columns with None if restkey is None.
            # Let's check for the heuristic: if logoUrl looks like a color and providerColor looks like a URL
            logo = (row.get('logoUrl') or "").strip()
            color = (row.get('providerColor') or "").strip()
            if logo.startswith('#') and color.startswith('http'):
                # Shift fields: directUrl <- providerColor, providerColor <- logoUrl, logoUrl <- keyFeatures
                row['directUrl'] = row.get('providerColor')
                row['providerColor'] = row.get('logoUrl')
                row['logoUrl'] = row.get('keyFeatures')
                row['keyFeatures'] = "" # It was missing

            # Map Category to JSON keys
            category = raw_category
            if raw_category in ['5g broadband', 'nbn']:
                category = 'internet'
            elif raw_category == 'financial':
                category = 'financial'
            
            if category not in new_products_data:
                new_products_data[category] = []

            # Parse features (handle both pipe and comma if not piped)
            raw_features = row.get('keyFeatures') or ""
            if '|' in raw_features:
                features = [f.strip() for f in raw_features.split('|') if f.strip()]
            else:
                features = [f.strip() for f in raw_features.split(',') if f.strip()]

            # Also pull features from description if it contains pipes
            raw_desc = (row.get('description') or "").strip()
            if '|' in raw_desc:
                desc_parts = [p.strip() for p in raw_desc.split('|')]
                # If features were empty, move piped parts to features
                if not features:
                    features = desc_parts
                    raw_desc = desc_parts[0] # Take first part as desc
                else:
                    # Append if they look unique
                    for p in desc_parts:
                        if p not in features: features.append(p)

            # Parse States
            raw_states = (row.get('applicableStates') or "").strip().upper()
            if raw_states:
                states = [s.strip() for s in raw_states.split('|') if s.strip()]
            else:
                # Detect from ID prefix (e.g. nsw_agl_...)
                id_val = (row.get('id') or "").lower()
                if id_val.startswith('nsw_'): states = ['NSW']
                elif id_val.startswith('vic_'): states = ['VIC']
                elif id_val.startswith('qld_'): states = ['QLD']
                elif id_val.startswith('sa_'): states = ['SA']
                elif id_val.startswith('wa_'): states = ['WA']
                elif id_val.startswith('act_'): states = ['ACT']
                elif id_val.startswith('tas_'): states = ['TAS']
                elif id_val.startswith('nt_'): states = ['NT']
                else: states = [] # National

            # Build Deal Object
            color = (row.get('providerColor') or "").strip()
            # Validation: if color is a URL, something is still wrong, default to navy
            if color.startswith('http'):
                color = "0xFF002A54"
            elif color and not color.startswith('0x'):
                if color.startswith('#'):
                    color = color.replace('#', '0xFF')
                else:
                    color = '0xFF' + color

            def safe_bool(val):
                if val is None: return False
                v = str(val).strip().upper()
                return v == 'TRUE' or v == '1' or v == 'YES'

            price = safe_float(row.get('price'))
            
            # Quote-based categories should be enabled even if price is 0.0
            quote_based_categories = ['solar', 'insurance', 'financial', 'security']
            is_enabled = price > 0.0 or category in quote_based_categories

            deal = {
                "id": (row.get('id') or "").strip(),
                "providerName": (row.get('providerName') or "").strip(),
                "logoUrl": (row.get('logoUrl') or "").strip(),
                "providerColor": color or "0xFF002A54",
                "planName": (row.get('planName') or "").strip(),
                "description": raw_desc,
                "keyFeatures": features,
                "price": price,
                "priceUnit": (row.get('priceUnit') or "").strip(),
                # Auto-generate internal affiliate URL
                "affiliateUrl": f"https://savenest.au/provider/{get_provider_slug((row.get('providerName') or '').strip())}",
                "directUrl": (row.get('directUrl') or "").strip(),
                "rating": safe_float(row.get('rating')),
                "isSponsored": safe_bool(row.get('isSponsored')),
                "isGreen": safe_bool(row.get('isGreen')),
                "isEnabled": is_enabled,
                "applicableStates": states
            }
            
            new_products_data[category].append(deal)

    # Apply safety checks and build final products object
    products = {
        "metadata": {
            "version": "1.5",
            "lastUpdated": datetime.datetime.now().strftime("%Y-%m-%d"),
            "currency": "AUD",
            "market": "Australia"
        }
    }

    # Categories to check
    all_categories = set(list(new_products_data.keys()) + [k for k in old_products.keys() if k != 'metadata'])

    for cat in all_categories:
        new_list = new_products_data.get(cat, [])
        old_list = old_products.get(cat, [])
        
        # SAFETY CHECK LOGIC:
        # 1. If new list has >= 10 items, it's considered good.
        # 2. If new list has < 10 items but the old list was also < 10 (or empty), 
        #    we take the new list (allows growth from 0->5->7 etc).
        # 3. If new list has < 10 items but the old list had >= 10, we PROTECT 
        #    the old list and don't overwrite it with a truncated version.
        
        if len(new_list) >= 10:
            products[cat] = new_list
            updated_count += len(new_list)
            print(f"  ✓ {cat}: Updated with {len(new_list)} items from CSV.")
        elif len(old_list) < 10:
            products[cat] = new_list
            updated_count += len(new_list)
            print(f"  ℹ {cat}: Category {cat} has {len(new_list)} items (growth from {len(old_list)}).")
        else:
            products[cat] = old_list
            updated_count += len(old_list)
            print(f"  ⚠ {cat}: CSV only had {len(new_list)} items, but existing data had {len(old_list)}. Retaining old data to prevent blank pages.")

    with open(JSON_PATH, 'w', encoding='utf-8') as f:
        json.dump(products, f, indent=2)

    print(f"Successfully synced {updated_count} total deals across all categories to {JSON_PATH}")

if __name__ == "__main__":
    sync()
