# Mnemonics

A native iOS app (SwiftUI) that helps you learn vocabulary through mnemonics and spaced repetition.

- **Learn** words with bilingual mnemonics, images, video, phrase context and fill-in-the-blank recall.
- **Repeat** them on an SM-2 schedule; local notifications remind you when words are due.
- **Track** streaks, accuracy, stages and a knowledge tree; follow adaptive daily plans and multi-day study plans.

## Build

```bash
brew install xcodegen
xcodegen && open Mnemonics.xcodeproj
```

Set a signing team, enable Sign in with Apple and Push, and optionally set `OPENROUTER_API_KEY` (AI features).
Firebase config lives in `Mnemonics/Resources/GoogleService-Info.plist`.

## Repository

| Path | What |
|---|---|
| `Mnemonics/` | iOS app target (SwiftUI) |
| `MnemonicsCore/` | Pure-Swift logic package + tests |
| `backend_api/` | Flask API (Railway) |
| `notification_server/` | Admin push notification service |
| `admin_dashboard/` | Admin web UI |
| `PLAN.md`, `PARITY.md` | Migration plan and Flutter parity notes |

The previous Flutter client is available in git history (commits before the native iOS migration).
