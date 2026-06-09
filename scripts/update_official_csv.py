import csv
import io
import os

CSV_PATH = 'assets/data/products_master - Sheet3.csv'

# Updated plans for June 2026 EOFY
UPDATED_PLANS = {
    "aus_spintel_homestarter": {
        "price": "39.00",
        "description": "EOFY Special: $39 for 6 months then $64.95",
        "rating": "4.8"
    },
    "aus_spintel_homevalue": {
        "price": "66.00",
        "description": "$66 for 6 months then $76.95",
        "rating": "4.5"
    },
    "aus_spintel_homeplus": {
        "price": "71.00",
        "description": "$71 for 6 months then $81.95",
        "rating": "4.5"
    },
    "aus_tangerine_value": {
        "price": "44.90",
        "description": "EOFY Deal: $44.90 for 6 months then $69.90",
        "rating": "4.6"
    },
    "aus_tangerine_valueplus": {
        "price": "59.90",
        "description": "EOFY Deal: $59.90 for 6 months then $84.90",
        "rating": "4.7"
    },
    "aus_superloop_familymax": {
        "price": "69.00",
        "description": "EOFY Deal: $69 for 6 months then $95",
        "rating": "4.8"
    },
    "aus_superloop_lightspeed": {
        "price": "79.00",
        "description": "EOFY Deal: $79 for 6 months then $109",
        "rating": "4.9"
    },
    "aus_spintel_25gb": {
        "category": "mobile",
        "id": "aus_spintel_25gb",
        "providerName": "SpinTel",
        "planName": "25GB Mobile",
        "price": "14.00",
        "priceUnit": "/mo",
        "description": "$14 for 6 months then $22",
        "keyFeatures": "25GB Data|Optus Network|No Lock-in",
        "logoUrl": "https://www.spintel.net.au/logo.png",
        "providerColor": "#09B5F3",
        "directUrl": "https://www.spintel.net.au/mobile/plans",
        "rating": "4.7",
        "isSponsored": "FALSE",
        "isGreen": "FALSE"
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
            rows.append(new_row)

    # Write back with the weird wrapping quotes
    output_lines = []
    
    # Header
    header_io = io.StringIO()
    writer = csv.DictWriter(header_io, fieldnames=fieldnames)
    writer.writeheader()
    header_str = header_io.getvalue().strip()
    output_lines.append(f'"{header_str}"')
    
    # Data
    for row in rows:
        row_io = io.StringIO()
        # Use a fresh writer to avoid header
        writer = csv.DictWriter(row_io, fieldnames=fieldnames, extrasaction='ignore')
        writer.writerow(row)
        row_str = row_io.getvalue().strip()
        # Handle internal quotes by doubling them
        safe_row_str = row_str.replace('"', '""')
        output_lines.append(f'"{safe_row_str}"')

    with open(CSV_PATH, 'w', encoding='utf-8') as f:
        f.write('\n'.join(output_lines) + '\n')

    print("Successfully updated CSV with official provider plans.")

if __name__ == "__main__":
    update_csv()
