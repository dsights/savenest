import json
import webbrowser
import time
import os
import contextlib

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
    print("🚀 SAVENEST MULTI-CHANNEL ORGANIC STRIKE")
    print("="*50)
    print(f"\nTODAY'S VIRAL CONTENT ({current_post['id']}):")
    print("-" * 30)
    print(current_post['text'])
    print("-" * 30)
    
    # Try to copy to clipboard
    try:
        import pyperclip
        pyperclip.copy(current_post['text'])
        print("\n✅ CONTENT COPIED TO CLIPBOARD!")
    except ImportError:
        print("\n⚠️  Install 'pyperclip' to enable auto-copy: pip install pyperclip")

    # Collect all target URLs
    all_urls = []
    channels = config.get('channels', {})
    
    # Add Facebook Groups
    all_urls.extend(channels.get('facebook_groups', []))
    # Add Instagram
    all_urls.extend(channels.get('instagram', []))
    # Add LinkedIn
    all_urls.extend(channels.get('linkedin', []))
    # Add Twitter/X
    all_urls.extend(channels.get('twitter_x', []))

    print(f"\nTargeting {len(all_urls)} Social Channels.")
    print("Action: Paste (Ctrl+V) and Post in each tab.")
    
    choice = input("\n[1] Auto-open all tabs (May fail in WSL/Terminal) | [2] List URLs only: ")

    if choice == '1':
        print("\nOpening tabs...")
        failed = False
        for url in all_urls:
            print(f"  → Opening: {url}")
            try:
                # Redirect stderr to suppress xdg-open "browser not found" errors
                with open(os.devnull, 'w') as fnull:
                    with contextlib.redirect_stderr(fnull):
                        success = webbrowser.open(url)
                if not success:
                    failed = True
            except Exception as e:
                print(f"    ❌ Error: {e}")
                failed = True
            time.sleep(0.5)
        
        if failed:
            print("\n⚠️  Some tabs might not have opened. Ensure you have a default browser configured.")
            print("If you are in WSL, try 'List URLs only' instead.")
    else:
        print("\n📋 SOCIAL CHANNEL LINKS:")
        print("-" * 30)
        for url in all_urls:
            print(url)
        print("-" * 30)
        print("\nTip: In most terminals, you can Ctrl+Click these links to open them.")

    # Update index for next time
    config['last_posted_index'] = last_idx + 1
    with open(CONFIG_PATH, 'w') as f:
        json.dump(config, f, indent=2)

    print("\n" + "="*50)
    print("✅ MULTI-CHANNEL STRIKE COMPLETE.")
    print("="*50)

if __name__ == "__main__":
    run_organic_strike()
