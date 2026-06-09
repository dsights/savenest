import os
import requests
import json
from dotenv import load_dotenv

load_dotenv()

HUBSPOT_ACCESS_TOKEN = os.environ.get("HUBSPOT_ACCESS_TOKEN")

class HubSpotManager:
    def __init__(self):
        self.base_url = "https://api.hubapi.com/crm/v3/objects"
        self.headers = {
            'Authorization': f'Bearer {HUBSPOT_ACCESS_TOKEN}',
            'Content-Type': 'application/json'
        }

    def get_companies(self, limit=10):
        """Fetch companies (Vendors) from HubSpot."""
        if not HUBSPOT_ACCESS_TOKEN:
            return {"error": "Missing HUBSPOT_ACCESS_TOKEN"}
        
        url = f"{self.base_url}/companies"
        params = {
            "limit": limit,
            "properties": "name,domain,city,state,lifecyclestage"
        }
        
        resp = requests.get(url, headers=self.headers, params=params)
        return resp.json()

    def get_contacts(self, limit=10):
        """Fetch contacts (Leads) from HubSpot."""
        if not HUBSPOT_ACCESS_TOKEN:
            return {"error": "Missing HUBSPOT_ACCESS_TOKEN"}
            
        url = f"{self.base_url}/contacts"
        params = {
            "limit": limit,
            "properties": "firstname,lastname,email,phone,lifecyclestage"
        }
        
        resp = requests.get(url, headers=self.headers, params=params)
        return resp.json()

    def update_object_status(self, object_type, object_id, properties):
        """Update a company or contact property (e.g., status)."""
        url = f"{self.base_url}/{object_type}/{object_id}"
        payload = {"properties": properties}
        
        resp = requests.patch(url, headers=self.headers, json=payload)
        return resp.json()

if __name__ == "__main__":
    manager = HubSpotManager()
    
    print("--- 🏢 Fetching Companies (Vendors) ---")
    companies = manager.get_companies()
    print(json.dumps(companies, indent=2))
    
    print("\n--- 👤 Fetching Contacts (Leads) ---")
    contacts = manager.get_contacts()
    print(json.dumps(contacts, indent=2))
