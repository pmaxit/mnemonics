# Mnemonics Notification Server

AI-powered notification backend for the Mnemonics vocabulary learning app.

## Features

- **Activity Log API** — Ingest user study activity (`POST /api/activity-logs`)
- **Notifications API** — Create / list / send notifications (`/api/notifications`)
- **Agent Suggestions** — Rule-based + AI-backed suggestions are generated from activity logs
- **Admin Stats** — Aggregate counters for the dashboard (`GET /api/stats`)
- CORS enabled for the admin dashboard

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /api/stats | Dashboard stats |
| GET | /api/activity-logs?limit=&offset= | Recent activity logs |
| GET | /api/activity-logs/types | Counts per activity type |
| GET | /api/activity-logs/user/:userId | Logs for a user |
| POST | /api/activity-logs | Create a log entry |
| GET | /api/notifications?limit=&schemeType=&status= | List notifications |
| POST | /api/notifications | Create a notification |
| POST | /api/notifications/:id/send | Mark a notification as sent |
| GET | /api/suggestions?pending=true | List suggestions |
| POST | /api/agent/analyze | Run the agent to generate suggestions |
| POST | /api/suggestions/:id/apply | Apply a suggestion as a notification |
| POST | /api/suggestions/:id/discard | Discard a suggestion |
| GET | /api/health | Health check |
| POST | /api/seed | Seed demo data |

## Run locally

```bash
dart pub get
dart run bin/server.dart
# or: OPENROUTER_API_KEY=... dart run bin/server.dart
```

Set `OPENROUTER_API_KEY` to enable AI-backed agent suggestions; without it the server falls back to a rule-based agent.

## Deploy on Railway

1. Create a new Railway service from this folder.
2. Set env vars: `OPENROUTER_API_KEY`, optional `AI_MODEL`, `DATA_DIR` (defaults to `data`).
3. Railway will run the `Dockerfile` (Dart AOT compile).

## Environment

| Variable | Default | Description |
|----------|---------|-------------|
| PORT | 8080 | HTTP port |
| HOST | 0.0.0.0 | Bind host |
| DATA_DIR | data | File persistence directory |
| OPENROUTER_API_KEY | — | Enable AI agent (optional) |
| AI_MODEL | google/gemma-4-12b-instruct | Model for the agent |
