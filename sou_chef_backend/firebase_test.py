import firebase_admin
import os
from firebase_admin import credentials  
from dotenv import load_dotenv

def main():
    print("Attempting Connection to Firebase")
    load_dotenv()

    cred_path = os.getenv('GOOGLE_APPLICATION_CREDENTIALS')
    if not cred_path:
        print("ERROR: GOOGLE_APPLICATION_CREDENTIALS not set.")
        return

    try:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print("Firebase Admin SDK successfully initialized")
        print("Default app name:", firebase_admin.get_app().name)
    except Exception as e:
        print(f"Failed to connect to Firebase: {e}")

if __name__ == "__main__":
    main()