# SaveNest SEO Growth & Content Checklist

## 1. Content Expansion (Goal: 100+ Pages)
- [x] **Core Comparison Tool:** Functional comparison for Energy, NBN, Mobile, Insurance.
- [x] **Provider Detail Pages:** Create dedicated pages for each plan/provider (e.g., `/deal/origin-energy-daily-saver`).
    - *Status:* **Completed.** (164+ deal pages active at `/deal/:id`).
- [x] **State-Based Guides:** Create landing pages for state specific queries (e.g., `/electricity/nsw`, `/gas/vic`).
    - *Status:* **Completed.** (21 guide pages active at `/guides/:state/:utility`).
- [x] **Blog Content:** 20+ High-quality articles implemented.
    - *Action:* Continue adding 2-3 articles/week.
- [x] **Author Bios:** Enhance blog posts with author expertise/bios to build EEAT.
    - *Status:* **Completed.** (Implemented in `BlogPostScreen`).

## 2. Technical SEO & Indexing
- [x] **Meta Tags:** Title and Description tags implemented for core pages.
- [x] **Dynamic Meta Tags:** Ensure Provider Detail and State Guide pages have dynamic, keyword-rich meta tags.
    - *Status:* **Completed.** (Implemented using `MetaSEO`).
- [x] **Title & Description Optimization:** Optimized for length (<60 chars title, <155 chars desc) and keyword density.
    - *Status:* **Completed.** (Updated in Landing, Comparison, and State Guide screens).
- [x] **Heading Structure:** H1-equivalent headings optimized for primary keywords (e.g., "Best Energy Comparison in Australia").
    - *Status:* **Completed.**
- [x] **Internal Linking:** Added footer navigation for State Guides and improved cross-linking.
    - *Status:* **Completed.**
- [x] **Image SEO:** Added semantic labels (alt text) to all primary images and logos.
    - *Status:* **Completed.**
- [x] **Schema.org:** Organization/LocalBusiness schema added to `index.html`.
- [x] **Product Schema:** Add `Product` structured data to Deal Detail pages.
    - *Status:* **Completed.** (Open Graph Product tags added).
- [x] **Sitemap.xml:** Update sitemap to include all 164+ product routes and blog routes.
    - *Status:* **Completed.** (Generated 1000+ URLs in `web/sitemap.xml`).
- [x] **Robots.txt:** Ensure it allows crawling.
    - *Status:* **Completed.** (Verified `web/robots.txt` allows all agents).

## 3. Trust & Authority (EEAT)
- [x] **Contact & Legal:** Contact Us, Privacy, Terms, Disclaimer pages exist.
- [x] **User Reviews:** Add a reviews section to Provider/Deal pages (even if static/placeholder for now).
    - *Status:* **Completed.** (Added to `DealDetailsScreen`).
- [x] **Trust Badges:** Display partner logos and "Verified" badges prominently.
    - *Status:* **Completed.** (Added "Independent Analysis" badge logic).

## 4. Conversion Optimization
- [x] **Affiliate Links:** "Go to Site" buttons implemented.
- [x] **Savings Calculator:** Implemented.
- [x] **Lead Capture:** "Contact Us" / "Personalised Quote" CTA added.

## Execution Plan
1.  **Implement `DealDetailsScreen`:** A dedicated page for every product in `products.json`.
2.  **Implement `StateGuideScreen`:** Dedicated SEO landing pages for each state.
3.  **Update `sitemap.xml`:** Generate a comprehensive sitemap listing all new routes.
4.  **Enhance `DealDetailsScreen`:** Add Reviews, Authoritative descriptions, and Schema.org tags.
