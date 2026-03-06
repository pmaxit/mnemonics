import csv
import sys
csv.field_size_limit(sys.maxsize)
from google.oauth2 import service_account
from googleapiclient.discovery import build

SCOPES = ['https://www.googleapis.com/auth/spreadsheets']
SERVICE_ACCOUNT_FILE = 'assets/credentials.json'

SPREADSHEET_ID = '1DkfyiJh5P9Zcq5L7LimYGrHZzKHVHjM-uBmsdFkkTHM'
RANGE_NAME = 'Sheet1!A1'

def upload_csv():
    # Load credentials
    creds = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, scopes=SCOPES)
        
    service = build('sheets', 'v4', credentials=creds)
    sheet = service.spreadsheets()
    
    # Read CSV
    print("Reading CSV data...")
    with open('assets/Vocabulary_with_Insights.csv', 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        values = list(reader)
        
    body = {
        'values': values
    }
    
    print(f"Uploading {len(values)} rows to Google Sheets...")
    # Update spreadsheet
    result = sheet.values().update(
        spreadsheetId=SPREADSHEET_ID, range=RANGE_NAME,
        valueInputOption='USER_ENTERED', body=body).execute()
        
    print(f"Successfully updated {result.get('updatedCells')} cells.")

if __name__ == '__main__':
    upload_csv()
