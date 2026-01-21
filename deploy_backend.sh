#!/bin/bash
set -e

# ==========================================
# SaveNest Backend - Auto Deployment Script
# ==========================================
# Usage: ./deploy_backend.sh <HUBSPOT_ACCESS_TOKEN>
# Example: ./deploy_backend.sh pat-na1-12345...

HUBSPOT_TOKEN=$1
BASE_PATH="/home/tripxen1"

if [ -z "$HUBSPOT_TOKEN" ]; then
    echo "ERROR: You must provide your HubSpot Access Token."
    echo "Usage: ./deploy_backend.sh <HUBSPOT_ACCESS_TOKEN>"
    exit 1
fi

echo "--- 🚀 Starting Deployment ---"
echo "--- 📂 Base Path: $BASE_PATH ---"

# 1. CLEANUP
echo "--- 🧹 Cleaning up old environments... ---"
rm -rf "$BASE_PATH/virtualenv/savenest_backend"
rm -rf "$BASE_PATH/savenest_backend"
mkdir -p "$BASE_PATH/savenest_backend"
cd "$BASE_PATH/savenest_backend"

# 2. CREATE FILES
echo "--- 📝 Writing Application Files... ---"

# Create requirements.txt
cat <<EOF > requirements.txt
fastapi==0.109.0
uvicorn==0.27.0
python-multipart==0.0.9
requests==2.31.0
a2wsgi==1.10.0
python-dotenv==1.0.1
EOF

# Create main.py (The FastAPI App)
cat <<EOF > main.py
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import requests
import os
import json
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI()

# Injected by shell script or cPanel env
HUBSPOT_ACCESS_TOKEN = os.environ.get("HUBSPOT_ACCESS_TOKEN", "$HUBSPOT_TOKEN") 
ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "*").split(",")

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
    if not HUBSPOT_ACCESS_TOKEN or "REPLACE" in HUBSPOT_ACCESS_TOKEN:
        raise HTTPException(status_code=500, detail="Server Config Error: Missing HubSpot Token")

    try:
        file_content = await file.read()
        hubspot_response = requests.post(
            HUBSPOT_UPLOAD_URL,
            headers={'Authorization': f'Bearer {HUBSPOT_ACCESS_TOKEN}'},
            files={'file': (file.filename, file_content)},
            data={
                'folderPath': 'savenest_bills',
                'options': json.dumps({"access": "PUBLIC_INDEXABLE"})
            }
        )
        return hubspot_response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
EOF

# Create passenger_wsgi.py (The Adapter)
cat <<EOF > passenger_wsgi.py
import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

def application(environ, start_response):
    """
    A diagnostic WSGI entry point.
    It attempts to load the real app. If it fails, it prints the error to the browser.
    """
    errors = []
    
    try:
        # Check modules
        modules = ['fastapi', 'uvicorn', 'a2wsgi', 'requests', 'multipart']
        for mod in modules:
            try:
                __import__(mod)
            except ImportError:
                errors.append(f"MISSING MODULE: {mod}")

        if errors:
            status = '200 OK'
            output = "--- DEPLOYMENT DIAGNOSTIC REPORT ---\n\n"
            output += "\n".join(errors)
            output += "\n\nSOLUTION:\n1. Open cPanel Terminal.\n2. Activate your env (source .../bin/activate).\n3. Run: pip install fastapi uvicorn a2wsgi requests python-multipart python-dotenv"
            
            response_headers = [('Content-type', 'text/plain')]
            start_response(status, response_headers)
            return [output.encode('utf-8')]

        # If modules exist, load the real app
        from a2wsgi import ASGIMiddleware
        from main import app as asgi_app
        
        # Create the real app adapter
        real_app = ASGIMiddleware(asgi_app)
        
        # Delegate to the real app
        return real_app(environ, start_response)

    except Exception as e:
        status = '200 OK'
        import traceback
        output = f"CRITICAL STARTUP ERROR:\n{str(e)}\n\n{traceback.format_exc()}"
        response_headers = [('Content-type', 'text/plain')]
        start_response(status, response_headers)
        return [output.encode('utf-8')]
EOF

# 3. SETUP VIRTUAL ENVIRONMENT & INSTALL
echo "--- 🐍 Building Virtual Environment (Python 3.9)... ---"
VENV_DIR="$BASE_PATH/virtualenv/savenest_backend/3.9"
mkdir -p "$VENV_DIR"

# Create venv (using --without-pip to bypass ensurepip errors on some hosts)
if ! python3.9 -m venv --without-pip "$VENV_DIR"; then
    echo "--- ⚠️ venv failed, trying virtualenv... ---"
    virtualenv -p python3.9 "$VENV_DIR" --no-pip
fi

# Activate
source "$VENV_DIR/bin/activate" || . "$VENV_DIR/bin/activate"

# Manually install pip since we skipped it
echo "--- 📥 Installing Pip manually... ---"
curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py || wget -q https://bootstrap.pypa.io/get-pip.py -O get-pip.py
"$VENV_DIR/bin/python" get-pip.py
rm get-pip.py

# Install dependencies
echo "--- 📦 Installing Dependencies... ---"
"$VENV_DIR/bin/pip" install -r requirements.txt

echo "--- ✅ Deployment Files & Environment Ready! ---"
echo "--- ℹ️  IMPORTANT: cPanel Registration Required ---"
echo "To see this in the 'Setup Python App' UI, you must create it once:"
echo "1. Log into cPanel > Setup Python App"
echo "2. Click 'Create Application'"
echo "3. Python Version: 3.9"
echo "4. Application root: savenest_backend"
echo "5. Application URL: api (or your choice)"
echo "6. Application startup file: passenger_wsgi.py"
echo "7. Application Entry point: application"
echo "8. Click 'Create' and then 'Restart'"
echo "--- 🌐 Testing URL: https://savenest.au/api/ ---"

echo "--- ✅ Deployment Complete! ---"
echo "1. Go to cPanel > Setup Python App"
echo "2. Ensure the app 'savenest_backend' is created with Python 3.9"
echo "3. Click RESTART"
echo "4. Test: https://savenest.au/api/"