import subprocess
import argparse
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_handoff_email(vendor_email, lead_data):
    msg = MIMEMultipart()
    msg['From'] = '"SaveNest" <contact@savenest.au>'
    msg['To'] = vendor_email
    msg['Bcc'] = "savenest.au@gmail.com"
    msg['Subject'] = f"New High-Intent Solar Lead: {lead_data['name']}"
    
    body = f"""Hi Team,

You have a new high-intent solar lead from SaveNest.

LEAD DETAILS:
Name: {lead_data['name']}
Phone: {lead_data['phone']}
Email: {lead_data.get('email', 'N/A')}
Address: {lead_data['address']}
Average Quarterly Bill: {lead_data.get('bill', 'N/A')}
Notes: {lead_data.get('notes', 'N/A')}

Please contact this lead within the next 2 hours for the best conversion rate. Let us know once the site visit is booked.

Best regards,

SaveNest Operations
savenest.au
"""
    msg.attach(MIMEText(body, 'plain'))

    try:
        process = subprocess.Popen(['msmtp', '-t'], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        _, stderr = process.communicate(msg.as_bytes())
        if process.returncode == 0:
            print(f"✅ Lead {lead_data['name']} successfully handed off to {vendor_email}")
        else:
            print(f"❌ Error handing off to {vendor_email}: {stderr.decode()}")
    except Exception as e:
        print(f"❌ Failed to hand off lead: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="SaveNest Lead Handoff Utility")
    parser.add_argument("--vendor", required=True, help="Vendor email address")
    parser.add_argument("--name", required=True, help="Lead name")
    parser.add_argument("--phone", required=True, help="Lead phone number")
    parser.add_argument("--address", required=True, help="Lead address")
    parser.add_argument("--bill", help="Average quarterly bill")
    parser.add_argument("--notes", help="Additional notes")
    
    args = parser.parse_args()
    
    lead = {
        "name": args.name,
        "phone": args.phone,
        "address": args.address,
        "bill": args.bill,
        "notes": args.notes
    }
    
    send_handoff_email(args.vendor, lead)
