import os
import json
from datetime import date

# This script is designed to be run by the SaveNest agent (Gemini CLI) 
# to discover new plans and providers. It outputs a structure that can 
# be directly used to update the master database.

PROVIDERS = [
    "SpinTel", "More", "Tangerine", "Superloop", "Aussie Broadband", 
    "Exetel", "Mate", "Flip", "Buddy Telco", "Amaysim", "Kogan Internet",
    "Swoop", "TPG", "Telstra", "Optus", "Vodafone", "Belong", "Southern Phone"
]

def generate_search_queries():
    queries = []
    # General discovery
    queries.append("cheapest NBN plans Australia June 2026 EOFY offers")
    queries.append("best high speed NBN 1000 plans Australia 2026")
    
    # Specific provider checks
    for p in PROVIDERS:
        queries.append(f"{p} NBN plans and mobile offers June 2026")
        
    return queries

def main():
    print(f"--- SaveNest Telecom Discovery Tool - {date.today()} ---")
    print("Run the following queries in Google Search to find latest data:")
    for i, q in enumerate(generate_search_queries()):
        print(f"{i+1}. {q}")
    
    print("\nAfter finding new data, update the 'UPDATED_PLANS' dictionary in 'scripts/update_official_csv.py'.")
    print("The system will automatically ingestion and validate during the next deployment.")

if __name__ == "__main__":
    main()
