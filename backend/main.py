from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import requests
import os
import json
from dotenv import load_dotenv

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

@app.post("/upload")
async def proxy_upload(file: UploadFile = File(...)):
    if not HUBSPOT_ACCESS_TOKEN:
        raise HTTPException(status_code=500, detail="Server misconfigured: Missing HubSpot Token")

    try:
        # Read file content
        file_content = await file.read()
        
        # Forward to HubSpot
        hubspot_response = requests.post(
            HUBSPOT_UPLOAD_URL,
            headers={'Authorization': f'Bearer {HUBSPOT_ACCESS_TOKEN}'},
            files={'file': (file.filename, file_content)},
            data={
                'folderPath': 'savenest_bills',
                'options': json.dumps({"access": "PUBLIC_INDEXABLE"})
            }
        )

        # Return HubSpot response directly
        return hubspot_response.json()

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
