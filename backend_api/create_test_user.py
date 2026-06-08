#!/usr/bin/env python3
"""
Create a test user in Firebase Authentication.
Requires Firebase Admin SDK credentials for the mnemonics project.
"""

import json
import os
import sys

def create_test_user(email, password, display_name="Test User"):
    try:
        import firebase_admin
        from firebase_admin import auth

        cred_path = os.environ.get('FIREBASE_CREDENTIALS', 'firebase-service-account.json')

        if not os.path.exists(cred_path):
            print(f"Error: Credentials file not found: {cred_path}")
            print("\nTo get credentials:")
            print("1. Go to Firebase Console -> Project Settings -> Service Accounts")
            print("2. Click 'Generate new private key'")
            print("3. Save the JSON file as 'firebase-service-account.json' in backend_api/")
            print("4. Run this script again")
            return False

        if not firebase_admin._apps:
            cred = firebase_admin.credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)

        user = auth.create_user(
            email=email,
            password=password,
            display_name=display_name
        )

        print(f"✅ Test user created successfully!")
        print(f"   Email: {email}")
        print(f"   UID: {user.uid}")
        return True

    except ImportError:
        print("Error: firebase-admin not installed")
        print("Run: pip install firebase-admin")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == '__main__':
    email = "test@mailnator.io"
    password = "test123"
    name = "Test User"

    if len(sys.argv) > 1:
        email = sys.argv[1]
    if len(sys.argv) > 2:
        password = sys.argv[2]
    if len(sys.argv) > 3:
        name = sys.argv[3]

    print(f"Creating test user: {email}")
    create_test_user(email, password, name)