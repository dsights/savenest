import ftplib
import sys
import getpass

def test_ftp_connection():
    print("--- FTP Connection Tester ---")
    server = input("Enter FTP Server (e.g., ftp.example.com): ").strip()
    username = input("Enter FTP Username: ").strip()
    password = getpass.getpass("Enter FTP Password: ").strip()

    print(f"\nAttempting to connect to '{server}'...")

    try:
        # 1. Test DNS/Connection
        print("Connecting with FTP_TLS...")
        ftp = ftplib.FTP_TLS(server)
        print("✅ Connected to server (Socket opened).")
        
        # 2. Test Login
        print("Attempting login...")
        ftp.login(user=username, passwd=password)
        ftp.prot_p() # Switch to secure data connection
        print("✅ Login successful (Secure Data Connection Enabled).")

        # 3. Test List
        print("Listing files in current directory:")
        ftp.retrlines('LIST')
        
        ftp.quit()
        print("\n🎉 Connection test passed!")
        
    except ftplib.all_errors as e:
        print(f"\n❌ FTP Error: {e}")
    except Exception as e:
        print(f"\n❌ General Error: {e}")

if __name__ == "__main__":
    test_ftp_connection()
