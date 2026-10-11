# Flutter ↔ Native iOS parity matrix

Source of truth: the former Flutter app (removed from the tree; paths like `lib/…` refer to git history before the native iOS migration). Status legend:
✅ ported · ⚠️ ported with a deliberate difference (see notes) · ⛔ not ported (reason given)

**Verification legend** (be skeptical of "✅"):
- *Logic* items live in `MnemonicsCore` and are checked by a compiled test harness (and a Swift Testing suite for Xcode).
- *UI* items type-check against the macOS SDK with iOS-only modifiers shimmed. **None has been launched on a simulator or device** — Xcode is not fully installed on this machine yet.

## 1. Screens & routes

| Flutter (`lib/…`) | Native | Status |
|---|---|---|
| `splash_screen` | `Features/Auth/SplashView` (logo, tagline, pulsing CTA) | ✅ |
| `welcome_screen` | `AuthViews.WelcomeView` | ✅ |
| `login_screen` (email, Google, Apple) | `AuthViews.LoginView` + `AuthService` | ✅ (forgot-password is a stub in Flutter too) |
| `signup_screen` | `AuthViews.SignupView` | ✅ |
| `onboarding_wizard_screen` | `OnboardingWizardView` + `Onboarding` (Core) | ✅ |
| `main_scaffold` (app bar, bell, settings) | `RootView.MainTabsView` + `AppToolbar` | ✅ |
| `bottom_nav` (animated pill: Home/Progress/Focus/Profile) | `AnimatedTabBar` | ⚠️ SwiftUI `matchedGeometryEffect` pill; not pixel-identical. Adds an orange "words due" dot on Focus (new) |
| `animated_wave_background` | `MBackground` / `WaveShape` | ✅ |
| `home_screen` (greeting, My Words, tree, pathfinding, sets) | `HomeView` | ✅ |
| `my_words_list_screen` | `MyWordsListView` | ✅ |
| `learn_word_list_screen` (search, sort, grouped) | `WordListView` | ⚠️ filter chips for difficulty/category (unused UI state in Flutter) omitted |
| `learn_word_detail_screen` (pager, learned slider, explorer, notes, rate bar) | `WordDetailPagerView` | ✅ |
| `fill_in_blank_card` | `FillInBlankCard` | ✅ |
| `knowledge_tree_widget` / `knowledge_tree_detail_screen` | `KnowledgeTreeViews` (Canvas) | ⚠️ tree shape uses a seeded RNG, not Dart's `Random(42)` |
| `progress_overview_screen` (Progress tab) | `ProgressOverviewView` | ✅ |
| `practice/details/*` streak, words-today, total-words, accuracy, learning-stages, breakdown | `Features/Progress/*` | ⚠️ see §3 |
| `learning_session_screen` (Focus tab) + setup/countdown/flashcard/completion widgets | `Features/Focus/*` | ✅ |
| `todays_study_plan_card` / `todays_study_plan_screen` | `TodaysPlanViews` | ✅ |
| `study_plan_wizard_screen` | `StudyPlanWizardView` | ✅ |
| `study_calendar_screen` + `calendar_heatmap_widget` | `StudyCalendarView` | ✅ |
| `study_day_detail_screen` | `StudyDayDetailView` | ✅ |
| `enhanced_profile_screen` (+ header / stats / complexity widgets) | `ProfileView` | ✅ |
| `profile_settings_screen` + widget | `ProfileSettingsView` | ✅ (export/import: Flutter rows are no-ops; native implements them) |
| `detailed_word_statistics_screen` | `DetailedWordStatisticsView` | ✅ |
| `test_notification_screen` | `TestNotificationView` | ✅ |
| notification bell / banner / display / listener | `NotificationViews` + `NotificationHub` | ✅ |

### Flutter code that is unreachable (dead) and therefore not ported
`practice/timer_screen` + `timer_provider` + `animated_timer_widgets` + `animated_flash_card` (superseded by `learning_session_screen`),
`profile_screen` (old), `activity_log_screen`, `category_detail_screen`, `daily_goal_screen`, `goal_summary_screen`,
`language_preferences_screen`, `achievements_widget`, `learning_insights_widget`, `profile_statistics_provider` (only the unified provider is wired to the UI),
`features/study_plan/*` (older duplicate of `study_session`), `create_plan_dialog`, `google_sheets_service`.
Say if you want any of these anyway.

## 2. Data, services & API

| Flutter | Native | Status |
|---|---|---|
| Hive `user_word_data` | `ProgressStore` (JSON, actor); wire format identical to `/user_progress` | ✅ |
| Hive `review_activity` | `ProgressStore.activities` | ✅ |
| Hive `user_settings` | `UserSettings` in `UserDefaults` | ✅ |
| `SpacedRepetitionManager` (SM-2) | `SpacedRepetition` | ✅ test-matched to Flutter's tests |
| `vocabulary_word.dart` context logic (sentences, phrase usages, collocations) | `WordContext.swift` | ✅ |
| `MysqlDatabaseService` row parsing, 1 h cache, JSON fallback | `VocabularyParsing`, `AppModel.loadVocabulary` | ✅ |
| `WordRecommendation` | `WordRecommendation` | ✅ (incl. last-resort fill, `parseLevels`) |
| statistics_provider (Progress tab) | `StatisticsCalculator.calculate` | ✅ |
| unified_statistics_provider (Profile tab) | `StatisticsCalculator.profileSummary` | ✅ |
| detailed_statistics_provider | `DetailedWords` | ✅ |
| study-plan repository (6 endpoints) | `APIClient` (StudyPlan.swift) | ✅ |
| notes / learned_status / user_profile / onboarding-curate / reset / settings-summary | `APIClient` | ✅ |
| `AIService` (OpenRouter) | `AIService` | ✅ needs `OPENROUTER_API_KEY` |
| Hindi translation (`translator`) | `Translator` (same Google endpoint) | ✅ |
| Firebase Auth + Google + Apple | `AuthService` (FirebaseAuth, GoogleSignIn, AuthenticationServices) | ✅ untested without Xcode |
| FCM + APNs + topic `all_users` + device register | `NotificationHub` + `AppDelegate` | ✅ untested |
| `NotificationPoller` (5 s) | `NotificationHub.poll` | ✅ |
| Review reminders ("repeat after a time") | `ReviewReminders` (local notifications at SM-2 due dates) | ➕ new; not in Flutter |
| `video_player` + `chewie` | AVKit `VideoPlayer` | ✅ |
| `firebase_options.dart`, `desktop_compat` | `GoogleService-Info.plist`; guest user when Firebase is absent | ✅ |

### Not ported (server side — shared as-is)
`backend_api/`, `notification_server/`, `admin_dashboard/`. The native app talks to the same Railway deployments.

## 3. Deliberate differences (fixes to Flutter bugs / quirks)

Each of these was a conscious call; flip any back if you want bug-for-bug parity.

1. **Enum-vs-string comparisons.** Flutter compares `UserWordData.learningStage` (an enum) to strings like `'new'`/`'learning'`.
   These are always unequal, so Flutter's "New Words" session mode, the Total-Words stage filter, and "learned" detection in several detail screens silently misbehave.
   Native uses the intended enum comparison.
2. **Hard/Medium/Easy from the word-detail screen** counts "correct" as *not hard* (same as the Focus session). Flutter's detail path counts only *easy*, and never sets `hasBeenTested`, so those words were missed by Progress-tab totals.
3. **Streak screen** shows real weekly activity and the real longest streak; Flutter fakes "active" for every past weekday and uses `max(streak, 7)` for "Personal Best".
4. **Progress "Learned Today"** uses `lastReviewedAt` (as Flutter's Progress tab does) while the *Words-Today* list uses `firstLearnedAt` (as Flutter does) — the two numbers can differ in both apps.
5. **Sign-out / account switch** clears local progress (as Flutter), then re-syncs from `/user_progress`. On a normal relaunch native *merges by newest `lastReviewedAt`* rather than wiping.
6. `gamificationProvider` is referenced by Flutter's detail screen but not defined anywhere in the repo; native has no XP-per-review.

## 4. Known gaps / needs your input

- **Nothing here has been run on a device.** First `xcodegen && open Mnemonics.xcodeproj`, build, and walk the flows in the checklist below.
- Firebase iOS SDK and GoogleSignIn are SPM dependencies resolved on first build (needs network).
- Provisioning/signing team, Sign in with Apple capability, and push (APNs key in Firebase) must be set for the `com.example.mnemonics` bundle id.
- App icon reuses the Flutter `AppIcon.appiconset`.
- Video/images/mnemonics come from the live API, so most screens need network on first launch (bundled `vocabulary.json` is a 13-word offline fallback, as in Flutter).

## 5. Smoke-test checklist (on a simulator)

1. Launch → splash → tap arrow → welcome → sign up → onboarding quiz → lands on Home with My Words.
2. Open a word → rate **Easy** → toast "Next review: 1 day(s)" → Progress tab "Total Learned" increments, streak = 1.
3. Rate the same word **Hard** → next review "1 day(s)", accuracy drops; Settings → Reset Progress clears it.
4. Focus tab → 5 min / Due for Review → countdown → flip, rate, skip, pause/resume, end → completion summary.
5. Background the app; confirm a local "Time to review" notification is scheduled (Settings → iOS Notifications).
6. Study plan wizard → calendar → open a day → Mark Complete.
7. Dark mode toggle in Settings; log out / log in restores progress from the server.
