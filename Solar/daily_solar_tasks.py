import os
import sys
import datetime
import subprocess

# --- CONFIGURATION ---
SOLAR_DIR = os.path.dirname(os.path.abspath(__file__))
START_DATE_FILE = os.path.join(SOLAR_DIR, 'start_date.txt')
ADMIN_EMAIL_FILE = os.path.join(SOLAR_DIR, 'admin_email.txt')
EMAIL_SCRIPT = os.path.abspath(os.path.join(SOLAR_DIR, '..', 'email-config', 'send_single_email.sh'))
TEMP_HTML_FILE = os.path.join(SOLAR_DIR, 'temp_daily_email.html')

# --- 90 DAY TASK DICTIONARY ---
TASKS = {
    1: [
        "Register Business Name (e.g., SaveNest Solar) and ABN/ACN.",
        "Set up professional email (e.g., hello@savenest.au).",
        "Open a dedicated business bank account."
    ],
    2: [
        "Set up your CRM (HubSpot free tier or GoHighLevel).",
        "Create standard Terms & Conditions for lead-sharing agreements.",
        "Set up your Meta (Facebook/Instagram) Business Manager and Google Ads account."
    ],
    3: [
        "Build a list of the Top 20 CEC Accredited Solar Installers in your target state (NSW/QLD/VIC).",
        "Find their direct phone numbers and Director/Sales Manager names via LinkedIn or their websites."
    ],
    4: [
        "Draft your cold call script and email templates to pitch installers.",
        "Pitch: 'We generate highly qualified solar leads and want to pass you 50 installs a month. Are you taking new volume?'",
        "Send initial outreach emails to the Top 20 list."
    ],
    5: [
        "Cold Call Day: Call the 20 installers you emailed yesterday.",
        "Goal: Book 3-5 Zoom meetings for next week to discuss Service Level Agreements (SLAs)."
    ],
    6: [
        "Finalize the SaveNest Solar Landing Page (lib/features/solar/screens/solar_landing_screen.dart).",
        "Connect the lead capture form to your CRM via Zapier or a direct API integration."
    ],
    7: [
        "Rest & Review Week 1.",
        "Ensure all tech (domain, email, CRM, landing page) is fully functional and tested with a dummy lead."
    ],
    8: [
        "Host installer meetings (Zoom/In-person).",
        "Negotiate your margin: Aim for 15-25% per closed deal or $100-$300 per qualified lead."
    ],
    9: [
        "Follow up with installers and sign at least 1-2 SLAs (Service Level Agreements).",
        "Get their ideal customer profile (e.g., single-story, tin roof, $500+ bill)."
    ],
    10: [
        "Create Facebook Ad creatives (Image/Video). Angle: 'Are you eligible for the 2026 State Solar Rebates?'",
        "Draft 3 variations of Ad Copy."
    ],
    11: [
        "Create Google Search Ads. Keywords: 'solar panels [city]', 'best solar installer near me', 'solar quotes'.",
        "Set daily budget ($50-$100 to start)."
    ],
    12: [
        "Set up an automated Email/SMS Drip Campaign in your CRM for leads that submit the form.",
        "Email 1: 'We received your details. Calculating savings now.'"
    ],
    13: [
        "Launch Ads! Turn on Meta and Google campaigns.",
        "Keep your phone off silent. You must call leads within 5 minutes of them submitting the form."
    ],
    14: [
        "Monitor Ad spend and lead cost.",
        "Call leads, pre-qualify them based on installer requirements, and pass the hot leads to your partners."
    ],
    # Weeks 3 & 4: Optimization
    15: ["Review Ad metrics. Kill ads with Cost Per Lead (CPL) > $50.", "Follow up with installers on the leads sent this weekend."],
    16: ["Publish SEO Blog: 'Solar Rebates NSW 2026 Explained' on the website.", "Call all new leads within 5 minutes."],
    17: ["Double the budget on the winning Facebook ad.", "Follow up on old leads that didn't answer yesterday."],
    18: ["If installers are slow to call leads, implement a 'warm handover' (call the lead, conference in the installer)."],
    19: ["End of week reconciliation: How many leads generated? How many quoted by partners? How many sold?"],
    20: ["Record a quick video on your phone explaining the 'Lazy Tax' on electricity to use as a new ad creative."],
    21: ["Review week. Adjust ad targeting if leads are low quality (e.g., renters instead of homeowners)."],
    22: ["Launch the video ad recorded on Day 20.", "Call new leads."],
    23: ["Check in with installation partners. Ask for feedback on lead quality. Adjust your qualification questions if needed."],
    24: ["Publish SEO Blog: 'How much do 6.6kW Solar Panels cost in 2026?'"],
    25: ["Analyze Google Ads search terms. Add negative keywords (like 'free', 'DIY', 'jobs') to stop wasting money."],
    26: ["Follow up aggressively on all quoted deals. Help the installer close the sale."],
    27: ["If you have closed deals, send your first invoice for referral fees/commissions to your installer partners."],
    28: ["Rest & Review Month 1. Goal check: Are we on track for the daily lead target?"],
    # Month 2: Scaling
    30: ["Start Month 2 push. Goal: 5 closed sales per day across all partners. Scale ad budget by 20%."],
    35: ["Interview a Virtual Assistant (VA) to handle the initial 5-minute qualifying calls so you can focus on sales/partnerships."],
    40: ["Train your VA on the script and CRM."],
    45: ["Expand ad targeting to a new state if current partners have capacity, or source new partners in that state."],
    50: ["Implement an SMS reactivation campaign for leads older than 14 days who didn't buy."],
    60: ["End of Month 2 Review. Calculate exact Cost per Acquisition (CPA). If profitable, uncap ad spend."],
    # Month 3: $1M Sprint
    70: ["Launch 'Refer a Friend' campaign to Month 1 customers. Offer $500 cash back for successful referrals."],
    80: ["Audit installer closing rates. Drop partners closing < 15% and replace them."],
    90: ["Final sprint review. If volume is high enough, begin the application process for your own CEC Retailer status."]
}

# Fill in the blanks with a default task
for i in range(1, 91):
    if i not in TASKS:
        TASKS[i] = [
            "Monitor Ad Spend and Lead Flow.",
            "Call all new leads within 5 minutes.",
            "Follow up with installation partners on pipeline.",
            "Close deals."
        ]

def get_admin_email():
    if not os.path.exists(ADMIN_EMAIL_FILE):
        print(f"Error: Admin email file not found at {ADMIN_EMAIL_FILE}.")
        print("Please create it and put your email address inside.")
        sys.exit(1)
    with open(ADMIN_EMAIL_FILE, 'r') as f:
        email = f.read().strip()
    if not email:
        print("Error: Admin email file is empty.")
        sys.exit(1)
    return email

def get_current_day():
    today = datetime.date.today()
    if not os.path.exists(START_DATE_FILE):
        with open(START_DATE_FILE, 'w') as f:
            f.write(today.isoformat())
        return 1
    
    with open(START_DATE_FILE, 'r') as f:
        date_str = f.read().strip()
        
    try:
        start_date = datetime.date.fromisoformat(date_str)
    except ValueError:
        print("Error: Invalid date format in start_date.txt. Use YYYY-MM-DD.")
        sys.exit(1)
        
    delta = today - start_date
    return delta.days + 1

def generate_html_email(day, tasks):
    html = f"""
    <html>
    <body style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h2 style="color: #1A365D;">SaveNest Solar: $1M Execution Plan</h2>
        <div style="background-color: #f4f7f6; padding: 15px; border-left: 4px solid #10B981; margin-bottom: 20px;">
            <h3 style="margin-top: 0;">Day {day} of 90</h3>
            <p style="margin-bottom: 0;">Here are your critical execution steps for today. Focus only on revenue-generating activities.</p>
        </div>
        <h3>Today's Checklist:</h3>
        <ul>
    """
    for task in tasks:
        html += f"<li style='margin-bottom: 10px; font-size: 16px;'>{task}</li>\n"
        
    html += """
        </ul>
        <hr style="border: 0; border-top: 1px solid #eee; margin: 30px 0;">
        <p style="font-size: 12px; color: #888;">This is an automated daily dispatch from your SaveNest CLI Agent.</p>
    </body>
    </html>
    """
    
    with open(TEMP_HTML_FILE, 'w') as f:
        f.write(html)

def send_email(day, admin_email):
    subject = f"SaveNest Solar: Day {day} Action Plan"
    
    if not os.path.exists(EMAIL_SCRIPT):
        print(f"Error: Email script not found at {EMAIL_SCRIPT}.")
        sys.exit(1)
        
    try:
        result = subprocess.run(
            [EMAIL_SCRIPT, subject, TEMP_HTML_FILE, admin_email],
            check=True,
            capture_output=True,
            text=True
        )
        print("Email sent successfully!")
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print("Failed to send email.")
        print("Error Output:", e.stderr)
    finally:
        if os.path.exists(TEMP_HTML_FILE):
            os.remove(TEMP_HTML_FILE)

def main():
    admin_email = get_admin_email()
    day = get_current_day()
    
    if day > 90:
        tasks = [
            "You have completed the 90-Day Sprint!",
            "Review your quarterly financials.",
            "Begin the CEC Retailer Accreditation process to increase margins.",
            "Hire full-time sales reps to scale."
        ]
    else:
        tasks = TASKS.get(day, TASKS[1]) # fallback to Day 1 if something weird happens
        
    print(f"Executing for Day {day}...")
    generate_html_email(day, tasks)
    send_email(day, admin_email)

if __name__ == "__main__":
    main()
