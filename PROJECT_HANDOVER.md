# SaveNest Technical Operations & Deployment Manual

## 1. Project Overview
SaveNest is a full-stack application consisting of:
*   **Frontend:** A Flutter Web application providing a Glassmorphism UI for bill management and savings calculation.
*   **Backend (savenest_backend):** A Python FastAPI proxy server.

### Why is `savenest_backend` required?
1.  **CORS Bypass:** Browsers block direct requests from a website (savenest.au) to HubSpot APIs for security reasons. The backend acts as a "trusted bridge."
2.  **Secret Management:** It keeps your `HUBSPOT_ACCESS_TOKEN` hidden from the public. If the token were in the Flutter code, anyone could inspect the source and steal it.
3.  **File Processing:** It handles the multipart upload requirements of HubSpot's File API.

---

## 2. GitHub Migration & Source Control
To move the code to your GitHub and enable automation:

### GitHub Link
Ensure your remote is set: `https://github.com/YOUR_USERNAME/savenest.git`

### Migration Commands
```bash
git remote add origin https://github.com/YOUR_USERNAME/savenest.git
git branch -M main
git push -u origin main
```

### GitHub Secrets Configuration
Go to **Settings > Secrets and variables > Actions** and add these:
| Secret Name | Value |
| :--- | :--- |
| `FTP_USERNAME` | `tripxen1` |
| `FTP_PASSWORD` | Your cPanel/SSH Password |
| `SSH_USERNAME` | `tripxen1` |
| `SSH_PASSWORD` | Your cPanel/SSH Password |
| `HUBSPOT_TOKEN` | `pat-ap1-be7cb5e3-...` |

---

## 3. Production Setup (cPanel UI)

### Backend Setup (Setup Python App)
1.  **Create Application**:
    *   Python Version: **3.9**
    *   App Root: `savenest_backend`
    *   App URL: `api`
    *   Startup File: `passenger_wsgi.py`
    *   Entry Point: `application`
2.  **Environment Variables (CRITICAL)**:
    *   `HUBSPOT_ACCESS_TOKEN`: Your pat-ap1 token.
    *   `ALLOWED_ORIGINS`: `https://savenest.au,https://www.savenest.au`
3.  **Restart**: Always click **RESTART** after making changes.

### Frontend Setup (Public HTML)
The GitHub Action automatically handles this by placing files into `public_html/`. Ensure `Force HTTPS Redirect` is **ON** in the cPanel **Domains** section.

---

## 4. Operational Commands (SSH)
If you need to manually debug or setup the backend via terminal:

*   **Access the App Folder:** `cd ~/savenest_backend`
*   **Activate VirtualEnv:** `source ~/virtualenv/savenest_backend/3.9/bin/activate`
*   **Install Requirements:** `pip install -r requirements.txt`
*   **Check Processes:** `ps aux | grep python`
*   **Restart App:** `touch tmp/restart.txt` (Passenger standard for restarting apps)

---

## 5. Daily Operational Monitoring
To ensure SaveNest is running smoothly, perform these checks:

1.  **Health Check:** Visit `https://savenest.au/api/` daily. If it doesn't return `{"status": "ok"}`, the backend is down.
2.  **SSL Status:** Ensure the padlock icon is present on the browser.
3.  **Error Logs:**
    *   Check `~/savenest_backend/stderr.log` for Python crashes.
    *   Check `~/public_html/error_log` for web server issues.
4.  **HubSpot Integration:** Periodically verify that uploaded files are appearing in the `savenest_bills` folder in your HubSpot File Manager.

---

## 6. Production Deployment Checklist (Step-by-Step)
1.  **Code Change:** Update code locally.
2.  **Push:** `git push origin main`.
3.  **GitHub Action:** Watch the **Actions** tab in GitHub to ensure the build succeeds.
4.  **Backend Sync:** If `requirements.txt` changed, the GitHub Action will automatically update the server environment.
5.  **Verify:** Visit the website and perform a test file upload to confirm the end-to-end flow is working.
