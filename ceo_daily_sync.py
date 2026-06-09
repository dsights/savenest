#!/usr/bin/env python3
import json
import argparse
import sys
import os
import subprocess
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import smtplib

SEO_STATE_FILE = '.seo_state.json'
TARGET_PLAN_FILE = '.target_plan.json'

def load_json(filepath):
    if not os.path.exists(filepath):
        print(f"Error: {filepath} not found. Ensure you are in the correct directory.")
        sys.exit(1)
    with open(filepath, 'r') as f:
        return json.load(f)

def save_json(filepath, data):
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)

def log_metric(metric, value):
    plan_data = load_json(TARGET_PLAN_FILE)
    if 'metrics' not in plan_data:
        plan_data['metrics'] = {
            "leads_generated": 0, "sales_closed": 0, 
            "organic_posts": 0, "jv_partners_signed": 0,
            "energy_switches": 0, "internet_switches": 0, "finance_referrals": 0
        }
    
    plan_data['metrics'][metric] = plan_data['metrics'].get(metric, 0) + value
    save_json(TARGET_PLAN_FILE, plan_data)
    print(f"✅ Logged {value} to {metric}. Total is now: {plan_data['metrics'][metric]}")

def log_revenue(amount):
    plan_data = load_json(TARGET_PLAN_FILE)
    plan_data['current_revenue'] = plan_data.get('current_revenue', 0) + amount
    save_json(TARGET_PLAN_FILE, plan_data)
    print(f"💸 Added ${amount:,.2f} to revenue. Total MRR is now: ${plan_data['current_revenue']:,.2f}")

def generate_business_advice(plan_data):
    metrics = plan_data.get('metrics', {})
    solar = metrics.get('leads_generated', 0)
    energy = metrics.get('energy_switches', 0)
    internet = metrics.get('internet_switches', 0)
    finance = metrics.get('finance_referrals', 0)

    advice = []
    advice.append("💡 <b>Cross-Selling Insight:</b> Every solar customer is naturally an energy customer looking to save. Pitch 'Compare Energy Providers' aggressively to your solar leads.")
    
    if energy == 0 and internet == 0:
        advice.append("💡 <b>Diversification Tip:</b> Non-solar revenue is currently sitting at 0. Post your Broadband and Electricity comparison links on local community boards this week.")
    
    if finance < 5:
        advice.append("💡 <b>High Margin Alert:</b> Credit cards and finance segments pay high affiliate commissions. Write a 'Best Credit Cards for New Homeowners' post and funnel your JV real-estate traffic to it.")
        
    if solar > 0 and energy == 0:
        advice.append("💡 <b>Missed Opportunity:</b> You have solar leads but no energy switches. Set up an automated email sequence to offer electricity plan checks 30 days after a solar install.")
        
    return "".join(f"<li style='margin-bottom: 8px;'>{a}</li>" for a in advice)

def send_email(subject, html_content, to_email="ceodaily2026@gmail.com"):
    msg = MIMEMultipart("alternative")
    msg['Subject'] = subject
    msg['To'] = to_email
    msg['From'] = '"SaveNest" <contact@savenest.au>'
    
    part = MIMEText(html_content, 'html')
    msg.attach(part)
    
    try:
        process = subprocess.Popen(['msmtp', '-t'], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        _, stderr = process.communicate(msg.as_bytes())
        if process.returncode == 0:
            print("Successfully sent briefing email via msmtp.")
            return
    except FileNotFoundError:
        pass

    smtp_server = os.environ.get("SMTP_SERVER", "localhost")
    smtp_port = int(os.environ.get("SMTP_PORT", 25))
    smtp_user = os.environ.get("SMTP_USER", "")
    smtp_pass = os.environ.get("SMTP_PASS", "")

    try:
        server = smtplib.SMTP(smtp_server, smtp_port)
        if smtp_user and smtp_pass:
            server.starttls()
            server.login(smtp_user, smtp_pass)
        server.sendmail(msg['From'], [msg['To']], msg.as_string())
        server.quit()
        print(f"Successfully sent briefing email via smtplib to {to_email}.")
    except Exception as e:
        print(f"Failed to send email via smtplib: {e}")

def generate_html_email(day_data, plan_data):
    current_rev = plan_data.get('current_revenue', 0)
    target_rev = plan_data.get('target_revenue_mrr', 10000)
    metrics = plan_data.get('metrics', {})
    
    leads = metrics.get('leads_generated', 0)
    sales = metrics.get('sales_closed', 0)
    energy = metrics.get('energy_switches', 0)
    internet = metrics.get('internet_switches', 0)
    finance = metrics.get('finance_referrals', 0)
    organic_posts = metrics.get('organic_posts', 0)
    jv_partners = metrics.get('jv_partners_signed', 0)
    target_jv = metrics.get('target_jv_partners', 15)
    
    progress_pct = min((current_rev / target_rev) * 100 if target_rev else 0, 100)
    jv_pct = min((jv_partners / target_jv) * 100 if target_jv else 0, 100)
    
    current_week_idx = min((day_data['day'] - 1) // 7, len(plan_data.get('milestones', [])) - 1)
    current_milestone = plan_data['milestones'][current_week_idx] if plan_data.get('milestones') else {"focus": "N/A", "actions": []}

    sop_steps = "".join([f"<li>{step.strip()}</li>" for step in day_data['human_sop'].split('\n') if step.strip()])
    advice_html = generate_business_advice(plan_data)
    
    copy_paste_html = ""
    if 'copy_paste_template' in day_data and day_data['copy_paste_template']:
        copy_paste_html = f"""
            <!-- Copy Paste Template -->
            <div class="section">
              <h2>📋 Your Copy & Paste Template</h2>
              <div class="template-box">
                {day_data['copy_paste_template']}
              </div>
            </div>
        """

    html = f"""
    <html>
      <head>
        <style>
          body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #2c3e50; background-color: #f4f6f7; padding: 20px; }}
          .container {{ max-width: 650px; margin: 0 auto; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 16px rgba(0,0,0,0.1); }}
          .header {{ background: linear-gradient(135deg, #27ae60, #2ecc71); color: #fff; padding: 25px; text-align: center; }}
          .header h1 {{ margin: 0; font-size: 26px; text-transform: uppercase; letter-spacing: 1px; }}
          .header p {{ margin: 10px 0 0 0; font-size: 16px; opacity: 0.9; }}
          .content {{ padding: 25px; }}
          .section {{ margin-bottom: 30px; }}
          .section h2 {{ color: #27ae60; border-bottom: 2px solid #a9dfbf; padding-bottom: 8px; font-size: 20px; margin-top: 0; }}
          
          .metrics-grid {{ display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 20px; }}
          .metric-card {{ background: #e8f8f5; padding: 15px; border-radius: 8px; text-align: center; border: 1px solid #d4efdf; }}
          .metric-value {{ font-size: 24px; font-weight: bold; color: #27ae60; margin: 5px 0; }}
          .metric-title {{ font-size: 12px; text-transform: uppercase; color: #7f8c8d; font-weight: bold; }}
          
          .multi-segment-grid {{ display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; margin-bottom: 20px; text-align: center; }}
          .segment-card {{ background: #fdf2e9; padding: 10px; border-radius: 6px; border: 1px solid #fae5d3; }}
          .segment-value {{ font-size: 18px; font-weight: bold; color: #d35400; }}
          .segment-title {{ font-size: 11px; text-transform: uppercase; color: #7f8c8d; }}
          
          .progress-bar-bg {{ background-color: #ecf0f1; border-radius: 20px; width: 100%; height: 12px; overflow: hidden; margin: 10px 0; }}
          .progress-bar-fill {{ background-color: #27ae60; height: 100%; width: {progress_pct}%; transition: width 0.5s; }}
          .progress-bar-fill.blue {{ background-color: #3498db; width: {jv_pct}%; }}
          
          .task-box {{ background-color: #ffffff; padding: 20px; border-left: 5px solid #2980b9; border-radius: 6px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); margin-bottom: 15px; }}
          .advice-box {{ background-color: #f4f6f6; padding: 15px; border-left: 5px solid #8e44ad; border-radius: 6px; font-size: 14px; color: #34495e; }}
          .template-box {{ background-color: #fef9e7; padding: 20px; border-left: 5px solid #f1c40f; border-radius: 6px; font-family: monospace; font-size: 15px; white-space: pre-wrap; box-shadow: 0 2px 5px rgba(0,0,0,0.05); color: #333; }}
          
          ul {{ padding-left: 20px; margin: 10px 0; }}
          li {{ margin-bottom: 10px; line-height: 1.5; }}
          .footer {{ text-align: center; font-size: 12px; color: #95a5a6; padding: 20px; background-color: #f8f9fa; border-top: 1px solid #eee; }}
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Savenest Multi-Segment Sprint</h1>
            <p>Day {day_data['day']} of 30: {day_data['title']}</p>
          </div>
          
          <div class="content">
            <!-- Dashboard Metrics -->
            <div class="section">
              <h2>Overall Dashboard</h2>
              
              <div class="metrics-grid">
                <div class="metric-card">
                  <div class="metric-title">Pure Profit (MRR)</div>
                  <div class="metric-value">${current_rev:,.0f} / ${target_rev:,.0f}</div>
                  <div class="progress-bar-bg"><div class="progress-bar-fill"></div></div>
                </div>
                <div class="metric-card">
                  <div class="metric-title">JV Partners Signed</div>
                  <div class="metric-value">{jv_partners} / {target_jv}</div>
                  <div class="progress-bar-bg"><div class="progress-bar-fill blue"></div></div>
                </div>
              </div>
              
              <h3 style="color: #d35400; font-size: 14px; margin-bottom: 10px; text-align: center;">Cross-Segment Performance</h3>
              <div class="multi-segment-grid">
                <div class="segment-card">
                  <div class="segment-title">Solar Leads</div>
                  <div class="segment-value">{leads}</div>
                </div>
                <div class="segment-card">
                  <div class="segment-title">Energy Switches</div>
                  <div class="segment-value">{energy}</div>
                </div>
                <div class="segment-card">
                  <div class="segment-title">Internet Switches</div>
                  <div class="segment-value">{internet}</div>
                </div>
                <div class="segment-card" style="grid-column: span 3;">
                  <div class="segment-title">Credit Card & Finance Referrals</div>
                  <div class="segment-value">{finance}</div>
                </div>
              </div>
              
              <div style="text-align: center; font-size: 14px; font-weight: bold; color: #34495e;">
                FB/Social Posts Made: {organic_posts} | Solar Deals Closed: {sales}
              </div>
            </div>
            
            <!-- AI Advice -->
            <div class="section">
              <h2>🧠 Daily Monetization Advice</h2>
              <div class="advice-box">
                <ul style="list-style-type: none; padding: 0; margin: 0;">
                  {advice_html}
                </ul>
              </div>
            </div>

            <!-- Customer Portal -->
            <div class="section">
              <h2>🔗 Customer Management Portal</h2>
              <div style="background-color: #e8f8f5; padding: 15px; border-left: 5px solid #27ae60; border-radius: 6px; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">
                <p style="margin: 0 0 10px 0; color: #2c3e50; font-size: 15px;">Access your central database for plan details and customer management.</p>
                <a href="http://localhost:5173" style="display: inline-block; background-color: #27ae60; color: white; padding: 10px 18px; text-decoration: none; border-radius: 4px; font-size: 14px; font-weight: bold;">Launch Portal Workspace</a>
                <p style="margin: 10px 0 0 0; font-size: 12px; color: #7f8c8d;">Backend API Server Status: <a href="http://localhost:5000" style="color: #2980b9;">http://localhost:5000</a></p>
              </div>
            </div>

            <!-- Weekly Focus -->
            <div class="section">
              <h2>Week {current_week_idx + 1} Focus</h2>
              <p><strong>{current_milestone['focus']}</strong></p>
              <ul>
                {"".join([f"<li>{action}</li>" for action in current_milestone['actions']])}
              </ul>
            </div>

            <!-- Human Task -->
            <div class="section">
              <h2>🧍 Step-by-Step Instructions</h2>
              <p style="font-size: 13px; color: #7f8c8d; margin-top: -10px;">
                <i>Update Status: To mark as partially complete, use <code>--progress &lt;percentage&gt;</code>. To complete entirely, use <code>--done</code>.</i>
              </p>
              <div class="task-box">
                <h3 style="margin-top:0; color: #2980b9;">{day_data['human_task']}</h3>
                <p><strong>Current Status: {day_data.get('status', 'pending')}</strong></p>
                <ul>
                  {sop_steps}
                </ul>
              </div>
            </div>

            {copy_paste_html}
            
          </div>
          
          <div class="footer">
            Generated by Savenest Intelligence | Multi-Segment Business Hub<br>
            {datetime.now().strftime('%Y-%m-%d %H:%M')}
          </div>
        </div>
      </body>
    </html>
    """
    return html

def ask_int(prompt, min_val=0):
    while True:
        raw = input(prompt).strip()
        if raw == "":
            return None
        try:
            val = int(raw)
            if val >= min_val:
                return val
            print(f"  Please enter a number >= {min_val}.")
        except ValueError:
            print("  Invalid input. Enter a number or press Enter to skip.")

def ask_float(prompt):
    while True:
        raw = input(prompt).strip()
        if raw == "":
            return None
        try:
            return float(raw)
        except ValueError:
            print("  Invalid input. Enter a number or press Enter to skip.")

def run_interactive_status(seo_state, target_plan):
    current_day_idx = seo_state.get('current_day', 1)
    day_data = next((d for d in seo_state['schedule'] if d['day'] == current_day_idx), None)
    if not day_data:
        print("Sprint complete — no more days to update.")
        return

    metrics = target_plan.setdefault('metrics', {
        "leads_generated": 0, "sales_closed": 0,
        "organic_posts": 0, "jv_partners_signed": 0,
        "energy_switches": 0, "internet_switches": 0, "finance_referrals": 0
    })

    print(f"\n{'='*55}")
    print(f"  END-OF-DAY STATUS UPDATE")
    print(f"  Day {current_day_idx}/30: {day_data['title']}")
    print(f"  Current status: {day_data.get('status', 'pending')}")
    print(f"{'='*55}")
    print("  Answer each question — press Enter to skip / keep unchanged.\n")

    changes = []

    # --- Task completion ---
    print("  [1/9] Today's main task:")
    print(f"        \"{day_data['human_task']}\"")
    print("        1 = Done (100%)   2 = In progress   3 = No change")
    while True:
        choice = input("  Your choice [1/2/3]: ").strip()
        if choice == "1":
            day_data['status'] = 'completed (100%)'
            changes.append("Task marked 100% complete")
            break
        elif choice == "2":
            pct = ask_int("  Enter % complete (0-100): ", min_val=0)
            if pct is not None:
                pct = min(pct, 100)
                day_data['status'] = f"in progress ({pct}%)"
                changes.append(f"Task marked {pct}% complete")
            break
        elif choice == "3" or choice == "":
            break
        else:
            print("  Please enter 1, 2, or 3.")

    # --- Metrics ---
    questions = [
        ("leads_generated",   "[2/9] Solar leads generated today?          (Enter to skip): "),
        ("sales_closed",      "[3/9] Solar sales closed today?             (Enter to skip): "),
        ("energy_switches",   "[4/9] Energy plan switches today?           (Enter to skip): "),
        ("internet_switches", "[5/9] Internet plan switches today?         (Enter to skip): "),
        ("finance_referrals", "[6/9] Credit card / finance referrals today?(Enter to skip): "),
        ("organic_posts",     "[7/9] Social / FB group posts made today?   (Enter to skip): "),
        ("jv_partners_signed","[8/9] JV partners signed today?             (Enter to skip): "),
    ]

    for key, prompt in questions:
        val = ask_int(f"  {prompt}")
        if val:
            metrics[key] = metrics.get(key, 0) + val
            changes.append(f"+{val} {key.replace('_', ' ')}")

    # --- Revenue ---
    rev = ask_float("  [9/9] Revenue to log today? ($, Enter to skip): $")
    if rev:
        target_plan['current_revenue'] = target_plan.get('current_revenue', 0) + rev
        changes.append(f"+${rev:,.2f} revenue")

    # --- Advance day ---
    advance = input("\n  Advance to the next day? (y/N): ").strip().lower()
    if advance == 'y':
        if current_day_idx < len(seo_state['schedule']):
            seo_state['current_day'] += 1
            changes.append(f"Advanced to Day {seo_state['current_day']}")
        else:
            print("  Already on the last day.")

    # --- Save ---
    save_json(SEO_STATE_FILE, seo_state)
    save_json(TARGET_PLAN_FILE, target_plan)

    print(f"\n{'='*55}")
    print("  SAVED UPDATES")
    if changes:
        for c in changes:
            print(f"  ✅ {c}")
    else:
        print("  No changes recorded.")
    print(f"{'='*55}\n")

    return day_data, target_plan


def main():
    print("Initializing Utility Portal systems...")
    portal_script = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'utility-portal', 'start.sh')
    if os.path.exists(portal_script):
        subprocess.run([portal_script], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        print(f"Warning: Portal startup script not found at {portal_script}")
        
    parser = argparse.ArgumentParser(description="Savenest - Multi-Segment Organic $10k/mo Script")
    parser.add_argument('--status', action='store_true', help="Interactive end-of-day status update (guided Q&A)")
    parser.add_argument('--done', action='store_true', help="Mark current day's human tasks as 100% complete")
    parser.add_argument('--progress', type=int, metavar='PERCENT', help="Mark current day's human tasks as partially complete (0-100)")
    parser.add_argument('--next', action='store_true', help="Advance to the next day")
    parser.add_argument('--add-lead', type=int, metavar='N', help="Add N organic solar leads to your dashboard")
    parser.add_argument('--add-energy', type=int, metavar='N', help="Add N energy switches")
    parser.add_argument('--add-internet', type=int, metavar='N', help="Add N internet plan switches")
    parser.add_argument('--add-finance', type=int, metavar='N', help="Add N credit card/finance referrals")
    parser.add_argument('--add-sale', type=int, metavar='N', help="Log N solar sales closed")
    parser.add_argument('--add-post', type=int, metavar='N', help="Log N social/FB group posts made")
    parser.add_argument('--add-partner', type=int, metavar='N', help="Log N Joint Venture partners signed")
    parser.add_argument('--add-revenue', type=float, metavar='AMOUNT', help="Add $AMOUNT to current revenue")
    parser.add_argument('--email', type=str, default="ceodaily2026@gmail.com", help="Email address to send the briefing to")
    args = parser.parse_args()

    if args.status:
        seo_state = load_json(SEO_STATE_FILE)
        target_plan = load_json(TARGET_PLAN_FILE)
        result = run_interactive_status(seo_state, target_plan)
        if result:
            day_data, target_plan = result
            print(f"Generating updated dashboard email to {args.email}...")
            html_content = generate_html_email(day_data, target_plan)
            subject = f"Business Sync Update - Day {day_data['day']}: {day_data['title']}"
            send_email(subject, html_content, to_email=args.email)
        sys.exit(0)

    # Handle metric additions
    if args.add_lead is not None: log_metric('leads_generated', args.add_lead); sys.exit(0)
    if args.add_energy is not None: log_metric('energy_switches', args.add_energy); sys.exit(0)
    if args.add_internet is not None: log_metric('internet_switches', args.add_internet); sys.exit(0)
    if args.add_finance is not None: log_metric('finance_referrals', args.add_finance); sys.exit(0)
    if args.add_sale is not None: log_metric('sales_closed', args.add_sale); sys.exit(0)
    if args.add_post is not None: log_metric('organic_posts', args.add_post); sys.exit(0)
    if args.add_partner is not None: log_metric('jv_partners_signed', args.add_partner); sys.exit(0)
    if args.add_revenue is not None: log_revenue(args.add_revenue); sys.exit(0)

    seo_state = load_json(SEO_STATE_FILE)
    target_plan = load_json(TARGET_PLAN_FILE)

    current_day_idx = seo_state.get('current_day', 1)
    day_data = next((d for d in seo_state['schedule'] if d['day'] == current_day_idx), None)
    
    if not day_data:
        print(f"🏆 Sprint Complete! You reached the end of the 30-day schedule.")
        sys.exit(0)

    # Task Status Updates
    if args.done:
        day_data['status'] = 'completed (100%)'
        save_json(SEO_STATE_FILE, seo_state)
        print(f"✅ Marked Day {current_day_idx} tasks as 100% completed!")
        sys.exit(0)
        
    if args.progress is not None:
        clamped_progress = max(0, min(100, args.progress))
        day_data['status'] = f"in progress ({clamped_progress}%)"
        save_json(SEO_STATE_FILE, seo_state)
        print(f"⏳ Marked Day {current_day_idx} tasks as {clamped_progress}% completed!")
        sys.exit(0)
        
    if args.next:
        if current_day_idx < len(seo_state['schedule']):
            seo_state['current_day'] += 1
            save_json(SEO_STATE_FILE, seo_state)
            print(f"⏩ Advanced to Day {seo_state['current_day']}. Let's grind.")
        else:
            print("Cannot advance. You are on the last day.")
        sys.exit(0)

    print(f"\n{'='*55}")
    print(f"🌱 SAVENEST MULTI-SEGMENT BUSINESS HUB 🌱")
    print(f"{ '='*55}")
    print(f"📅 Day {day_data['day']}/30: {day_data['title']}")
    print(f"📊 Status: {day_data.get('status', 'pending')}")
    print(f"💰 MRR Profit: ${target_plan.get('current_revenue', 0):,.2f} / ${target_plan.get('target_revenue_mrr', 10000):,.0f}")
    
    metrics = target_plan.get('metrics', {})
    print(f"\n--- CROSS-SEGMENT PERFORMANCE ---")
    print(f"☀️  Solar Leads: {metrics.get('leads_generated', 0)} (Closed: {metrics.get('sales_closed', 0)})")
    print(f"⚡  Energy Switches: {metrics.get('energy_switches', 0)}")
    print(f"🌐  Internet Switches: {metrics.get('internet_switches', 0)}")
    print(f"💳  Finance Referrals: {metrics.get('finance_referrals', 0)}")
    
    print(f"\n🤝 JV Partners: {metrics.get('jv_partners_signed', 0)} / {metrics.get('target_jv_partners', 15)}")
    print(f"📱 Social Posts: {metrics.get('organic_posts', 0)}")
    
    print(f"\n🧍 Step-by-Step Instructions:\n  - {day_data['human_task']}")
    
    if 'copy_paste_template' in day_data and day_data['copy_paste_template']:
        print(f"\n📋 YOUR EXACT COPY & PASTE TEMPLATE:")
        print(f"--------------------------------------------------")
        print(day_data['copy_paste_template'])
        print(f"--------------------------------------------------")

    print(f"\nGenerating and sending dynamic dashboard to {args.email}...")
    
    html_content = generate_html_email(day_data, target_plan)
    subject = f"Business Sync - Day {day_data['day']}: {day_data['title']}"
    
    send_email(subject, html_content, to_email=args.email)
    
    print("\nRun  python3 ceo_daily_sync.py --status  at end of day to update all your metrics interactively.")

if __name__ == "__main__":
    main()
