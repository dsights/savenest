
import json
import requests
from bs4 import BeautifulSoup
import os

# --- Configuration ---
SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
PRODUCTS_JSON_PATH = os.path.join(SCRIPT_DIR, '..', 'assets', 'data', 'products.json')

TPG_NBN_URL = "https://www.tpg.com.au/nbn"

def scrape_tpg_nbn_plans():
    """
    Scrapes the TPG NBN plans page to extract plan details.
    
    NOTE: This is a fragile implementation and is likely to break if TPG
    changes their website structure. Web scraping is not a recommended
    approach for production systems.
    """
    print(f"Scraping TPG NBN plans from: {TPG_NBN_URL}")
    
    try:
        response = requests.get(TPG_NBN_URL)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching TPG NBN page: {e}")
        return []

    soup = BeautifulSoup(response.content, 'html.parser')
    
    # This is a highly specific selector that is likely to change.
    # I am creating this based on a hypothetical structure of the TPG website.
    # In a real scenario, this would need to be carefully inspected and tested.
    plan_cards = soup.select('.nbn-plan-card') 

    extracted_plans = []
    for card in plan_cards:
        try:
            plan_name = card.select_one('.plan-name').get_text(strip=True)
            price = card.select_one('.price').get_text(strip=True)
            speed = card.select_one('.speed').get_text(strip=True)
            data = card.select_one('.data').get_text(strip=True)

            # Basic data cleaning and transformation
            price_value = float(price.replace('$', '').replace('/mo', '').strip())

            extracted_plans.append({
                "id": f"tpg_nbn_{plan_name.lower().replace(' ', '')}",
                "providerName": "TPG",
                "planName": plan_name,
                "description": f"{speed} speed with {data} data",
                "keyFeatures": [
                    f"Speed: {speed}",
                    f"Data: {data}",
                ],
                "price": price_value,
                "priceUnit": "/mo",
                "affiliateUrl": "https://savenest.au/provider/tpg",
                "directUrl": TPG_NBN_URL,
                "rating": 4.0, # Placeholder
                "isSponsored": False,
                "isGreen": False,
                "isEnabled": True,
                "applicableStates": [],
            })
        except (AttributeError, ValueError) as e:
            print(f"Skipping a plan card due to parsing error: {e}")
            continue
            
    return extracted_plans

def update_internet_plans():
    """
    Updates the internet plans in products.json by scraping provider websites.
    """
    print("Starting internet plan update...")
    
    # Read the existing products.json file
    try:
        with open(PRODUCTS_JSON_PATH, 'r') as f:
            products_data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        print(f"Warning: Could not read or parse {PRODUCTS_JSON_PATH}. A new file will be created.")
        products_data = {"internet": [], "electricity": []}

    # For this proof-of-concept, we are only scraping TPG.
    # A real implementation would need to scrape multiple providers.
    tpg_plans = scrape_tpg_nbn_plans()
    
    # We will replace all existing internet plans with the new scraped plans.
    # A more sophisticated approach would be to merge the new plans with the
    # existing ones, but for this example, we'll keep it simple.
    products_data['internet'] = tpg_plans
    
    # Write the updated data back to the file
    try:
        with open(PRODUCTS_JSON_PATH, 'w') as f:
            json.dump(products_data, f, indent=2)
        print("Successfully updated internet plans in products.json.")
    except IOError as e:
        print(f"Error writing to {PRODUCTS_JSON_PATH}: {e}")

if __name__ == '__main__':
    update_internet_plans()
