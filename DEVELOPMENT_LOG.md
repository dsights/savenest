# SaveNest Development Log

## Status: 2026-02-08

### Completed:
- **Affiliate Comparison Site Overhaul:**
  - Transformed website into an affiliate comparison/publisher site.
  - **Created "Compare X" pages:**
    - Implemented `ComparisonScreen` for various categories (electricity, gas, internet, mobile, insurance).
    - Updated `products.json` parsing and data loading in `JsonProductRepository` to align with new data structure, including commission parsing and logo URLs.
    - Enhanced `DealCard` to display "Sponsored" and "BEST VALUE" badges.
    - Implemented deal sorting in `ComparisonController` to prioritize sponsored deals, then sort by price.
    - Changed comparison routes from `/compare/:category` to `/deals/:category` for a more professional URL structure.
  - **Created "Advertise with us" page:**
    - Implemented `AdvertiseWithUsScreen` with details for partners, promotional channels, and example placements.
    - Added route `/partners/advertise`.
  - **Created "How we work" page:**
    - Implemented `HowItWorksScreen` explaining the affiliate business model and sponsored placements.
    - Added route `/how-it-works`.
  - **Created "Privacy Policy" and "Terms of Service" pages:**
    - Implemented `PrivacyPolicyScreen` and `TermsOfServiceScreen` detailing data usage, affiliate tracking, and terms of service.
    - Added routes `/privacy` and `/terms`.
  - **Created "About Us" page:**
    - Implemented `AboutUsScreen` with company mission and placeholder business details (ABN).
    - Added route `/about`.
  - **Updated Navigation and Footer:**
    - Modified `LandingScreen` navigation bar, mobile drawer, category cards, and footer links to point to the new `/deals` routes and new informational pages.
    - Removed irrelevant "Download App" and "How It Works" sections from `LandingScreen` hero.
  - **Strengthened Trust and Legitimacy:**
    - Incorporated `savenest.au` email where appropriate.

## Status: 2026-01-24
### Completed:
- **CaaS Integration (Phase 1):** 
  - Added `webview_flutter` dependency.
  - Implemented `PartnerWebView` widget for embedded comparison tools.
  - Added "Self Service" entry points in `ComparisonScreen` (AppBar icon and CTA button).
  - Configured project to be ready for CIMET/AccuRate white-label integration.

### Pending:
- **Affiliate Link Update:**
  - Update `lib/features/comparison/comparison_screen.dart` with the production affiliate URL once obtained from CIMET.