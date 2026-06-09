import json
import webbrowser
import time
import os

CONFIG_PATH = 'marketing/social_strike_config.json'

def run_organic_strike():
    if not os.path.exists(CONFIG_PATH):
        print("Error: social_strike_config.json not found.")
        return

    with open(CONFIG_PATH, 'r') as f:
        config = json.load(f)

    # Rotate Content
    posts = config['content_rotation']
    last_idx = config.get('last_posted_index', 0)
    current_post = posts[last_idx % len(posts)]
    
    print("\n" + "="*50)
    print("🚀 SAVENEST ORGANIC STRIKE ACTIVATED")
    print("="*50)
    print(f"\nTODAY'S VIRAL CONTENT ({current_post['id']}):")
    print("-" * 30)
    print(current_post['text'])
    print("-" * 30)
    
    # Try to copy to clipboard (requires pyperclip)
    try:
        import pyperclip
        pyperclip.copy(current_post['text'])
        print("\n✅ CONTENT COPIED TO CLIPBOARD!")
    except ImportError:
        print("\n⚠️  Install 'pyperclip' to enable auto-copy: pip install pyperclip")

    print(f"\nLaunching {len(config['target_groups'])} Facebook Groups in 5 seconds...")
    print("Action: Once the page loads, click 'Write something...', Paste (Ctrl+V), and Post.")
    time.sleep(5)

    for group_url in config['target_groups']:
        print(f"Opening: {group_url}")
        webbrowser.open(group_url)
        time.sleep(1) # Small delay to prevent browser overload

    # Update index for next time
    config['last_posted_index'] = last_idx + 1
    with open(CONFIG_PATH, 'w') as f:
        json.dump(config, f, indent=2)

    print("\n" + "="*50)
    print("✅ STRIKE COMPLETE. CHECK YOUR DMS IN 2 HOURS.")
    print("="*50)

if __name__ == "__main__":
    run_organic_strike()
