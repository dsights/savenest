from fastapi.concurrency import run_in_threadpool
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import requests
import os
import json
from dotenv import load_dotenv
from ocr_service import extract_bill_data

# Load environment variables from .env file if it exists
load_dotenv()

app = FastAPI()

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
