import csv
import io
import os

CSV_PATH = 'assets/data/products_master - Sheet3.csv'

# Updated plans for June 2026 EOFY
# This dict now acts as our "Discovery & Update" database.
UPDATED_PLANS = {
    # --- SpinTel ---
    "aus_spintel_homestarter": {"price": "39.00", "description": "EOFY Special: $39 for 6 months then $64.95", "rating": "4.8"},
    "aus_spintel_homevalue": {"price": "66.00", "description": "$66 for 6 months then $76.95", "rating": "4.5"},
    "aus_spintel_homeplus": {"price": "71.00", "description": "$71 for 6 months then $81.95", "rating": "4.5"},
    "aus_spintel_25gb": {
        "category": "mobile", "providerName": "SpinTel", "planName": "25GB Mobile", "price": "14.00", "priceUnit": "/mo",
        "description": "$14 for 6 months then $22", "keyFeatures": "25GB Data|Optus Network|No Lock-in",
        "logoUrl": "https://www.spintel.net.au/logo.png", "providerColor": "#09B5F3",
        "directUrl": "https://www.spintel.net.au/mobile/plans", "rating": "4.7", "isSponsored": "FALSE", "isGreen": "FALSE"
    },

    # --- Tangerine ---
    "aus_tangerine_value": {"price": "44.90", "description": "EOFY Deal: $44.90 for 6 months then $69.90", "rating": "4.6"},
    "aus_tangerine_valueplus": {"price": "59.90", "description": "EOFY Deal: $59.90 for 6 months then $84.90", "rating": "4.7"},

    # --- Superloop ---
    "aus_superloop_familymax": {"price": "69.00", "description": "EOFY Deal: $69 for 6 months then $95", "rating": "4.8"},
    "aus_superloop_lightspeed": {"price": "79.00", "description": "EOFY Deal: $79 for 6 months then $109", "rating": "4.9"},

    # --- More ---
    "aus_more_nbn25": {
        "category": "nbn", "providerName": "More", "planName": "Home Starter (NBN 25)", "price": "56.99", "priceUnit": "/mo",
        "description": "CBA Exclusive: $56.99 for 12 months then $76.99", "keyFeatures": "25/10 Mbps|CBA Customer Discount|No Lock-in",
        "logoUrl": "https://www.more.com.au/logo.png", "providerColor": "#00245E", "directUrl": "https://www.more.com.au/nbn",
        "rating": "4.6", "isSponsored": "FALSE", "isGreen": "FALSE"
    },
    "aus_more_nbn50": {
        "category": "nbn", "providerName": "More", "planName": "Value Plus (NBN 50)", "price": "65.00", "priceUnit": "/mo",
        "description": "CBA Exclusive: $65.00 for 12 months then $84.90", "keyFeatures": "50/20 Mbps|CBA Customer Discount|No Lock-in",
        "logoUrl": "https://www.more.com.au/logo.png", "providerColor": "#00245E", "directUrl": "https://www.more.com.au/nbn",
        "rating": "4.7", "isSponsored": "FALSE", "isGreen": "FALSE"
    },
    "aus_more_mobile14": {
        "category": "mobile", "providerName": "More", "planName": "14GB Mobile", "price": "28.00", "priceUnit": "/mo",
        "description": "Telstra Wholesale Network", "keyFeatures": "14GB Data|500GB Databank|eSIM Support",
        "logoUrl": "https://www.more.com.au/logo.png", "providerColor": "#00245E", "directUrl": "https://www.more.com.au/mobile",
        "rating": "4.3", "isSponsored": "FALSE", "isGreen": "FALSE"
    },

    # --- Buddy Telco (New) ---
    "aus_buddy_nbn50": {
        "category": "nbn", "providerName": "Buddy Telco", "planName": "Standard Plus (NBN 50)", "price": "75.00", "priceUnit": "/mo",
        "description": "Budget brand by Aussie Broadband", "keyFeatures": "50/20 Mbps|No Lock-in|App-based Support",
        "logoUrl": "https://www.buddytelco.com.au/logo.png", "providerColor": "#FFD700", "directUrl": "https://www.buddytelco.com.au",
        "rating": "4.7", "isSponsored": "TRUE", "isGreen": "FALSE"
    },
    "aus_buddy_nbn1000": {
        "category": "nbn", "providerName": "Buddy Telco", "planName": "Ultrafast (NBN 1000)", "price": "89.00", "priceUnit": "/mo",
        "description": "$89 for 3 months then $99", "keyFeatures": "1000/50 Mbps|High Speed Value|No Lock-in",
        "logoUrl": "https://www.buddytelco.com.au/logo.png", "providerColor": "#FFD700", "directUrl": "https://www.buddytelco.com.au",
        "rating": "4.9", "isSponsored": "FALSE", "isGreen": "FALSE"
    },

    # --- Flip ---
    "aus_flip_nbn12": {"price": "39.00", "description": "Best for Seniors/Basic Users", "rating": "4.4"},
    "aus_flip_nbn500": {
        "category": "nbn", "providerName": "Flip", "planName": "NBN 500 Family", "price": "69.00", "priceUnit": "/mo",
        "description": "$69 for 6 months then $88.90", "keyFeatures": "500/40 Mbps|No Lock-in|Aussie Support",
        "logoUrl": "https://www.flip.com.au/logo.png", "providerColor": "#F7941D", "directUrl": "https://www.flip.com.au/nbn",
        "rating": "4.6", "isSponsored": "FALSE", "isGreen": "FALSE"
    },

    # --- Mate ---
    "aus_mate_nbn25": {"price": "40.00", "description": "$40 for 6 months with code MATE25", "rating": "4.5"},
    "aus_mate_nbn2000": {
        "category": "nbn", "providerName": "Mate", "planName": "Hyperfast (NBN 2000)", "price": "141.00", "priceUnit": "/mo",
        "description": "$141 for 6 months with code MATE25", "keyFeatures": "2000/100 Mbps|Gigabit+ Ready|100% Aussie Support",
        "logoUrl": "https://www.letsbemates.com.au/logo.png", "providerColor": "#E30613", "directUrl": "https://www.letsbemates.com.au/nbn",
        "rating": "4.8", "isSponsored": "FALSE", "isGreen": "FALSE"
    },

    # --- Aussie Broadband ---
    "aus_abb_nbn25": {"price": "65.10", "description": "30% off for 3 months (Code: BEST30)", "rating": "4.6"},
    "aus_abb_nbn1000": {
        "category": "nbn", "providerName": "Aussie Broadband", "planName": "NBN 1000/50", "price": "129.00", "priceUnit": "/mo",
        "description": "Premium High Speed Experience", "keyFeatures": "1000/50 Mbps|Award Winning Support|FTTP Upgrade Ready",
        "logoUrl": "https://www.aussiebroadband.com.au/logo.png", "providerColor": "#00A651", "directUrl": "https://www.aussiebroadband.com.au/nbn",
        "rating": "4.7", "isSponsored": "FALSE", "isGreen": "FALSE"
    },

    # --- Exetel ---
    "aus_exetel_one": {
        "category": "nbn", "providerName": "Exetel", "planName": "The One Plan (500/50)", "price": "80.00", "priceUnit": "/mo",
        "description": "Flat $80/mth - No promo traps", "keyFeatures": "500/50 Mbps|Warp Speed Boost|Hibernate Mode",
        "logoUrl": "https://www.exetel.com.au/logo.png", "providerColor": "#00AEEF", "directUrl": "https://www.exetel.com.au/broadband/nbn",
        "rating": "4.7", "isSponsored": "TRUE", "isGreen": "FALSE"
    },

    # --- Amaysim NBN ---
    "aus_amaysim_nbn500": {
        "category": "nbn", "providerName": "Amaysim", "planName": "NBN 500", "price": "50.00", "priceUnit": "/mo",
        "description": "$50 for 6 months then $90. Save $10/mth with Amaysim SIM.", "keyFeatures": "500/40 Mbps|Mobile Bundle Discount|No Lock-in",
        "logoUrl": "https://www.amaysim.com.au/logo.png", "providerColor": "#FF5000", "directUrl": "https://www.amaysim.com.au/nbn",
        "rating": "4.8", "isSponsored": "FALSE", "isGreen": "FALSE"
    },

    # --- Kogan Internet ---
    "aus_kogan_nbn500": {
        "category": "nbn", "providerName": "Kogan Internet", "planName": "Silver Plus (NBN 500)", "price": "69.90", "priceUnit": "/mo",
        "description": "$69.90 for 12 months then $85.90", "keyFeatures": "500/40 Mbps|Qantas Points|No Lock-in",
        "logoUrl": "https://www.kogan.com/logo.png", "providerColor": "#EF3340", "directUrl": "https://www.kogan.com/internet",
        "rating": "4.6", "isSponsored": "FALSE", "isGreen": "FALSE"
    },

    # --- Swoop ---
    "aus_swoop_nbn1000": {
        "category": "nbn", "providerName": "Swoop", "planName": "Home Ultrafast", "price": "85.00", "priceUnit": "/mo",
        "description": "$85 for 6 months then $109", "keyFeatures": "1000/50 Mbps|High Speed Specialist|Local Support",
        "logoUrl": "https://www.swoop.com.au/logo.png", "providerColor": "#FF0000", "directUrl": "https://www.swoop.com.au/nbn",
        "rating": "4.7", "isSponsored": "FALSE", "isGreen": "FALSE"
    }
}

def update_csv():
    if not os.path.exists(CSV_PATH):
        print("CSV not found.")
        return

    # Read and clean
    with open(CSV_PATH, 'r', encoding='utf-8') as f:
        content = f.read().splitlines()
    
    clean_lines = []
    for line in content:
        line = line.strip()
        if line.startswith('"') and line.endswith('"'):
            line = line[1:-1].replace('""', '"')
        clean_lines.append(line)
    
    reader = csv.DictReader(io.StringIO('\n'.join(clean_lines)))
    fieldnames = reader.fieldnames
    rows = []
    for row in reader:
        plan_id = row.get('id')
        if plan_id in UPDATED_PLANS:
            updates = UPDATED_PLANS[plan_id]
            for k, v in updates.items():
                if k in row: row[k] = v
        rows.append(row)

    # Add missing
    existing_ids = [r['id'] for r in rows if r.get('id')]
    for plan_id, data in UPDATED_PLANS.items():
        if plan_id not in existing_ids and 'category' in data:
            new_row = {f: "" for f in fieldnames}
            new_row.update(data)
            new_row['id'] = plan_id
            rows.append(new_row)

    # Write back
    output_lines = []
    header_io = io.StringIO()
    writer = csv.DictWriter(header_io, fieldnames=fieldnames)
    writer.writeheader()
    output_lines.append(f'"{header_io.getvalue().strip()}"')
    
    for row in rows:
        row_io = io.StringIO()
        writer = csv.DictWriter(row_io, fieldnames=fieldnames, extrasaction='ignore')
        writer.writerow(row)
        row_str = row_io.getvalue().strip()
        safe_row_str = row_str.replace('"', '""')
        output_lines.append(f'"{safe_row_str}"')

    with open(CSV_PATH, 'w', encoding='utf-8') as f:
        f.write('\n'.join(output_lines) + '\n')

    print(f"Successfully updated CSV with {len(UPDATED_PLANS)} providers/plans.")

if __name__ == "__main__":
    update_csv()
