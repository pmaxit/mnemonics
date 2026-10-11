# Mnemonics — Native iOS (SwiftUI) Conversion Plan

Source: the former Flutter app (~38k lines Dart; removed from the tree — see git history before the native iOS migration). Target: SwiftUI, iOS 17+, no cross-platform layer.
Backend (`backend_api`, Railway) is **unchanged** — the native app talks to the same REST API, so
progress is shared with the Flutter app during the migration.

## Architecture
| Flutter | Native |
|---|---|
| Riverpod providers | `@Observable` stores injected via `.environment` |
| GoRouter | `NavigationStack` + typed `Route` enum; `TabView` shell |
| Hive (`user_word_data`, `user_settings`) | `ProgressStore` (JSON file, actor) in `MnemonicsCore`; SwiftData later if needed |
| Freezed models | `Codable` structs |
| fl_chart | Swift Charts |
| chewie/video_player | AVKit `VideoPlayer` |
| firebase_auth / google_sign_in / apple | FirebaseAuth SPM + `AuthenticationServices` |
| firebase_messaging + local notifs | `UNUserNotificationCenter` (local review reminders first) + APNs/FCM |
| google_generative_ai (AI mnemonic) | URLSession to Gemini REST, or backend |

Layout: `MnemonicsCore/` is a SwiftPM package (pure Swift, unit-tested with `swift test`, no UI);
`Mnemonics/` is the app target; `project.yml` generates the Xcode project (XcodeGen).

## Status
Phases 1–5 are written (see `PARITY.md` for the screen-by-screen matrix, deliberate differences and unreachable Flutter code).
Phase 6 (polish, widgets, App Store assets) and **first run on a simulator/device** are outstanding.

## Run it
```bash
brew install xcodegen      # once
xcodegen && open Mnemonics.xcodeproj
```
Set a signing team, enable Sign in with Apple + Push in the target, and (optionally) set `OPENROUTER_API_KEY` for the AI features.
Core logic tests: open `MnemonicsCore` in Xcode and run the `MnemonicsCore` scheme (Swift Testing), or `cd MnemonicsCore && swift test` once the Xcode license is accepted.

## Layout
- `MnemonicsCore/` — pure Swift package: models, SM-2, statistics, session logic, study-plan models, API client, progress store, notifications inbox, AI/translation. No UI.
- `Mnemonics/App` — `AppModel` (the Riverpod-provider replacement), router, auth, notification hub, reminders.
- `Mnemonics/Features/*` — SwiftUI screens grouped like the Flutter tabs.
- `Mnemonics/Common` — design system (colors, spacing, wave background, cards).
## Feature map (Flutter → Swift) and phases

### Phase 1 — Core learning loop  ✅ scaffolded in this folder
- Domain: `VocabularyWord`, `UserWordData`, `LearningStage`, `WordDifficulty`, `UserSettings` (Core/Models)
- **Spaced repetition (SM-2)** `SpacedRepetition.calculateNextReview` — exact port, same tests
- **Word recommendation** (level-aware "My Words")
- `APIClient` (vocabulary, word_sets, user_progress get/post, learned_status, notes, user_profile)
- `ProgressStore` — records every word you learn + schedules `nextReview`
- UI: tab shell (Home / Practice / Timer / Profile), word list, word detail (meaning, mnemonic, examples,
  synonyms/antonyms, notes, "Mark learned"), **flashcard review session** (hard/medium/easy → SM-2), due-today queue
- `ReviewReminders`: local notification when words become due ("repeat after a certain time")

### Phase 2 — Home, discovery, practice depth
- Home dashboard, word sets, category screens, knowledge tree (`knowledge_tree_*`)
- Fill-in-the-blank card, phrase usages (`PhraseUsage` parsing from `vocabulary_word.dart`)
- Practice tab: session setup (duration/mode), countdown, completion summary, timer screen
- Practice detail screens: streak, words today, total words, accuracy, learning stages, breakdown

### Phase 3 — Study plans
- Study plan wizard, calendar heatmap, today's plan, day detail (`study_session`, `study_plan`);
  endpoints `/study-plan/*`

### Phase 4 — Profile, stats, settings
- Statistics providers (profile/unified/detailed), achievements, difficulty stats, insights, activity log,
  goal summary, daily goal, language preferences, profile settings, data migration

### Phase 5 — Auth, onboarding, notifications, media
- Splash, welcome, login, signup, Google/Apple sign-in, onboarding wizard (`/onboarding/curate`)
- Push (APNs), notification poller/banner/bell, AI mnemonic/insights, video + image loading

### Phase 6 — Polish & release
- Design system port (colors/typography from `common/design`), dark mode, animated tab bar, haptics,
  widgets/Live Activity (optional), App Store assets, TestFlight

## Decisions / assumptions (change if wrong)
- iOS 17+, iPhone first, SwiftUI + Observation, Swift Concurrency.
- Same backend + Firebase project; bundle ID `com.mnemonics.app` (set to your real one).
- Phase 1 runs offline with a bundled `vocabulary.json` fallback and syncs when a user id exists.

## Environment note
This Mac currently lacks full Xcode (partial `Xcode.appdownload`). Core package can be built/tested with
`swift test`; the app target needs Xcode: `brew install xcodegen && xcodegen && open Mnemonics.xcodeproj`.
