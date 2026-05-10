from fastapi.concurrency import run_in_threadpool
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import requests
import os
import json
import csv
from pydantic import BaseModel
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables from .env file if it exists
load_dotenv()

app = FastAPI()

class SolarLead(BaseModel):
    name: str
    email: str
    postcode: str
    billAmount: str
    phone: str

@app.post("/api/solar-lead")
async def create_solar_lead(lead: SolarLead):
    try:
        # 1. Save to local CSV as fallback
        file_exists = os.path.isfile('solar_leads.csv')
        with open('solar_leads.csv', mode='a', newline='') as f:
            writer = csv.writer(f)
            if not file_exists:
                writer.writerow(['timestamp', 'name', 'email', 'postcode', 'bill_amount', 'phone'])
            writer.writerow([datetime.now().isoformat(), lead.name, lead.email, lead.postcode, lead.billAmount, lead.phone])

        # 2. Submit to HubSpot CRM (Contacts API)
        if HUBSPOT_ACCESS_TOKEN:
            hubspot_url = "https://api.hubapi.com/crm/v3/objects/contacts"
            headers = {
                'Authorization': f'Bearer {HUBSPOT_ACCESS_TOKEN}',
                'Content-Type': 'application/json'
            }
            
            # Split name into first and last for HubSpot
            name_parts = lead.name.split(' ', 1)
            first_name = name_parts[0]
            last_name = name_parts[1] if len(name_parts) > 1 else "Solar Lead"

            payload = {
                "properties": {
                    "firstname": first_name,
                    "lastname": last_name,
                    "email": lead.email,
                    "phone": lead.phone,
                    "zip": lead.postcode,
                    "industry": "Solar",
                    "description": f"Solar Quote Request. Quarterly Bill: ${lead.billAmount}. Postcode: {lead.postcode}"
                }
            }
            hs_resp = requests.post(hubspot_url, headers=headers, json=payload)
            if hs_resp.status_code >= 400:
                print(f"HubSpot Lead Sync Error: {hs_resp.text}")

        # 3. Optional: Send to Zapier Webhook
        zapier_webhook = os.environ.get("ZAPIER_SOLAR_WEBHOOK")
        if zapier_webhook:
            requests.post(zapier_webhook, json=lead.dict())

        # 4. Automated Auto-Responder
        try:
            template_path = os.path.join(os.path.dirname(__file__), '..', 'email-config', 'templates', 'solar_auto_responder.html')
            if os.path.exists(template_path):
                with open(template_path, 'r') as tf:
                    html_content = tf.read()
                
                # Simple replacement
                html_content = html_content.replace('[Name]', lead.name)
                html_content = html_content.replace('[Postcode]', lead.postcode)
                html_content = html_content.replace('[BillAmount]', lead.billAmount)
                
                temp_email_file = f"temp_solar_resp_{lead.phone}.html"
                with open(temp_email_file, 'w') as ef:
                    ef.write(html_content)
                
                email_script = os.path.join(os.path.dirname(__file__), '..', 'email-config', 'send_single_email.sh')
                subject = "Your Solar Savings Quote - Quick Question"
                
                # Execute bash script
                subprocess.run([email_script, subject, temp_email_file, lead.email], check=True)
                os.remove(temp_email_file)
        except Exception as e:
            print(f"Auto-responder failed: {e}")

        return {"success": True, "message": "Lead received and synced to HubSpot"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process lead: {str(e)}")

# 1. Security: Get Secrets from Environment Variables
HUBSPOT_ACCESS_TOKEN = os.environ.get("HUBSPOT_ACCESS_TOKEN")
ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "*").split(",")

# 2. Security: CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["POST", "OPTIONS"],
    allow_headers=["*"],
)

HUBSPOT_UPLOAD_URL = "https://api.hubapi.com/files/v3/files"

@app.get("/")
def health_check():
    return {"status": "ok", "service": "savenest-backend"}

@app.post("/ocr")
async def process_bill(file: UploadFile = File(...)):
    try:
        content = await file.read()
        data = extract_bill_data(content)
        return {"success": True, "data": data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OCR Failed: {str(e)}")

@app.post("/upload")
async def proxy_upload(file: UploadFile = File(...)):
    if not HUBSPOT_ACCESS_TOKEN:
        raise HTTPException(status_code=500, detail="Server misconfigured: Missing HubSpot Token")

    try:
        # Read file content once to use for both services
        file_content = await file.read()
        
        # Add logging to inspect the incoming file
        print(f"--- HubSpot Upload ---")
        print(f"Received file: {file.filename}")
        print(f"Content-Type: {file.content_type}")
        print(f"----------------------")
        
        # 1. HubSpot Upload (Critical Path)
        # Re-structure the request to match HubSpot SDK's approach
        file_options = {
            "access": "PUBLIC_INDEXABLE"
        }
        
        request_files = {
            'file': (file.filename, file_content, file.content_type),
            'options': (None, json.dumps(file_options)),
            'folderPath': (None, 'savenest_bills'),
        }

        hubspot_response = requests.post(
            HUBSPOT_UPLOAD_URL,
            headers={'Authorization': f'Bearer {HUBSPOT_ACCESS_TOKEN}'},
            files=request_files
        )
        
        # Add logging to see the response from HubSpot
        if hubspot_response.status_code < 200 or hubspot_response.status_code >= 300:
            print(f"HubSpot Upload Error: Status={hubspot_response.status_code}, Body={hubspot_response.text}")
        
        hubspot_data = hubspot_response.json()

        # 2. Google Cloud OCR (Enhancement Path)
        # Only attempt if upload succeeded to avoid wasting API calls on bad requests
        if 200 <= hubspot_response.status_code < 300:
            try:
                # Run OCR in a thread pool so it doesn't block the server loop
                ocr_data = await run_in_threadpool(extract_bill_data, file_content)
                
                # Merge OCR data into response. 
                # HubSpot returns a dict, so we can safely add a key.
                if isinstance(hubspot_data, dict):
                    hubspot_data['ocr_analysis'] = ocr_data
            except Exception as e:
                # Log error but DO NOT fail the request. The user still needs the file uploaded.
                print(f"OCR Enhancement Failed: {e}")
                if isinstance(hubspot_data, dict):
                     hubspot_data['ocr_error'] = str(e)

        # Propagate the exact status code and (enhanced) response
        return JSONResponse(
            status_code=hubspot_response.status_code,
            content=hubspot_data
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
