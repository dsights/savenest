# SaveNest Project Documentation

## 1. Project Overview

SaveNest is a multi-faceted project designed to operate as an affiliate marketing and utility comparison platform. It comprises several interconnected components, including a customer-facing website/app, a backend API with AI and automation features, an internal admin portal for managing utility switches, and a suite of scripts for data management and email marketing.

The primary goal of the project is to provide users with a platform to compare and switch utility providers, credit cards, and other financial products, while generating affiliate revenue.

## 2. System Architecture

The SaveNest ecosystem is composed of several distinct applications that work together:

*   **Flutter Frontend:** The main user-facing application, built with Flutter. It's a web and mobile app that displays comparison data, blog posts, and captures user information.
*   **Python Backend:** A FastAPI server that acts as a backend-for-frontend (BFF) and a service layer. It provides AI-powered document analysis, OCR, form pre-filling, and a secure proxy for interacting with third-party APIs like HubSpot and Basiq.
*   **Utility Switcher Portal:** A standalone Node.js/React application that serves as an internal tool for managing customer utility switch requests. It has its own database and authentication.
*   **Data Scripts:** A collection of Python and Dart scripts are used to populate and maintain the data used by the Flutter application (e.g., utility plans, blog posts).
*   **Email System:** A simple email marketing system built with shell scripts and `msmtp` for sending templated emails.

**Data Flow Example (User Bill Upload):**

1.  A user on the Flutter web app uploads a copy of their utility bill.
2.  The Flutter app sends the file to the Python (FastAPI) backend's `/upload` endpoint.
3.  The Python backend receives the file and performs two main actions:
    a.  It uploads the file to HubSpot via the HubSpot API for CRM purposes.
    b.  It sends the file to the Google Cloud Vision API for OCR to extract text and identify the provider.
4.  The backend returns the HubSpot file URL and the OCR analysis to the Flutter app.
5.  The Flutter app can then use this information to guide the user to relevant offers.

## 3. Flutter Web/Mobile App (`website/`)

This is the core, user-facing application of the SaveNest project, built with Flutter.

*   **Purpose and Functionality:**
    *   Displays product and service comparisons (e.g., electricity, internet).
    *   Features a blog for content marketing.
    *   Provides tools for users to upload bills for analysis.
    *   Captures user data through forms and integrates with the backend for processing.
*   **Technologies Used:**
    *   **Framework:** Flutter
    *   **State Management:** `flutter_riverpod`
    *   **Routing:** `go_router`
    *   **HTTP:** `http` package
    *   **SEO:** `meta_seo` for web SEO.
*   **Key Files and Directories:**
    *   `website/lib/main.dart`: The application's entry point.
    *   `website/lib/router.dart`: Defines all the application's routes (URLs).
    *   `website/lib/features/`: Contains the different features of the application, likely following a feature-based project structure.
    *   `website/lib/services/`: Contains services for interacting with APIs (e.g., `hubspot_service.dart`).
    *   `website/assets/data/`: Contains JSON files that act as a database for the app's content (e.g., `products.json`, `blog_posts.json`).
*   **Data Sources:** The app's content is primarily sourced from static JSON files located in `website/assets/data/`. These files are managed and updated by the scripts in the `scripts/` directory.
*   **Deployment:** The project appears to be deployed as a web application. The `PROJECT_HANDOVER.md` document mentions deployment to cPanel.

## 4. Python Backend (`backend/`)

This is a FastAPI application that serves as a backend-for-frontend and service layer.

*   **Purpose and Functionality:**
    *   Provides a secure proxy for client-side interactions with third-party APIs (HubSpot, Basiq), keeping API keys off the frontend.
    *   **OCR Service:** Extracts data from user-uploaded bills using Google Cloud Vision API.
    *   **AI Agent:** Analyzes PDF documents (like energy fact sheets) using a Large Language Model (Gemini 1.5 Pro via LangChain) to extract specific financial information.
    *   **Browser Automation:** A placeholder service to pre-fill online application forms using Playwright.
    *   **Financial Data Aggregation:** Integrates with the Basiq API to create users and manage connections to financial institutions.
*   **Technologies Used:**
    *   **Framework:** FastAPI
    *   **Server:** Uvicorn
    *   **AI/ML:** `langchain`, `google-generativeai`, `google-cloud-vision`
    *   **Web Scraping/Automation:** `playwright`
    *   **PDF Processing:** `PyMuPDF` (`fitz`)
*   **API Endpoints:**
    *   `/upload`: Proxies file uploads to HubSpot and triggers OCR analysis.
    *   `/ocr`: Processes a file with the OCR service.
    *   `/analyze-pdf`: Analyzes a PDF with the AI agent.
    *   `/prefill-form`: (Placeholder) Initiates the form pre-filling process.
    *   `/users`, `/users/{user_id}/connections`: Manages users and connections in the Basiq service.
*   **Security Considerations:**
    *   The backend abstracts API keys (HubSpot, Google Cloud, Basiq) from the frontend, which is a good security practice.
    *   It uses CORS to restrict access to allowed origins.

## 5. Utility Switcher Portal (`utility-portal/`)

This is a standalone web application that serves as an internal admin tool.

*   **Purpose and Functionality:**
    *   Provides an interface for managing customers and their utility switch requests.
    *   Allows an admin to view pending switches, add/edit customers, and manage products.
*   **Architecture:**
    *   **Frontend:** A React application built with Vite and using the Material-UI component library.
    *   **Backend:** A Node.js application using the Express.js framework.
    *   **Database:** A SQLite database (`utility-switcher.db`).
*   **Database Schema:**
    *   `customers`: Stores customer information.
    *   `products`: Stores product information.
    *   `switch_requests`: Tracks the status of customer switch requests.
*   **Authentication:**
    *   A simple, non-production-ready authentication system that uses a single admin username and password stored in environment variables.
    *   Uses JWT for session management.
*   **Scheduled Tasks:**
    *   A cron job runs daily to process pending switch requests. It simulates contacting the utility provider and marks the switch as 'COMPLETED'.

## 6. Email & Marketing (`email-config/`)

This component provides basic email sending capabilities.

*   **Purpose and Functionality:**
    *   Sending single and bulk emails using pre-defined HTML templates.
*   **Technologies Used:**
    *   `msmtp`: A command-line SMTP client.
    *   Shell scripts (`.sh`).
*   **Key Files:**
    *   `msmtprc`: Configuration file for `msmtp`, containing SMTP server details.
    *   `send_single_email.sh`: Script to send an email to a single recipient.
    *   `send_bulk_email.sh`: Script to send an email to a list of recipients.
    *   `templates/`: Directory containing HTML email templates.
*   **Security Warning:** The `msmtprc` file contains a **plaintext password**. This is a significant security vulnerability. The password should be stored in a secure manner, for example, using environment variables or a secret management system.

## 7. Data & Content Management Scripts (`scripts/`)

This directory contains a collection of scripts for maintaining the project's data and content.

*   **Purpose and Functionality:**
    *   Automating the process of fetching and updating data for the Flutter application.
    *   Validating content and data files.
    *   Generating sitemaps for SEO.
*   **Examples of Key Scripts:**
    *   `update_electricity_plans.py`: Fetches electricity plans from the AER's CDR API and updates `products.json`.
    *   `generate_sitemap.dart`: Generates a `sitemap.xml` file for the website.
    *   `validate_json.dart`: A utility script to validate the syntax of JSON data files.

## 8. Project Documentation (`documents/`)

The `documents/` directory contains various markdown files related to project management and documentation.

*   `PROJECT_HANDOVER.md`: A crucial document that provides a high-level overview of the project's architecture, deployment, and operational procedures.
*   Other files like `DEVELOPMENT_LOG.md`, `KEYWORD_MAP.md`, etc., provide additional context on the project's history and strategy.
