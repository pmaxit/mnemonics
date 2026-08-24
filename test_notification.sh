#!/bin/bash

# Simple script to test notification flow
# Usage: ./test_notification.sh [server_url] [device_token]

SERVER_URL=${1:-"http://localhost:8080"}
DEVICE_TOKEN=${2:-""}

echo "Testing notification flow..."
echo "Server URL: $SERVER_URL"

# Step 1: Create a test notification
echo -e "\n1. Creating test notification..."
CREATE_RESPONSE=$(curl -s -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Notification",
    "body": "This is a test notification from the shell script",
    "schemeType": "general",
    "priority": "medium"
  }' \
  "$SERVER_URL/api/notifications")

HTTP_CODE=${CREATE_RESPONSE: -3}
RESPONSE_BODY=${CREATE_RESPONSE%???}

if [ "$HTTP_CODE" != "201" ]; then
  echo "Failed to create notification: $HTTP_CODE"
  echo "$RESPONSE_BODY"
  exit 1
fi

# Extract notification ID
NOTIFICATION_ID=$(echo "$RESPONSE_BODY" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "✓ Created notification with ID: $NOTIFICATION_ID"

# Extract title and body for confirmation
TITLE=$(echo "$RESPONSE_BODY" | grep -o '"title":"[^"]*"' | head -1 | cut -d'"' -f4)
BODY=$(echo "$RESPONSE_BODY" | grep -o '"body":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "Title: $TITLE"
echo "Body: $BODY"

# Step 2: Send to device if token provided
if [ ! -z "$DEVICE_TOKEN" ]; then
  echo -e "\n2. Sending notification to device..."
  SEND_RESPONSE=$(curl -s -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "{\"token\":\"$DEVICE_TOKEN\"}" \
    "$SERVER_URL/api/notifications/$NOTIFICATION_ID/send-fcm")
    
  HTTP_CODE=${SEND_RESPONSE: -3}
  RESPONSE_BODY=${SEND_RESPONSE%???}
  
  if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Successfully sent notification to device via FCM"
    
    # Mark as sent in database
    curl -s -X POST "$SERVER_URL/api/notifications/$NOTIFICATION_ID/send" > /dev/null
    echo "✓ Marked notification as sent in database"
  else
    echo "✗ Failed to send notification via FCM: $HTTP_CODE"
    echo "$RESPONSE_BODY"
  fi
else
  echo -e "\nNote: No device token provided. To send to device, run:"
  echo "DEVICE_TOKEN=\"your_device_token\" ./test_notification.sh"
fi

echo -e "\nTest notification workflow completed!"