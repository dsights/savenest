import json
import re

def parse_price(val):
    if not val: return 0.0
    val = str(val).strip().replace('$', '').replace(',', '')
    try:
        return float(val)
    except ValueError:
        match = re.search(r'(\d+\.?\d*)', val)
        return float(match.group(1)) if match else 0.0

def make_id(category, provider, plan_name):
    clean_prov = re.sub(r'[^a-z0-9]', '', provider.lower())
    clean_plan = re.sub(r'[^a-z0-9]', '', plan_name.lower())
    return f"{category}_{clean_prov}_{clean_plan}"

def get_color(provider):
    colors = {
        'SpinTel': '0xFF09B5F3',
        'AGL': '0xFFED0000',
        'EnergyAustralia': '0xFF00A651',
        'Origin': '0xFFF36A22',
        'Optus': '0xFFE72024',
        'Telstra': '0xFF007BC2',
        'Vodafone': '0xFFE60000',
        'Swoop': '0xFFFF0000',
        'Aussie Broadband': '0xFF00A651',
        'Bupa': '0xFF007BC2',
        'Medibank': '0xFFE72024',
        'Allianz': '0xFF007BC2',
    }
    for k, v in colors.items():
        if k.lower() in provider.lower():
            return v
    return '0xFF4200B3' # default

data = json.load(open('assets/data/product_data_manual/extracted_data.json'))

products = {
    "metadata": {
        "version": "2.0",
        "lastUpdated": "2026-04-12",
        "currency": "AUD",
        "market": "Australia"
    },
    "internet": [],
    "mobile": [],
    "electricity": [],
    "gas": [],
    "solar": [],
    "insurance": []
}

def get_details(row, primary_keys):
    details = {}
    for key, value in row.items():
        if key not in primary_keys and value and str(value).strip():
            # Clean up the key name for display
            display_key = key.replace('_', ' ').title()
            details[display_key] = str(value)
    return details

# --- (keep existing functions: parse_price, make_id, get_color) ---

# Mapping NBN -> internet
if 'NBN' in data:
    primary_keys = {'Provider', 'Plan Name', 'Speed Tier', 'Advertised Max DL', 'Typical Evening DL', 'Upload', 'Standard Price', 'Intro Price', 'Plan Link', 'Value Score', 'Best For', 'Deal Type'}
    for row in data['NBN']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = str(row.get('Plan Name', ''))
        # ... (rest of the NBN mapping is fine, just add details)
        products['internet'].append({
            "id": make_id("internet", provider, plan_name),
            "providerName": provider,
            "logoUrl": "", # to be fixed if needed
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"Best for: {row.get('Best For', '')}",
            "keyFeatures": [
                f"Max DL: {row.get('Advertised Max DL', '')} Mbps",
                f"Evening DL: {row.get('Typical Evening DL', '')} Mbps",
                f"Upload: {row.get('Upload', '')} Mbps",
            ],
            "price": parse_price(row.get('Intro Price') or row.get('Standard Price')),
            "priceUnit": "/mo",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": False,
            "isEnabled": True,
            "applicableStates": [],
            "details": get_details(row, primary_keys),
        })

# Mapping MOBILE SIM ONLY -> mobile
if 'MOBILE SIM ONLY' in data:
    primary_keys = {'Provider', 'Plan Name', 'Data', 'Standard Price', 'New Customer Price', 'Discounted Price', 'Plan Link', 'Value Score', 'Best For', 'Deal Type', 'Network Provider', 'Intl Calls'}
    for row in data['MOBILE SIM ONLY']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = str(row.get('Plan Name', ''))
        products['mobile'].append({
            "id": make_id("mobile", provider, plan_name),
            "providerName": provider,
            "logoUrl": "",
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"Standard Price: ${row.get('Standard Price', '')}",
            "keyFeatures": [
                f"Data: {row.get('Data', '')} GB",
                f"Network: {row.get('Network Provider', '')}",
            ],
            "price": parse_price(row.get('Discounted Price') or row.get('New Customer Price') or row.get('Standard Price')),
            "priceUnit": "/mo",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": False,
            "isEnabled": True,
            "applicableStates": [],
            "details": get_details(row, primary_keys),
        })

# Mapping Electricity -> electricity
if 'Electricity' in data:
    primary_keys = {'Provider', 'Plan Name', 'Available States/Areas', 'Plan Type', 'Daily Supply Charge', 'Usage Rate (c/kWh)', 'Solar FIT (c/kWh)', 'Value Score', 'Best For', 'Deal Type', 'Plan Link'}
    for row in data['Electricity']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = str(row.get('Plan Name', ''))
        states = [s.strip() for s in str(row.get('Available States/Areas', '')).split(',') if s.strip()]
        products['electricity'].append({
            "id": make_id("elec", provider, plan_name),
            "providerName": provider,
            "logoUrl": "",
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"Best for: {row.get('Best For', '')}",
            "keyFeatures": [
                f"Type: {row.get('Plan Type', '')}",
                f"Daily Supply: {row.get('Daily Supply Charge', '')}c",
                f"Usage: {row.get('Usage Rate (c/kWh)', '')}c/kWh",
                f"Solar FIT: {row.get('Solar FIT (c/kWh)', '')}c/kWh"
            ],
            "price": parse_price(row.get('Est. Annual Cost @ 4,000 kWh', 0)),
            "priceUnit": "/yr",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": "Green" in plan_name or "Solar" in plan_name,
            "isEnabled": True,
            "applicableStates": states,
            "details": get_details(row, primary_keys),
        })

# Mapping GAS -> gas
if 'GAS' in data:
    primary_keys = {'Provider', 'Gas Type', 'Available States/Areas', 'Plan Name', 'Daily Supply Charge', 'Usage Rate (c/MJ)', 'Value Score', 'Best For', 'Deal Type', 'Plan Link'}
    for row in data['GAS']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = str(row.get('Plan Name', ''))
        states = [s.strip() for s in str(row.get('Available States/Areas', '')).split(',') if s.strip()]
        products['gas'].append({
            "id": make_id("gas", provider, plan_name),
            "providerName": provider,
            "logoUrl": "",
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"Best for: {row.get('Best For', '')}",
            "keyFeatures": [
                f"Type: {row.get('Gas Type', '')}",
                f"Daily Supply: {row.get('Daily Supply Charge', '')}c",
                f"Usage: {row.get('Usage Rate (c/MJ)', '')}c/MJ"
            ],
            "price": parse_price(row.get('Est Annual @ 35k MJ', 0)),
            "priceUnit": "/yr",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": False,
            "isEnabled": True,
            "applicableStates": states,
            "details": get_details(row, primary_keys),
        })

# Mapping SOLAR -> solar
if 'SOLAR' in data:
    primary_keys = {'Provider', 'Solar Size (kW)', 'Battery Size (kWh)', 'Gross Price (before rebates)', 'Total Installed Price (after rebates)', 'Plan Link', 'Value Score', 'Deal Type'}
    for row in data['SOLAR']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = f"{row.get('Solar Size (kW)', '')}kW System"
        products['solar'].append({
            "id": make_id("solar", provider, plan_name),
            "providerName": provider,
            "logoUrl": "",
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"Additional costs: {row.get('Additional Costs', 'None')}",
            "keyFeatures": [
                f"Battery: {row.get('Battery Size (kWh)', 'None')} kWh" if row.get('Battery Size (kWh)') else "No Battery",
                f"Warranty: {row.get('Warranty (Panels / Inverter / Battery)', '')}",
            ],
            "price": parse_price(row.get('Total Installed Price (after rebates)', 0)),
            "priceUnit": " total",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": True,
            "isEnabled": True,
            "applicableStates": [],
            "details": get_details(row, primary_keys),
        })

# Mapping Insurance -> insurance
if 'Insurance' in data:
    primary_keys = {'Provider', 'Insurance Type', 'Plan Name', 'Est Annual Premium (indicative*)', 'Effective Annual (approx after offer)', 'Plan Link', 'Value Score', 'Best For', 'Deal Type'}
    for row in data['Insurance']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = str(row.get('Plan Name', ''))
        type_ins = str(row.get('Insurance Type', ''))
        products['insurance'].append({
            "id": make_id("ins", provider, plan_name),
            "providerName": provider,
            "logoUrl": "",
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"{type_ins} Insurance",
            "keyFeatures": [
                f"Type: {type_ins}",
                f"Best For: {row.get('Best For', '')}",
                f"Offer: {row.get('New Customer Offer (April 2026)', '')}"
            ],
            "price": parse_price(row.get('Effective Annual (approx after offer)') or row.get('Est Annual Premium (indicative*)')),
            "priceUnit": "/yr",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": False,
            "isEnabled": True,
            "applicableStates": [],
            "details": get_details(row, primary_keys),
        })

with open('assets/data/products.json', 'w') as f:
    json.dump(products, f, indent=2)

print("Generated products.json with extra details")

