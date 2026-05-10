
import json
import requests
import os

# --- Configuration ---
# The path to the products.json file
SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
PRODUCTS_JSON_PATH = os.path.join(SCRIPT_DIR, '..', 'assets', 'data', 'products.json')

# The base URL for the AER CDR API
AER_API_BASE_URL = "https://api.cdr.gov.au/cdr-register/v1"

# A list of known retailer URIs. In a real scenario, this would be fetched
# from the CDR register's get-data-holders endpoint.
# For now, we'll use a static list of some major retailers.
RETAILER_URIS = [
    "https://cdr.agl.com.au",
    "https://cdr.originenergy.com.au",
    "https://cdr.energyaustralia.com.au",
]

def get_retailer_plans(retailer_uri):
    """
    Fetches the energy plans for a given retailer.
    """
    print(f"Fetching plans from: {retailer_uri}")
    plans_url = f"{retailer_uri}/cds-au/v1/energy/plans"
    try:
        response = requests.get(plans_url, headers={"x-v": "1"})
        response.raise_for_status()
        return response.json()['data']['plans']
    except requests.exceptions.RequestException as e:
        print(f"Error fetching plans for {retailer_uri}: {e}")
        print("Please ensure you have a working internet connection and that the retailer URI is correct.")
        return []

def transform_plan(plan, retailer_name):
    """
    Transforms a plan from the AER API format to the format
    expected in products.json.
    """
    # Identify if it's a solar plan by checking for feed-in tariffs
    is_solar = False
    solar_features = []
    if plan.get('solarFeedInTariff'):
        is_solar = any(tariff.get('solarFeedInTariff', 0) > 0 for tariff in plan.get('solarFeedInTariff'))
        if is_solar:
            # Add details about the solar tariff to the key features
            for tariff in plan.get('solarFeedInTariff'):
                solar_features.append(f"Solar Feed-in: {tariff.get('displayName', '')} - {tariff.get('solarFeedInTariff')} c/kWh")

    # Extract incentives and discounts
    offer_features = []
    if plan.get('incentives'):
        for incentive in plan.get('incentives'):
            offer_features.append(f"Offer: {incentive.get('displayName', '')} - {incentive.get('description', '')}")

    key_features = [
        f"Type: {plan.get('type', 'N/A')}",
        f"Customer Type: {plan.get('customerType', 'N/A')}",
    ] + solar_features + offer_features

    return {
        "id": plan['planId'],
        "providerName": retailer_name,
        "logoUrl": "", # The AER API doesn't provide logos
        "providerColor": "",
        "planName": plan.get('displayName', 'Unnamed Plan'),
        "description": plan.get('description', ''),
        "keyFeatures": key_features,
        "price": 0, # The AER API has a complex pricing structure that requires more processing
        "priceUnit": "/mo",
        "affiliateUrl": "",
        "directUrl": "",
        "rating": 0,
        "isSponsored": False,
        "isGreen": is_solar,
        "isEnabled": True,
        "applicableStates": [],
    }

def update_electricity_plans():
    """
    Fetches the latest electricity plans from the AER API and updates
    products.json.
    
    This script needs a working internet connection to fetch the data.
    """
    print("Starting electricity plan update...")
    
    # Read the existing products.json file
    try:
        with open(PRODUCTS_JSON_PATH, 'r') as f:
            products_data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Warning: Could not read or parse {PRODUCTS_JSON_PATH}. A new file may be created. {e}")
        products_data = {"internet": [], "electricity": []}


    all_new_plans = []
    for uri in RETAILER_URIS:
        retailer_name = uri.split('.')[1].capitalize() # Simple way to get a name
        plans = get_retailer_plans(uri)
        if plans:
            transformed_plans = [transform_plan(p, retailer_name) for p in plans]
            all_new_plans.extend(transformed_plans)
            print(f"Successfully fetched and transformed {len(transformed_plans)} plans for {retailer_name}.")

    # Update the electricity section of the products data
    if all_new_plans:
        products_data['electricity'] = all_new_plans
        
        # Write the updated data back to the file
        try:
            with open(PRODUCTS_JSON_PATH, 'w') as f:
                json.dump(products_data, f, indent=2)
            print("Successfully updated electricity plans in products.json.")
        except IOError as e:
            print(f"Error writing to {PRODUCTS_JSON_PATH}: {e}")
    else:
        print("No new plans were fetched. The products.json file was not updated.")


if __name__ == '__main__':
    update_electricity_plans()
