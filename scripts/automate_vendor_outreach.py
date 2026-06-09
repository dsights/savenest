import subprocess
import time
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_email(to_email, subject, body_plain, body_html):
    msg = MIMEMultipart("alternative")
    msg['From'] = '"SaveNest" <contact@savenest.au>'
    msg['To'] = to_email
    msg['Bcc'] = "savenest.au@gmail.com"
    msg['Subject'] = subject
    
    msg.attach(MIMEText(body_plain, 'plain'))
    msg.attach(MIMEText(body_html, 'html'))

    try:
        process = subprocess.Popen(['msmtp', '-t'], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        _, stderr = process.communicate(msg.as_bytes())
        if process.returncode == 0:
            print(f"Successfully sent branded email to {to_email}")
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

def get_html_template(name, content_html):
    return f"""
    <html>
    <body style="font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #333; line-height: 1.6;">
        <div style="max-width: 600px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden;">
            <div style="background-color: #27ae60; padding: 20px; text-align: center;">
                <h1 style="color: #ffffff; margin: 0; font-size: 24px;">SaveNest™</h1>
                <p style="color: #e8f8f5; margin: 5px 0 0 0; font-size: 14px;">Australia's Premium Utility Comparison Network</p>
            </div>
            <div style="padding: 30px;">
                {content_html}
                
                <div style="margin-top: 40px; border-top: 1px solid #eee; padding-top: 20px;">
                    <table style="width: 100%;">
                        <tr>
                            <td style="width: 70px;">
                                <div style="width: 60px; height: 60px; background-color: #27ae60; border-radius: 50%; text-align: center; line-height: 60px; color: white; font-weight: bold; font-size: 20px;">SN</div>
                            </td>
                            <td>
                                <strong style="font-size: 16px; color: #2c3e50;">SaveNest Operations</strong><br>
                                <span style="font-size: 14px; color: #7f8c8d;">Partnerships & Vendor Relations</span><br>
                                <a href="tel:0423265518" style="color: #2980b9; text-decoration: none; font-size: 14px;">0423 265 518</a> | <a href="https://savenest.au" style="color: #2980b9; text-decoration: none; font-size: 14px;">savenest.au</a>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div style="background-color: #f9f9f9; padding: 15px; text-align: center; font-size: 12px; color: #95a5a6; border-top: 1px solid #eee;">
                <p style="margin: 0;">SaveNest | Level 13, 135 King St, Sydney NSW 2000</p>
                <p style="margin: 5px 0 0 0;">You are receiving this as a registered Australian business. To opt-out, reply 'Unsubscribe'.</p>
            </div>
        </div>
    </body>
    </html>
    """

if __name__ == "__main__":
    for vendor in vendors:
        subject = f"Strategic Lead Partnership: SaveNest x {vendor['name']}"
        
        body_plain = f"Hi {vendor['name']} Team,\n\nI run SaveNest (savenest.au), a local lead generation platform for high-intent solar customers in Australia.\n\nWe are currently generating organic leads and are looking for a reliable installation partner to pass them to.\n\nOur offer is zero-risk: We provide leads upfront and only ask for a commission on closed installs.\n\nCan you handle an extra 5-10 installs per month?\n\nBest regards,\nSaveNest Team\n0423 265 518\nsavenest.au"
        
        content_html = f"""
        <p>Hi <strong>{vendor['name']} Team</strong>,</p>
        <p>I'm reaching out from <strong>SaveNest</strong> (savenest.au). We provide specialized energy auditing and utility optimization for homeowners across Australia.</p>
        <p>We are currently seeing a surge in organic solar enquiries and are looking for a Tier-1 installation partner to fulfill these ready-to-buy leads.</p>
        <p><strong>The SaveNest Advantage:</strong></p>
        <ul>
            <li><strong>Zero Upfront Cost:</strong> You only pay a commission when the system is successfully installed.</li>
            <li><strong>High-Intent Leads:</strong> Every lead has undergone a basic utility audit by our team.</li>
            <li><strong>Exclusive Access:</strong> We prioritize quality over quantity, partnering with only a few select vendors.</li>
        </ul>
        <p>Can your team handle an additional <strong>5-10 installs per month</strong> in your current service areas?</p>
        <p>If you're open to a brief chat, feel free to call us directly on <strong>0423 265 518</strong>.</p>
        """
        
        body_html = get_html_template(vendor['name'], content_html)
        send_email(vendor['email'], subject, body_plain, body_html)
        time.sleep(5)
