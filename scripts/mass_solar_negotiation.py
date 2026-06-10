import subprocess
import time
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# This script performs mass outreach to Australian Solar Providers
# It mandates a 20% commission and requests their lowest 'Base Unit Price'

def send_negotiation_email(to_email, vendor_name):
    subject = f"Urgent Partnership Negotiation: SaveNest x {vendor_name} (20% Commission Model)"
    
    body_plain = f"""Hi {vendor_name} Team,

I run SaveNest (savenest.au), a national energy audit and solar lead generation platform.

We are currently onboarding fulfillment partners for our Q3/Q4 organic surge. We provide pre-audited, high-intent leads that have already undergone a basic savings calculation on our platform.

Our Partnership Terms:
1. Commission: 20% flat commission on the total system price for every successful installation.
2. Transparency: We need your absolute lowest 'Base Unit Price' for a standard 6.6kW and 10kW system (Tier 1 panels/inverter).

We only work with partners who can maintain high installation standards while accepting our commission structure.

Can your team handle an additional 10-20 installs per month under these terms? If yes, please reply with your current base pricing for NSW, VIC, and QLD.

Best regards,
Partnerships Director
SaveNest Australia
savenest.au
0423 265 518"""

    content_html = f"""
    <p>Hi <strong>{vendor_name} Team</strong>,</p>
    <p>I'm the Partnerships Director at <strong>SaveNest</strong> (savenest.au). We operate a national energy auditing engine that generates high-intent solar enquiries from homeowners across Australia.</p>
    <p>We are currently restructuring our vendor network for 2026 and are looking for aggressive partners who want to scale their installation volume.</p>
    
    <div style="background-color: #f9f9f9; padding: 20px; border-left: 4px solid #27ae60; margin: 20px 0;">
        <h3 style="margin-top: 0; color: #2c3e50;">Mandatory Partnership Terms:</h3>
        <ul>
            <li><strong>20% Flat Commission:</strong> SaveNest receives a 20% commission on the final invoice price for every installation.</li>
            <li><strong>Audited Leads:</strong> Every lead is pre-qualified via our AI energy auditor before being passed to you.</li>
            <li><strong>Price Leadership:</strong> We require your most competitive 'Base Unit Price' to ensure our users get the best deals in the market.</li>
        </ul>
    </div>

    <p>Can your team handle an additional <strong>10-20 installs per month</strong> under this 20% commission structure?</p>
    <p>If you are interested, please reply to this email with your current <strong>Base Unit Price for 6.6kW and 10kW systems</strong> across your active states.</p>
    
    <p>We are looking to finalize our partner list by the end of this week.</p>
    """
    
    msg = MIMEMultipart("alternative")
    msg['From'] = '"SaveNest Partnerships" <contact@savenest.au>'
    msg['To'] = to_email
    msg['Bcc'] = "savenest.au@gmail.com"
    msg['Subject'] = subject
    
    msg.attach(MIMEText(body_plain, 'plain'))
    msg.attach(MIMEText(get_html_template(vendor_name, content_html), 'html'))

    try:
        process = subprocess.Popen(['msmtp', '-t'], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        _, stderr = process.communicate(msg.as_bytes())
        if process.returncode == 0:
            print(f"✅ Negotiation sent to {vendor_name} ({to_email})")
            return True
        else:
            print(f"❌ Error sending to {vendor_name}: {stderr.decode()}")
            return False
    except Exception as e:
        print(f"❌ Failed to send to {vendor_name}: {e}")
        return False

def get_html_template(name, content_html):
    return f"""
    <html>
    <body style="font-family: Arial, sans-serif; color: #333; line-height: 1.6;">
        <div style="max-width: 600px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden;">
            <div style="background-color: #27ae60; padding: 20px; text-align: center;">
                <h1 style="color: #ffffff; margin: 0;">SaveNest™ Partnerships</h1>
            </div>
            <div style="padding: 30px;">
                {content_html}
                <p>Best regards,<br><strong>SaveNest Australia</strong></p>
            </div>
        </div>
    </body>
    </html>
    """

# Comprehensive 2026 Vendor List (Expanded)
vendors = [
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
    {"name": "Sky Solar", "email": "info@skysolar.com.au"}
]

if __name__ == "__main__":
    print(f"🚀 Starting Mass Solar Negotiation for {len(vendors)} vendors...")
    success_count = 0
    for vendor in vendors:
        if send_negotiation_email(vendor['email'], vendor['name']):
            success_count += 1
        time.sleep(3) # Be polite
    
    print(f"\n✅ Negotiation batch complete. {success_count}/{len(vendors)} emails sent.")
    print("Next Step: Monitor inbox for 'Base Unit Price' quotes and update products.json.")
