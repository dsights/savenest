
import os
import requests
from dotenv import load_dotenv

load_dotenv()

BASIQ_API_KEY = os.getenv("BASIQ_API_KEY")
BASIQ_API_URL = "https://au-api.basiq.io"

def is_enabled():
    """
    Check if the Basiq service is enabled.
    """
    return BASIQ_API_KEY and BASIQ_API_KEY != "your_basiq_api_key"

def get_client_access_token():
    """
    Get a client access token from the Basiq API.
    Returns None if the service is not enabled.
    """
    if not is_enabled():
        return None
        
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Basic {BASIQ_API_KEY}",
        "basiq-version": "3.0"
    }
    response = requests.post(f"{BASIQ_API_URL}/token", headers=headers)
    response.raise_for_status()
    return response.json()["access_token"]

def create_user(access_token, email):
    """
    Create a new user in the Basiq system.
    """
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {access_token}",
    }
    data = {
        "email": email
    }
    response = requests.post(f"{BASIQ_API_URL}/users", headers=headers, json=data)
    response.raise_for_status()
    return response.json()

def create_connection_url(access_token, user_id):
    """
    Create a new connection URL for a user.
    """
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {access_token}",
    }
    data = {
        "institutionId": "AU-EN-DUMMY" # Using a dummy energy provider for now
    }
    response = requests.post(f"{BASIQ_API_URL}/users/{user_id}/connections", headers=headers, json=data)
    response.raise_for_status()
    return response.json()

if __name__ == '__main__':
    # Example usage
    if not BASIQ_API_KEY:
        print("Error: BASIQ_API_KEY environment variable not set.")
    else:
        try:
            client_token = get_client_access_token()
            print(f"Client access token: {client_token}")
            # In a real application, you would get the user's email from your system
            user = create_user(client_token, "test.user@example.com")
            print(f"Created user: {user}")
            
            connection_url_data = create_connection_url(client_token, user['id'])
            print(f"Connection URL data: {connection_url_data}")

        except requests.exceptions.HTTPError as e:
            print(f"HTTP Error: {e.response.status_code} {e.response.text}")
        except Exception as e:
            print(f"An error occurred: {e}")

