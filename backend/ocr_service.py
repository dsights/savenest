from google.cloud import vision
from google.oauth2 import service_account
import os
import json
import io

def extract_bill_data(file_bytes):
    """
    Extracts text from an image using Google Cloud Vision API.
    Does NOT throw exceptions that crash the app; returns error dict instead.
    """
    try:
        # 1. Load Credentials
        credentials_json = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS_JSON")
        
        if credentials_json:
            cred_info = json.loads(credentials_json)
            credentials = service_account.Credentials.from_service_account_info(cred_info)
            client = vision.ImageAnnotatorClient(credentials=credentials)
        else:
            # Fallback to standard GOOGLE_APPLICATION_CREDENTIALS file path
            client = vision.ImageAnnotatorClient()

        # 2. Prepare the image
        image = vision.Image(content=file_bytes)

        # 3. Call the API (Text Detection)
        response = client.text_detection(image=image)
        texts = response.text_annotations

        if response.error.message:
            return {"error": f"Google Vision API Error: {response.error.message}"}

        if not texts:
            return {"raw_text": "", "structured_data": {}, "provider": "Unknown"}

        # 4. Process the result
        full_text = texts[0].description
        
        return {
            "raw_text": full_text[:500] + "...", # Truncate for log safety
            "provider": _guess_provider(full_text),
            # "lines": [text.description for text in texts[1:]] # Detailed lines
        }

    except Exception as e:
        print(f"OCR Internal Error: {e}")
        return {"error": str(e)}

def _guess_provider(text):
    text_lower = text.lower()
    # Major Australian Providers
    if "agl" in text_lower: return "AGL"
    if "origin" in text_lower: return "Origin Energy"
    if "energyaustralia" in text_lower: return "EnergyAustralia"
    if "telstra" in text_lower: return "Telstra"
    if "optus" in text_lower: return "Optus"
    if "tpg" in text_lower: return "TPG"
    if "vodafone" in text_lower: return "Vodafone"
    if "red energy" in text_lower: return "Red Energy"
    if "alinta" in text_lower: return "Alinta Energy"
    return "Unknown Provider"
