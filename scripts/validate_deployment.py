import json
import os
import re
import sys
from datetime import date

def validate_products():
    print("--- Validating Products ---")
    path = 'assets/data/products.json'
    if not os.path.exists(path):
        print(f"ERROR: {path} not found.")
        return False

    try:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"ERROR: Failed to parse products.json: {e}")
        return False

    categories = {
        'internet': 10,
        'electricity': 10,
        'gas': 10,
        'mobile': 10,
        'solar': 5,
        'insurance': 5,
        'security': 10
    }
    all_pass = True

    for cat, threshold in categories.items():
        items = data.get(cat, [])
        count = len(items)
        if count < threshold:
            print(f"FAIL: Category '{cat}' only has {count} items (threshold: {threshold}).")
            all_pass = False
        else:
            print(f"OK: Category '{cat}' has {count} items.")

    # Check for empty fields in products
    for cat in categories:
        for i, item in enumerate(data.get(cat, [])):
            if not item.get('providerName') or not item.get('planName'):
                print(f"FAIL: Empty provider or plan name in {cat} at index {i}.")
                all_pass = False
            if item.get('isEnabled') is False and count > 10:
                # Warning only? If it's disabled it doesn't show up.
                pass

    return all_pass

def validate_blogs():
    print("\n--- Validating Blog Articles ---")
    path = 'assets/data/blog_posts.json'
    if not os.path.exists(path):
        print(f"ERROR: {path} not found.")
        return False

    try:
        with open(path, 'r', encoding='utf-8') as f:
            posts = json.load(f)
    except Exception as e:
        print(f"ERROR: Failed to parse blog_posts.json: {e}")
        return False

    all_pass = True
    for post in posts:
        slug = post.get('slug', 'unknown')
        title = post.get('title', 'No Title')
        content = post.get('content', '')
        image = post.get('imageUrl', '')
        thumb = post.get('thumbnailUrl', '')
        
        # 1. Image Check
        if not image or len(image) < 5:
            print(f"FAIL: [{slug}] Missing image URL.")
            all_pass = False
        if not thumb or len(thumb) < 5:
            print(f"FAIL: [{slug}] Missing thumbnail URL.")
            all_pass = False
        
        # 2. Word Count Check (> 1000 words)
        # Strip HTML
        stripped = re.sub('<[^<]+?>', ' ', content)
        stripped = re.sub(r'\s+', ' ', stripped).strip()
        words = stripped.split()
        word_count = len(words)
        if word_count < 1000:
            print(f"FAIL: [{slug}] Word count is {word_count} (threshold: 1000).")
            all_pass = False
            
        # 3. Checklist / Action Items Check
        # Look for headers with 'Checklist' or 'Action' or 'Steps' or 'Summary'
        checklist_headers = [
            r'<h[23].*?>.*?Checklist.*?</h[23]>',
            r'<h[23].*?>.*?Action Items.*?</h[23]>',
            r'<h[23].*?>.*?Steps to Take.*?</h[23]>',
            r'<h[23].*?>.*?Summary Checklist.*?</h[23]>',
            r'<h[23].*?>.*?Your Execution Plan.*?</h[23]>'
        ]
        has_checklist_header = any(re.search(p, content, re.IGNORECASE | re.DOTALL) for p in checklist_headers)
        
        if not has_checklist_header:
            print(f"FAIL: [{slug}] No explicit 'Checklist' or 'Action Items' header found.")
            all_pass = False

    if all_pass:
        print(f"OK: All {len(posts)} blog posts passed quality checks.")
    
    return all_pass

def main():
    p_valid = validate_products()
    b_valid = validate_blogs()
    
    if not p_valid or not b_valid:
        print("\nQuality Control Failed. Please fix the issues above before deploying.")
        sys.exit(1)
    
    print("\nQuality Control Passed! Deployment can proceed.")

if __name__ == "__main__":
    main()
