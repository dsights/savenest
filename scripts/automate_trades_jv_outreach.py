import subprocess
import time
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_email(to_email, subject, body):
    msg = MIMEMultipart()
    msg['From'] = '"SaveNest" <contact@savenest.au>'
    msg['To'] = to_email
    msg['Bcc'] = "savenest.au@gmail.com"
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    try:
        process = subprocess.Popen(['msmtp', '-t'], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        _, stderr = process.communicate(msg.as_bytes())
        if process.returncode == 0:
            print(f"Successfully sent Trades JV pitch to {to_email}")
        else:
            print(f"Error sending to {to_email}: {stderr.decode()}")
    except Exception as e:
        print(f"Failed to send email to {to_email}: {e}")

trades_businesses = [
    {"name": "HVAC Australia", "email": "info@hvac.com.au"},
    {"name": "ecoHVAC", "email": "sales@ecohvac.com.au"},
    {"name": "A.G. Coombs", "email": "awoodley@agcoombs.com.au"},
    {"name": "Grosvenor Engineering Group", "email": "inductions@gegroup.com.au"},
    {"name": "Australian HVAC Services", "email": "reception@hvacservices.com.au"},
    {"name": "Sydmech", "email": "peter@sydmech.com.au"},
    {"name": "Tradecom Group", "email": "services@tradecomgroup.com"},
    {"name": "Tomkat Roofing", "email": "info@tomkatroofing.com.au"},
    {"name": "Roof Group", "email": "info@roofgroup.com.au"},
    {"name": "Roofrite", "email": "clientservices@roofrite.com.au"},
    {"name": "Aussie Roof Co", "email": "sales@aussieroofco.com.au"},
    {"name": "The Roofing Company AU", "email": "info@roofing-company.com.au"}
]

trades_pitch_template = """Hi {name} Team,

I'm reaching out from SaveNest (savenest.au). We run a solar brokerage and energy auditing platform.

Since your team is already on roofs or handling energy-heavy HVAC systems all day, you are perfectly positioned to identify customers who are overpaying for power.

We want to pay you for the names you're already seeing:
1. If a customer needs solar, pass the name and number to us.
2. We handle the entire sales process, design, and installation handoff.
3. We pay you a $1,000 "Spotter's Fee" for every successful install.

It's a zero-effort way to add $5k - $10k to your monthly profit just by passing us the leads you're already standing on.

Are you open to a quick 2-minute chat about how we can set this up for your technicians?

Best regards,

SaveNest Partnerships Team
savenest.au
---
To opt-out of future partnerships, reply with 'Unsubscribe'.
SaveNest Operations | Girraween, NSW, Australia
"""

if __name__ == "__main__":
    for business in trades_businesses:
        subject = "Referral Partnership: $1,000 per Solar Spotter Lead"
        body = trades_pitch_template.format(name=business['name'])
        send_email(business['email'], subject, body)
        time.sleep(3)
