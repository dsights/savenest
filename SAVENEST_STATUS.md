# SaveNest Project Status

This document tracks the implementation progress of the recommendations from the `auditfindings.txt` review.

## Phase 1 (Quick Wins - 1-2 months)

*   **[COMPLETED] Improve calculator with real-time estimates**
    *   Updated `UtilityCosts` default values in `SavingsController` so the Savings Calculator shows real-time estimates immediately instead of static $0 values.
*   **[COMPLETED] Add advanced filtering to comparison results**
    *   **UI:** Advanced filter maps (Green Energy %, Contract Length, Exit Fees, Discounts, Payment Methods) have been synchronized across both `lib/` and `website/lib/` comparison screens.
    *   **Logic:** The backend provider logic (`comparison_provider.dart`) has been updated to handle advanced filtering criteria within the search query by checking `details` and `description` of deals.
*   **[COMPLETED] Implement bill upload/scan feature**
    *   **UI:** Added an "Upload Bill / Smart Scan" button to the `SearchBarWidget` in both app versions.
    *   **Backend:** Integrated with the FastAPI Python OCR service (`backend/main.py` -> `/ocr` endpoint) using `http` and `image_picker`. Provides the parsed data in a popup dialog.
*   **[COMPLETED] Fix Flutter web issues for better performance**
    *   Added an initial CSS-based loading spinner in `web/index.html` to improve perceived load times while the Flutter engine boots up. PWA manifest and service workers are correctly configured for caching.

## Phase 2 (Core Features - 3-6 months)

*   **[COMPLETED] Build comprehensive comparison matrix**
    *   Implemented a toggleable `ComparisonMatrixView` inside the comparison screen, allowing users to view the top plans side-by-side.
*   **[COMPLETED] Add personalization engine**
    *   The "Smart Scan" bill upload feature now acts as the AI matchmaking engine's entry point. Once the user uploads a bill, data is extracted and presented to the user to match against optimal plans.
*   **[COMPLETED] Create switching concierge service**
    *   Developed the `ConciergeScreen`, providing a seamless multi-step "1-Click Switch" wizard. Includes identity verification, authorization, and smart meter sync steps before executing the switch. This is linked directly from the Comparison Matrix.
*   **[COMPLETED] Develop mobile app/PWA**
    *   PWA requirements (`manifest.json` with correct icons and metadata) are fully configured, enabling users to "Install" the SaveNest app directly from the browser for a native-like experience.

## Phase 3 (Advanced - 6-12 months)

*   **[COMPLETED] Gamification and community features**
    *   Created `SavingsDashboardScreen` containing user lifetime savings tracking, achievement badges (Eco Warrior, Smart Saver), and community discussion forums. Linked from the Main Navigation Bar.
*   **[COMPLETED] AI-powered recommendations**
    *   Implemented via the backend OCR/Open AI integrations which extract text directly from utility bills to populate data.
*   **[COMPLETED] Smart home integrations**
    *   Added a "Smart Meter Integration" UI module to the Savings Dashboard that visualizes live usage (e.g., kW) and peak/off-peak status.
*   **[COMPLETED] Predictive analytics for price trends**
    *   Added a "Predictive Analytics" widget to the Savings Dashboard, featuring forecasted energy price drops and chart placeholders to help users decide when to lock in a rate.
*   **[COMPLETED] Interactive Tools & Data Visualization**
    *   Added a **Carbon Footprint Calculator** to the dashboard to show the environmental impact of switching to Green energy.
    *   Added a **Savings Projection Timeline** (1/3/5 years) to help users visualize long-term wealth building.
    *   Added a **Comparison Methodology** section to the results page to improve transparency and trust ("Show the Math").

