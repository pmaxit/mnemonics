# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

## Project Overview

"Mnemonics" is a native iOS (SwiftUI, iOS 17+) vocabulary-learning app built around mnemonics and spaced repetition (SM-2).
It was ported from a Flutter app; the Flutter client has been removed (it remains in git history before the "native iOS" commit).
Server components (`backend_api`, `notification_server`, `admin_dashboard`) are unchanged and shared.

## Layout

- `MnemonicsCore/` — pure Swift package (no UI): models, SM-2, statistics, session logic, study-plan models, API client, progress store, notification inbox, AI/translation. Tests in `MnemonicsCore/Tests`.
- `Mnemonics/` — the app target. `App/` (AppModel, router, auth, notifications, reminders), `Features/*` (Home, Progress, Focus, Profile, StudyPlan, Auth), `Common/` (design system), `Resources/`.
- `project.yml` — XcodeGen spec. The `.xcodeproj` is generated and git-ignored.
- `PLAN.md`, `PARITY.md` — migration plan and Flutter↔native parity matrix (incl. deliberate differences).
- `backend_api/` (Flask + Postgres, Railway), `notification_server/`, `admin_dashboard/`, `scripts/`, `assets/` (vocabulary data/images used by seeding scripts).

## Commands

```bash
brew install xcodegen
xcodegen && open Mnemonics.xcodeproj      # generate + open the project
cd MnemonicsCore && swift test            # core logic tests (needs Xcode license accepted)
```

## Architecture

- State: `@Observable` `AppModel` injected via `.environment` (replaces Riverpod). Navigation: one `NavigationStack` per tab + typed `Route` enum (`App/Router.swift`).
- Persistence: `ProgressStore` (JSON in Application Support; wire-compatible with `/user_progress`), settings in `UserDefaults`.
- Auth: Firebase Auth + Google + Apple (`AuthService`); falls back to a local guest when Firebase isn't configured.
- Same bundle id (`com.example.mnemonics`) and `GoogleService-Info.plist` as the old Flutter app.
- Core logic goes in `MnemonicsCore` with tests; keep views thin.
