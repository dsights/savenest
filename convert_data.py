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

# Mapping NBN -> internet
if 'NBN' in data:
    for row in data['NBN']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = str(row.get('Plan Name', ''))
        features = [
            f"Max DL: {row.get('Advertised Max DL', '')} Mbps",
            f"Evening DL: {row.get('Typical Evening DL', '')} Mbps",
            f"Upload: {row.get('Upload', '')} Mbps",
            f"Type: {row.get('Deal Type', '')}"
        ]
        products['internet'].append({
            "id": make_id("internet", provider, plan_name),
            "providerName": provider,
            "logoUrl": "", # to be fixed if needed
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"Best for: {row.get('Best For', '')}",
            "keyFeatures": [f for f in features if f and not f.endswith(":  Mbps") and not f.endswith(": ")],
            "price": parse_price(row.get('Intro Price') or row.get('Standard Price')),
            "priceUnit": "/mo",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": False,
            "isEnabled": True,
            "applicableStates": []
        })

# Mapping MOBILE SIM ONLY -> mobile
if 'MOBILE SIM ONLY' in data:
    for row in data['MOBILE SIM ONLY']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = str(row.get('Plan Name', ''))
        features = [
            f"Data: {row.get('Data', '')}",
            f"Network: {row.get('Network Provider', '')}",
            f"Intl Calls: {row.get('Intl Calls', '')}"
        ]
        products['mobile'].append({
            "id": make_id("mobile", provider, plan_name),
            "providerName": provider,
            "logoUrl": "",
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"Standard Price: ${row.get('Standard Price', '')}",
            "keyFeatures": [f for f in features if f and not f.endswith(": ")],
            "price": parse_price(row.get('Discounted Price') or row.get('New Customer Price') or row.get('Standard Price')),
            "priceUnit": "/mo",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": False,
            "isEnabled": True,
            "applicableStates": []
        })

# Mapping Electricity -> electricity
if 'Electricity' in data:
    for row in data['Electricity']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = str(row.get('Plan Name', ''))
        states = [s.strip() for s in str(row.get('Available States/Areas', '')).split(',') if s.strip()]
        features = [
            f"Type: {row.get('Plan Type', '')}",
            f"Daily Supply: {row.get('Daily Supply Charge', '')}c",
            f"Usage: {row.get('Usage Rate (c/kWh)', '')}c/kWh",
            f"Solar FIT: {row.get('Solar FIT (c/kWh)', '')}c/kWh"
        ]
        products['electricity'].append({
            "id": make_id("elec", provider, plan_name),
            "providerName": provider,
            "logoUrl": "",
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"Best for: {row.get('Best For', '')}",
            "keyFeatures": [f for f in features if f and not f.endswith(": c") and not f.endswith(": ") and not f.endswith(": c/kWh")],
            "price": parse_price(row.get('Est. Annual Cost @ 4,000 kWh', 0)),
            "priceUnit": "/yr",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": "Green" in plan_name or "Solar" in plan_name,
            "isEnabled": True,
            "applicableStates": states
        })

# Mapping GAS -> gas
if 'GAS' in data:
    for row in data['GAS']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = str(row.get('Plan Name', ''))
        states = [s.strip() for s in str(row.get('Available States/Areas', '')).split(',') if s.strip()]
        features = [
            f"Type: {row.get('Gas Type', '')}",
            f"Daily Supply: {row.get('Daily Supply Charge', '')}c",
            f"Usage: {row.get('Usage Rate (c/MJ)', '')}c/MJ"
        ]
        products['gas'].append({
            "id": make_id("gas", provider, plan_name),
            "providerName": provider,
            "logoUrl": "",
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"Best for: {row.get('Best For', '')}",
            "keyFeatures": [f for f in features if f and not f.endswith(": c") and not f.endswith(": ") and not f.endswith(": c/MJ")],
            "price": parse_price(row.get('Est Annual @ 35k MJ', 0)),
            "priceUnit": "/yr",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": False,
            "isEnabled": True,
            "applicableStates": states
        })

# Mapping SOLAR -> solar
if 'SOLAR' in data:
    for row in data['SOLAR']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = f"{row.get('Solar Size (kW)', '')}kW System"
        features = [
            f"Battery: {row.get('Battery Size (kWh)', 'None')} kWh" if row.get('Battery Size (kWh)') else "No Battery",
            f"Warranty: {row.get('Warranty (Panels / Inverter / Battery)', '')}",
            f"Timeline: {row.get('Delivery Timeline', '')}",
            f"Type: {row.get('Deal Type', '')}"
        ]
        products['solar'].append({
            "id": make_id("solar", provider, plan_name),
            "providerName": provider,
            "logoUrl": "",
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"Additional costs: {row.get('Additional Costs', 'None')}",
            "keyFeatures": [f for f in features if f and not f.endswith(": ")],
            "price": parse_price(row.get('Total Installed Price (after rebates)', 0)),
            "priceUnit": " total",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": True,
            "isEnabled": True,
            "applicableStates": []
        })

# Mapping Insurance -> insurance
if 'Insurance' in data:
    for row in data['Insurance']:
        provider = str(row.get('Provider', ''))
        if not provider: continue
        plan_name = str(row.get('Plan Name', ''))
        type_ins = str(row.get('Insurance Type', ''))
        features = [
            f"Type: {type_ins}",
            f"Best For: {row.get('Best For', '')}",
            f"Offer: {row.get('New Customer Offer (April 2026)', '')}"
        ]
        products['insurance'].append({
            "id": make_id("ins", provider, plan_name),
            "providerName": provider,
            "logoUrl": "",
            "providerColor": get_color(provider),
            "planName": plan_name,
            "description": f"{type_ins} Insurance",
            "keyFeatures": [f for f in features if f and not f.endswith(": ")],
            "price": parse_price(row.get('Effective Annual (approx after offer)') or row.get('Est Annual Premium (indicative*)')),
            "priceUnit": "/yr",
            "affiliateUrl": row.get('Plan Link', ''),
            "directUrl": row.get('Plan Link', ''),
            "rating": float(row.get('Value Score', 40)) / 20.0,
            "isSponsored": False,
            "isGreen": False,
            "isEnabled": True,
            "applicableStates": []
        })

with open('assets/data/products.json', 'w') as f:
    json.dump(products, f, indent=2)

print("Generated products.json")
