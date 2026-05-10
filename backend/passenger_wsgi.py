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
            output += "\n\nSOLUTION:\n1. Open cPanel Terminal.\n2. Activate your env (source .../bin/activate).\n3. Run: pip install fastapi uvicorn a2wsgi requests python-multipart"
            
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
        response_headers = [('Content-type', 'text/plain')] # Corrected: Removed unnecessary escaping for quotes
        start_response(status, response_headers)
        return [output.encode('utf-8')]