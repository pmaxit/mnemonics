# Mnemonics Notification Server

This server handles notifications for the Mnemonics language learning app. It provides APIs for sending notifications, analyzing user activity, and generating AI-powered notification suggestions.

## Features

- REST API for notification management
- Activity log analysis
- AI-powered notification suggestions
- Dashboard statistics
- Demo data seeding

## API Endpoints

### Notifications

- `POST /api/notifications` - Create a new notification
- `GET /api/notifications` - List notifications
- `POST /api/notifications/{id}/send` - Mark notification as sent

### Activity Logs

- `POST /api/activity-logs` - Log user activity
- `GET /api/activity-logs` - List activity logs
- `GET /api/activity-logs/user/{userId}` - Get logs for a specific user

### Agent Suggestions

- `GET /api/suggestions` - List notification suggestions
- `POST /api/agent/analyze` - Trigger AI analysis of activity logs
- `POST /api/suggestions/{id}/apply` - Apply a suggestion (creates notification)
- `POST /api/suggestions/{id}/discard` - Discard a suggestion

### Dashboard

- `GET /api/stats` - Get dashboard statistics
- `GET /api/health` - Health check endpoint

## Sending Notifications to the Flutter App

To send notifications that will be received by the Flutter app, you need to use Firebase Cloud Messaging (FCM). 

The notification server stores notifications in its database, but to actually deliver them to devices, you need to:

1. Get the FCM device token from the Flutter app
2. Send the notification through the notification server's FCM integration
3. The server will forward the notification to FCM which delivers it to the device

### Using the FCM Endpoint

To send a notification via FCM, use the following endpoint:

```
POST /api/notifications/{id}/send-fcm
```

Payload:
```json
{
  "token": "device_fcm_token"
}
```

### Setting up FCM Credentials

To enable FCM functionality, you need to:

1. Get your Firebase project's Server Key from the Firebase Console
   - Go to Project Settings > Cloud Messaging
   - Copy the Server Key from the "Project credentials" section
2. Set the `FCM_SERVER_KEY` environment variable with your server key
3. Restart the server

Example:
```bash
export FCM_SERVER_KEY="YOUR_FCM_SERVER_KEY_HERE"
dart run bin/server.dart
```

## Running the Server

```bash
dart pub get
dart run bin/server.dart
```

Environment variables:
- `PORT` - Server port (default: 8080)
- `HOST` - Server host (default: 0.0.0.0)
- `DATA_DIR` - Data storage directory (default: data)
- `OPENROUTER_API_KEY` - API key for AI suggestions (optional)

## Seeding Demo Data

POST to `/api/seed` to populate with sample notifications and activity logs.