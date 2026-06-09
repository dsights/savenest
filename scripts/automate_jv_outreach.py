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
            print(f"Successfully sent JV pitch to {to_email}")
        else:
            print(f"Error sending to {to_email}: {stderr.decode()}")
    except Exception as e:
        print(f"Failed to send email to {to_email}: {e}")

agencies = [
    {"name": "Ray White NSW", "email": "corporate.nsw@raywhite.com"},
    {"name": "Ray White QLD", "email": "corporate.qld@raywhite.com"},
    {"name": "Ray White VIC", "email": "corporate.vic@raywhite.com"},
    {"name": "Ray White WA", "email": "corporate.wa@raywhite.com"},
    {"name": "Ray White SA", "email": "corporate.sa@raywhite.com"},
    {"name": "LJ Hooker Corporate", "email": "assistinfo@ljhooker.com"},
    {"name": "Raine & Horne", "email": "reception@rh.com.au"},
    {"name": "Harcourts Melbourne", "email": "admin@melbourneharcourts.com.au"},
    {"name": "McGrath Estate Agents", "email": "info@mcgrath.com.au"},
    {"name": "Shelter Real Estate", "email": "hello@shelterrealestate.com.au"}
]

jv_pitch_template = """Hi {name} Team,

I'm reaching out from SaveNest (savenest.au). We provide specialized energy auditing and utility optimization for Australian homeowners.

We are looking to partner with premium real estate agencies to offer a "Free Home Energy Audit" as a value-add service for your new buyers and sellers. 

The benefit for your agency:
1. High-value gift for your clients (helps with post-sale satisfaction).
2. We pay a $500 referral fee for every client who chooses to upgrade to solar through our network.

It's a zero-cost way to add value to your listings and create a new revenue stream for the agency.

Are you open to a 5-minute chat with our partnership manager to see how we can pilot this with your offices?

Best regards,

SaveNest Partnerships Team
savenest.au
---
To opt-out of future partnerships, reply with 'Unsubscribe'.
SaveNest Operations | Sydney, NSW, Australia
"""

if __name__ == "__main__":
    for agency in agencies:
        subject = "Strategic Partnership Proposal: Value-Add for New Homeowners"
        body = jv_pitch_template.format(name=agency['name'])
        send_email(agency['email'], subject, body)
        time.sleep(3) # Respectful delay
