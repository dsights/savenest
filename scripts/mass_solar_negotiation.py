import subprocess
import time
import json
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime

# Path Configuration
LOG_FILE = 'logs/outreach_sent_log.json'

def load_sent_log():
    if os.path.exists(LOG_FILE):
        try:
            with open(LOG_FILE, 'r') as f:
                return json.load(f)
        except:
            return []
    return []

def save_to_sent_log(email, vendor_name):
    log = load_sent_log()
    log.append({
        "email": email,
        "name": vendor_name,
        "sent_at": datetime.now().isoformat(),
        "type": "solar_negotiation_20"
    })
    with open(LOG_FILE, 'w') as f:
        json.dump(log, f, indent=2)

def send_negotiation_email(to_email, vendor_name):
    # Skip if already sent
    sent_emails = [item['email'] for item in load_sent_log()]
    if to_email in sent_emails:
        print(f"⏩ Skipping {vendor_name} ({to_email}) - Already in sent log.")
        return False

    subject = f"Strategic Partnership: SaveNest x {vendor_name} (20% Performance Model)"
    
    body_plain = f"""Hi {vendor_name} Team,

I'm the Partnerships Director at SaveNest (savenest.au). We operate a high-intent energy auditing platform that connects Australian homeowners with top-tier solar and electrical installers.

As we scale our organic lead volume for the second half of 2026, we are opening up several fulfillment slots for reliable partners who can handle an additional 10-20 installs per month.

Our Core Partnership Terms:
1. Commission: 20% flat performance fee on the final contract price for every successful installation.
2. Quality Control: Every lead is pre-audited via our proprietary savings calculator, ensuring we only pass you 'ready-to-buy' customers.
3. Market Leadership: We require your most competitive 'Base Unit Price' for standard 6.6kW and 10kW systems to ensure our users get the best value.

Are you positioned to accept additional volume under this 20% commission structure?

If yes, please reply with your current base pricing for your active service areas. We are finalizing our primary partner list this week.

Best regards,
Partnerships Director
SaveNest Australia
savenest.au
0423 265 518"""

    content_html = f"""
    <html>
    <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #333; line-height: 1.6;">
        <div style="max-width: 650px; margin: 0 auto; border: 1px solid #eee; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
            <div style="background-color: #27ae60; padding: 30px; text-align: center; color: white;">
                <h1 style="margin: 0; font-size: 28px; letter-spacing: 1px;">SaveNest™</h1>
                <p style="margin: 5px 0 0 0; opacity: 0.9;">Australia's Premium Utility Intelligence Network</p>
            </div>
            <div style="padding: 40px; background-color: #ffffff;">
                <p style="font-size: 16px;">Hi <strong>{vendor_name} Team</strong>,</p>
                <p>I'm reaching out to discuss a high-volume fulfillment partnership between <strong>SaveNest</strong> and your team.</p>
                <p>We generate pre-qualified solar enquiries from homeowners who have completed a full energy audit on our platform. We are currently looking for <strong>Tier-1 installers and electrical partners</strong> to fulfill an additional 10-20 systems per month.</p>
                
                <div style="background-color: #f8fdf9; padding: 25px; border-left: 5px solid #27ae60; margin: 25px 0; border-radius: 4px;">
                    <h3 style="margin-top: 0; color: #1e8449; font-size: 18px;">2026 Partnership Framework:</h3>
                    <ul style="padding-left: 20px;">
                        <li style="margin-bottom: 10px;"><strong>20% Performance Commission:</strong> A flat 20% fee paid on the final system price upon successful installation.</li>
                        <li style="margin-bottom: 10px;"><strong>Pre-Audited Leads:</strong> Zero time wasted on 'tyre-kickers'. Every lead comes with bill usage data and a verified savings profile.</li>
                        <li style="margin-bottom: 10px;"><strong>Strategic Volume:</strong> We prioritize a small group of active partners to ensure consistent, reliable work flow.</li>
                    </ul>
                </div>

                <p>To move forward, we require your most competitive <strong>Base Unit Price for standard 6.6kW and 10kW systems</strong> (Tier 1 components).</p>
                
                <p>Can your team maintain high installation standards while operating under this volume-based commission structure?</p>
                
                <p style="margin-top: 30px;">Best regards,</p>
                <p><strong>SaveNest Australia</strong><br>
                <span style="color: #7f8c8d; font-size: 14px;">Partnerships & Vendor Relations</span><br>
                <a href="https://savenest.au" style="color: #27ae60; text-decoration: none; font-weight: bold;">savenest.au</a> | 0423 265 518</p>
            </div>
            <div style="background-color: #f9f9f9; padding: 20px; text-align: center; font-size: 12px; color: #bdc3c7; border-top: 1px solid #f0f0f0;">
                <p style="margin: 0;">SaveNest | 5-7 Bando Road, Girraween, NSW 2145</p>
                <p style="margin: 5px 0 0 0;">Commercial Partnership Enquiry. To opt-out of future updates, reply 'Unsubscribe'.</p>
            </div>
        </div>
    </body>
    </html>
    """
    
    msg = MIMEMultipart("alternative")
    msg['From'] = '"SaveNest Partnerships" <contact@savenest.au>'
    msg['To'] = to_email
    msg['Bcc'] = "savenest.au@gmail.com"
    msg['Subject'] = subject
    
    msg.attach(MIMEText(body_plain, 'plain'))
    msg.attach(MIMEText(content_html, 'html'))

    try:
        process = subprocess.Popen(['msmtp', '-t'], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        _, stderr = process.communicate(msg.as_bytes())
        if process.returncode == 0:
            print(f"✅ Negotiation sent to {vendor_name} ({to_email})")
            save_to_sent_log(to_email, vendor_name)
            return True
        else:
            print(f"❌ Error sending to {vendor_name}: {stderr.decode()}")
            return False
    except Exception as e:
        print(f"❌ Failed to send to {vendor_name}: {e}")
        return False

# Hybrid Electrical & Solar Vendors
vendors = [
    # --- Previously Contacted (Will be skipped by log if run before, but included for completeness) ---
    {"name": "Solahart", "email": "solahart@solahart.com.au"},
    {"name": "Solargain", "email": "sg.info@solargain.com.au"},
    {"name": "Energy Matters", "email": "roshan@energymatters.com.au"},
    {"name": "1KOMMA5 Australia", "email": "hello.australia@1komma5.com"},
    {"name": "VoltX Energy", "email": "support@voltxenergy.com.au"},
    {"name": "RESINC Solar", "email": "info@resinc.com.au"},
    {"name": "Arise Solar", "email": "info@arisesolar.com.au"},
    {"name": "Fortune Solar", "email": "info@fortunesolar.com.au"},
    {"name": "RegenPower", "email": "sales@regenpower.com"},
    {"name": "Think Renewable", "email": "customercare@thinkrenewable.com.au"},
    {"name": "Natural Solar", "email": "sales@naturalsolar.com.au"},
    {"name": "Smart Energy Group", "email": "info@smartenergygroup.com.au"},
    {"name": "SAE Group", "email": "sales@saegroup.com.au"},
    {"name": "Sunboost", "email": "info@sunboost.com.au"},
    {"name": "Jet Solar", "email": "info@jetsolar.com.au"},
    {"name": "Brightworks Solar", "email": "info@brightworks.com.au"},
    {"name": "Nexa Solar", "email": "info@nexasolar.com.au"},
    {"name": "Nordon Solar", "email": "info@nordon.com.au"},
    {"name": "Solar My Home", "email": "info@solarmyhome.com.au"},
    {"name": "Goliath Solar", "email": "info@goliathsolar.com.au"},
    {"name": "DQ Electrical", "email": "info@dqelectrical.com.au"},
    {"name": "Perth Solar Warehouse", "email": "info@pswenergy.com.au"},
    {"name": "Koala Solar", "email": "info@koalasolar.com.au"},
    {"name": "3 Phase Solar", "email": "info@3phasesolar.com.au"},
    {"name": "Sky Solar", "email": "info@skysolar.com.au"},

    # --- New Electrical / Hybrid Partners ---
    {"name": "ECOlectrical", "email": "sales@ecolectrical.com.au"},
    {"name": "Aztech Solar", "email": "info@aztechsolar.com.au"},
    {"name": "Concept Electrical & Solar", "email": "info@conceptelectrical.com.au"},
    {"name": "Aus Solar Energy Group", "email": "info@aussolarenergygroup.com.au"},
    {"name": "3P Solar", "email": "solutions@3psolar.com.au"},
    {"name": "GreenTech Solar Australia", "email": "info@greentechsolar.com.au"},
    {"name": "Zing Solar Vic", "email": "info@zingsolar.com.au"},
    {"name": "365 Solar Australia", "email": "info@365solar.com.au"},
    {"name": "Best Value Solar", "email": "info@bestvaluesolar.com.au"},
    {"name": "Victorian Solar & Power", "email": "info@victoriansolar.com"},
    {"name": "3D Energy", "email": "sales@3denergy.com.au"},
    {"name": "Sparkrite Electrical", "email": "spark_rite@bigpond.com"},
    {"name": "AB Solar & Electrical", "email": "absolarandelectrical@gmail.com"},
    {"name": "APS Wholesale", "email": "Peter@australianpremiumsolar.com.au"},
    {"name": "TCB Electrical Services", "email": "contact@tcbelectricalservices.com.au"},
    {"name": "Adelaide Solar Repairs", "email": "info@adelaidesolarrepairs.com.au"},
    {"name": "Solar Repair Adelaide", "email": "info@solarrepairadelaide.com.au"},
    {"name": "Adelaide Solar & Electrical", "email": "info@adelaidesolarandelectrical.com.au"},
    {"name": "ARK Air & Solar", "email": "hi@arkwa.au"},
    {"name": "Quinncroft Electrical", "email": "accounts@quinncroftelectrical.com"},
    {"name": "Solar 365", "email": "info@solar365.net.au"}
]

if __name__ == "__main__":
    print(f"🚀 Starting Mass Solar & Electrical Negotiation for {len(vendors)} potential partners...")
    success_count = 0
    skip_count = 0
    
    for vendor in vendors:
        res = send_negotiation_email(vendor['email'], vendor['name'])
        if res:
            success_count += 1
            time.sleep(5) # Delay for high-quality delivery
        else:
            skip_count += 1
    
    print(f"\n✅ Batch complete.")
    print(f"   - Successfully Sent: {success_count}")
    print(f"   - Skipped (Duplicates): {skip_count}")
    print(f"Next Step: Monitor replies and verify 20% commission acceptance.")
