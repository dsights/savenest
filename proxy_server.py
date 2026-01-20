import http.server
import socketserver
import requests
import cgi
import json
import os

PORT = 8888
HUBSPOT_UPLOAD_URL = "https://api.hubapi.com/files/v3/files"
ACCESS_TOKEN = os.environ.get("HUBSPOT_ACCESS_TOKEN")

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()

    def do_POST(self):
        # 1. Parse the incoming Multipart Form Data (The Image)
        content_type, pdict = cgi.parse_header(self.headers['content-type'])
        if content_type == 'multipart/form-data':
            pdict['boundary'] = bytes(pdict['boundary'], "utf-8")
            form = cgi.FieldStorage(
                fp=self.rfile,
                headers=self.headers,
                environ={'REQUEST_METHOD': 'POST', 'CONTENT_TYPE': self.headers['Content-Type']},
            )
            
            # Get the file item
            file_item = form['file']
            file_content = file_item.file.read()
            filename = file_item.filename

            # 2. Forward to HubSpot
            print(f"Proxying upload for: {filename}")
            
            try:
                hubspot_response = requests.post(
                    HUBSPOT_UPLOAD_URL,
                    headers={'Authorization': f'Bearer {ACCESS_TOKEN}'},
                    files={'file': (filename, file_content)},
                    data={
                        'folderPath': 'savenest_bills',
                        'options': json.dumps({"access": "PUBLIC_INDEXABLE"})
                    }
                )
                
                # 3. Return HubSpot's response to the App
                self.send_response(hubspot_response.status_code)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(hubspot_response.content)
                
            except Exception as e:
                self.send_response(500)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(bytes(f"Proxy Error: {e}", "utf-8"))

print(f"Starting Proxy Server on port {PORT}...")
with socketserver.TCPServer(("", PORT), ProxyHandler) as httpd:
    httpd.serve_forever()
