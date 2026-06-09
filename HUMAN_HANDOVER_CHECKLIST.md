# 🧍 SaveNest Human Handover Checklist

Complete these **One-Off** tasks to enable 100% AI-driven business operations. Once these gaps are closed, the AI can run the "Strike" commands autonomously.

## 1. Email Deliverability (Critical for Inboxes)
*   [ ] **Action:** Log into FastComet cPanel -> **Email Deliverability**.
*   [ ] **Validation:** Ensure 'savenest.au' status is Green/Valid. If not, click 'Manage' and 'Install Suggested Records' (SPF/DKIM).
*   [ ] **Why:** This ensures our vendor outreach doesn't end up in spam.

## 2. Social Media Hub Configuration
*   [ ] **Action:** Open `marketing/social_strike_config.json`.
*   [ ] **Action:** Replace placeholder URLs with the actual URLs of the 40+ Facebook groups you joined.
*   [ ] **Action:** Run `pip install pyperclip` on your local machine.
*   [ ] **Why:** This enables the "One-Button Organic Strike" where the AI copies content and opens your groups for you.

## 3. CRM & Vendor Management
*   [ ] **Action:** Log into [HubSpot](https://app.hubspot.com/).
*   [ ] **Note:** The AI now has automated read/write access via \`scripts/hubspot_manager.py\`.
*   [ ] **AI Task:** I will automatically sync with HubSpot to identify which vendors are active. You just need to ensure the token in your \`.env\` is correct.
*   [ ] **Why:** This removes the need for you to manually tell the AI who our partners are.

## 4. Daily Operational Flow (Your 10-Min Routine)
*   [ ] **Morning:** Run `python3 scripts/organic_strike_launcher.py` (5 mins to Paste/Post in groups).
*   [ ] **Evening:** Check your Facebook DMs for "INFO" or "ME" comments.
*   [ ] **Handover:** Paste any Lead details (Name, Phone, Address) here and tell the AI: "Day 6 Strike - Handoff this lead."

---
## ✅ Final Handover Status
Once all boxes are checked, tell the AI: **"System Primed. Take the Lead."**
