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
            print(f"Successfully sent email to {to_email}")
        else:
            print(f"Error sending to {to_email}: {stderr.decode()}")
    except Exception as e:
        print(f"Failed to send email to {to_email}: {e}")

vendors = [
    {"name": "Natural Solar", "email": "sales@naturalsolar.com.au"},
    {"name": "Smart Energy", "email": "info@smartenergygroup.com.au"},
    {"name": "SAE Group", "email": "sales@saegroup.com.au"},
    {"name": "Sunboost", "email": "info@sunboost.com.au"},
    {"name": "Solar Link Australia", "email": "info@solarlinkaustralia.com.au"}
]

pitch_template = """Hi {name} Team,

I run SaveNest (savenest.au), a local lead generation platform for high-intent solar customers in Australia.

We are currently generating organic leads and are looking for a reliable installation partner to pass them to. 

Our offer is zero-risk for you:
1. We provide the leads upfront.
2. We only ask for a commission when you successfully close and install the system.

Can you handle an extra 5-10 installs per month in your service areas?

Best regards,

SaveNest Business Development
savenest.au
"""

if __name__ == "__main__":
    for vendor in vendors:
        subject = f"Zero-Risk Lead Partnership for {vendor['name']}"
        body = pitch_template.format(name=vendor['name'])
        send_email(vendor['email'], subject, body)
        time.sleep(2) # Avoid spamming
