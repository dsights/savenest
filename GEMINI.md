# SaveNest Project Instructions

## Email & Branding Authority
All automated communications sent by SaveNest agents must adhere to the following strict protocol:

- **Sender Name:** "SaveNest" <contact@savenest.au>
- **Mandatory BCC:** savenest.au@gmail.com (for all outreach and system notifications)
- **Primary Contact:** 0423 265 518
- **Office Location:** 5-7 Bando Road, Girraween, NSW 2145
- **Template Standard:** Premium HTML with Green SaveNest branding, Multi-part (Plain + HTML), and SN icon signature.
- **Compliance:** Must include a physical address and 'Unsubscribe' option in the footer.
- **Tone:** Professional Brokerage / High-Trust / Value-Oriented.

## Business Strategy
- **Growth Model:** 100% Organic (Facebook Groups, SEO, JVs). 
- **Ad Spend:** $0 budget for paid ads unless explicitly overridden by the owner.
- **Vendor Model:** Pay-Per-Close commission only. 

## Automated Workflows
- **Lead Handoff:** Use `scripts/handoff_lead.py` to ensure consistent formatting and BCC tracking.
- **Data Refresh:** Run `sync_products.py` and `update_prices.py` daily to prevent stale data.
- **Deployment:** Push to `main` branch triggers GitHub Actions for live deployment.
