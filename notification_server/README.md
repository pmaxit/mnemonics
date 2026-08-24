# Mnemonics Notification Server

This server handles notifications for the Mnemonics language learning app. It provides APIs for sending notifications, analyzing user activity, and generating AI-powered notification suggestions.

## Features

- REST API for notification management
- Activity log analysis
- AI-powered notification suggestions
- Dashboard statistics
- Demo data seeding
- FCM HTTP v1 push to phones (topic `all_users` plus registered device tokens)

## API Endpoints

### Notifications

- `POST /api/notifications` - Create a new notification
- `GET /api/notifications` - List notifications
- `POST /api/notifications/{id}/send` - Mark sent **and** push via FCM
- `POST /api/notifications/{id}/send-fcm` - Push to an explicit device token
- `POST /api/devices/register` - Flutter app registers its FCM token

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
- `GET /api/health` - Health check (`fcmConfigured`, `registeredDevices`)

## Sending notifications to phones

Admin **Send** calls `POST /api/notifications/{id}/send`. That endpoint:

1. Pushes FCM HTTP v1 to topic `all_users` (broadcast) or to tokens registered for `targetUserId`
2. Marks the row `sent` so open apps can also pick it up by polling

The Flutter app:

1. Requests notification permission
2. Subscribes to topic `all_users`
3. Registers its token at `POST /api/devices/register`

### Firebase credentials (required for lock-screen push)

Legacy `FCM_SERVER_KEY` / `https://fcm.googleapis.com/fcm/send` no longer works. Use a Firebase **Admin SDK service account** for project `mnemonics-76ca2`:

1. Firebase Console → Project settings → Service accounts → Generate new private key
2. Set one of these on the notification server:

```bash
# Raw JSON (Railway variable). Keep the private_key newlines.
FIREBASE_SERVICE_ACCOUNT='{"type":"service_account","project_id":"mnemonics-76ca2",...}'

# Or base64 of the downloaded JSON file (easier in Railway UI):
FIREBASE_SERVICE_ACCOUNT_BASE64="$(base64 -i service-account.json | tr -d '\n')"
```

Optional: `FCM_PROJECT_ID=mnemonics-76ca2` if the JSON has no `project_id`.

Also in Firebase Console → Project settings → Cloud Messaging, upload an **APNs Authentication Key** (.p8) for iOS.

Restart / redeploy the server after setting the variable. `GET /api/health` should show `"fcmConfigured": true`.

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
- `FIREBASE_SERVICE_ACCOUNT` or `FIREBASE_SERVICE_ACCOUNT_BASE64` - FCM send credentials

## Seeding Demo Data

POST to `/api/seed` to populate with sample notifications and activity logs.
