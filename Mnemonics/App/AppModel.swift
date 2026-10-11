import Foundation
import Observation
import SwiftUI
import MnemonicsCore

enum ThemePreference: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var scheme: ColorScheme? { self == .system ? nil : (self == .dark ? .dark : .light) }
    var title: String { rawValue.capitalized }
}

struct WordSetInfo: Codable, Identifiable, Hashable {
    let id: String, name: String, description: String
}

/// Replaces the Riverpod providers (vocabulary, user data, profile, statistics, study plans, settings).
@Observable @MainActor
final class AppModel {
    // MARK: Data
    private(set) var words: [VocabularyWord] = []
    private(set) var wordSets: [WordSetInfo] = []
    private(set) var progress: [String: UserWordData] = [:]
    private(set) var activities: [ReviewActivity] = []
    private(set) var profile: UserProfile?
    private(set) var isLoading = false
    private(set) var loadError: String?
    private(set) var stats = LearningStatistics()
    private(set) var profileSummary = ProfileSummary()

    // MARK: Toasts (SnackBar equivalent)
    struct Toast: Equatable, Identifiable { let id = UUID(); let text: String; let isError: Bool }
    private(set) var toast: Toast?
    func showToast(_ text: String, isError: Bool = false) {
        let t = Toast(text: text, isError: isError); toast = t
        Task { try? await Task.sleep(nanoseconds: 3_500_000_000); if toast == t { toast = nil } }
    }

    // MARK: Study plans
    private(set) var plans: [StudyPlan] = []
    private(set) var todaysPlan: DailyStudyPlan?
    private(set) var planError: String?
    private(set) var isLoadingPlan = false

    // MARK: Settings (persisted)
    var settings: UserSettings { didSet { saveSettings() } }
    var theme: ThemePreference { didSet { UserDefaults.standard.set(theme.rawValue, forKey: "theme") } }

    /// Lives here (not in the view) so a running Focus session survives tab switches / view rebuilds.
    let session = LearningSessionModel()
    let auth = AuthService()
    private let store = ProgressStore()
    let api = APIClient()
    let ai = AIService(apiKey: Bundle.main.object(forInfoDictionaryKey: "OPENROUTER_API_KEY") as? String ?? "")
    private let reminders = ReviewReminders()
    private var vocabFetchedAt: Date?
    private var loadedFor: String?

    init() {
        if let d = UserDefaults.standard.data(forKey: "user_settings"), let s = try? JSONDecoder().decode(UserSettings.self, from: d) { settings = s }
        else { settings = UserSettings() }
        theme = ThemePreference(rawValue: UserDefaults.standard.string(forKey: "theme") ?? "") ?? .system
    }
    private func saveSettings() {
        if let d = try? JSONEncoder().encode(settings) { UserDefaults.standard.set(d, forKey: "user_settings") }
    }

    var userID: String { auth.user?.uid ?? "default" }
    var remoteUserID: String? { auth.isGuest ? nil : auth.user?.uid }

    // MARK: Derived

    func data(for word: String) -> UserWordData? { progress[word] }
    var learnedWords: Set<String> { Set(progress.values.filter(\.isLearned).map(\.word)) }
    var enabledWordSetIDs: Set<String> { profile?.enabledSetIDs ?? [] }

    /// Words the user started (rated or marked) — the "learning" list.
    var learningWords: [VocabularyWord] { words.filter { progress[$0.word]?.firstLearnedAt != nil } }

    var dueWords: [VocabularyWord] {
        let now = Date()
        return words.filter { progress[$0.word]?.isDue(at: now) == true && progress[$0.word]?.isLearned != true }
            .sorted { (progress[$0.word]?.nextReview ?? .distantFuture) < (progress[$1.word]?.nextReview ?? .distantFuture) }
    }

    var recommendedWords: [VocabularyWord] {
        WordRecommendation.recommend(available: words, learned: learnedWords, levels: profile?.levels ?? [1],
                                     enabledCategories: enabledWordSetIDs)
    }

    var visibleWordSets: [WordSetInfo] {
        let enabled = enabledWordSetIDs
        return enabled.isEmpty ? wordSets : wordSets.filter { enabled.contains($0.id) }
    }

    func words(inSet id: String) -> [VocabularyWord] {
        words.filter { $0.category == id }
    }

    func recalcStats() {
        stats = StatisticsCalculator.calculate(vocab: words, userData: Array(progress.values), activities: activities)
        profileSummary = StatisticsCalculator.profileSummary(vocab: words, userData: Array(progress.values), activities: activities)
    }

    // MARK: Loading

    func bootstrap() async {
        guard auth.isReady else { return }
        let uid = userID
        if loadedFor == uid, !words.isEmpty { return }
        isLoading = true; loadError = nil
        defer { isLoading = false }

        wordSets = Self.bundledWordSets()
        if loadedFor != nil, loadedFor != uid { await store.resetAll() }   // user switched → clear (as Flutter does on sign-in/out)
        await refreshLocal()

        words = Self.bundledVocabulary()
        recalcStats()
        await loadVocabulary(force: true)

        if let remote = remoteUserID {
            profile = try? await api.userProfile(userID: remote)
            await syncProgressFromRemote(remote)
            await loadVocabulary(force: true)   // re-fetch filtered by profile's enabled sets
        } else {
            var p = UserProfile(userId: uid); p.hasCompletedOnboarding = true; p.learningGoal = "general"; profile = p
        }
        loadedFor = uid
        await reminders.requestAuthorizationIfNeeded()
        await rescheduleReminders()
        recalcStats()
    }

    func loadVocabulary(force: Bool = false) async {
        if !force, let t = vocabFetchedAt, Date().timeIntervalSince(t) < 3600, !words.isEmpty { return }
        do {
            let fetched = try await api.vocabularyRows(userID: remoteUserID)
            if !fetched.isEmpty { words = fetched; vocabFetchedAt = Date() }
        } catch {
            loadError = words.isEmpty ? "Couldn't load vocabulary: \(error.localizedDescription)" : nil
            if words.isEmpty { words = Self.bundledVocabulary() }
        }
        recalcStats()
    }

    private func syncProgressFromRemote(_ uid: String) async {
        guard let remote = try? await api.userProgress(userID: uid), !remote.isEmpty else { return }
        for item in remote {
            let local = progress[item.word]
            if (local?.lastReviewedAt ?? .distantPast) <= (item.lastReviewedAt ?? .distantPast) { await store.save(item) }
        }
        await refreshLocal()
    }

    private func refreshLocal() async {
        progress = Dictionary(uniqueKeysWithValues: await store.all().map { ($0.word, $0) })
        activities = await store.allActivities()
    }

    private static func bundledVocabulary() -> [VocabularyWord] {
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([VocabularyWord].self, from: data)) ?? []
    }
    private static func bundledWordSets() -> [WordSetInfo] {
        struct Wrap: Decodable { let sets: [WordSetInfo] }
        guard let url = Bundle.main.url(forResource: "word_sets", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode(Wrap.self, from: data))?.sets ?? []
    }

    // MARK: Recording & repeating

    /// Flashcard / detail rating → SM-2 (`_updateUserWordData`), logs a review activity.
    @discardableResult
    func review(_ word: String, rating: ReviewRating) async -> UserWordData {
        let item = await store.review(word: word, rating: rating)
        await didChange(item)
        activities = await store.allActivities()
        recalcStats()
        return item
    }

    func markLearned(_ word: String, _ learned: Bool) async {
        await store.markLearned(word: word, learned)
        if let item = await store.get(word) { await didChange(item) }
        recalcStats()
        if let remote = remoteUserID { try? await api.saveLearnedStatus(userID: remote, word: word, learned: learned) }
    }

    func saveNotes(_ word: String, _ notes: String) async {
        await store.setNotes(word: word, notes)
        if let item = await store.get(word) { progress[word] = item }
    }
    func syncNotesToCloud(_ word: String, _ notes: String) async -> Bool {
        guard let remote = remoteUserID else { return true }
        return (try? await api.saveNotes(userID: remote, word: word, notes: notes)) != nil
    }
    func cloudNotes(_ word: String) async -> String? {
        guard let remote = remoteUserID else { return nil }
        let n = try? await api.notes(userID: remote, word: word)
        return (n?.isEmpty == false) ? n : nil
    }
    func cloudLearned(_ word: String) async -> Bool? {
        guard let remote = remoteUserID else { return nil }
        return try? await api.learnedStatus(userID: remote, word: word)
    }

    func resetWord(_ word: String) async {
        await store.resetWord(word)
        await refreshLocal(); recalcStats(); await rescheduleReminders()
    }

    func resetAllProgress() async {
        await store.resetAll()
        if let remote = remoteUserID { try? await api.resetUser(userID: remote) }
        await refreshLocal(); recalcStats(); await rescheduleReminders()
    }

    private func didChange(_ item: UserWordData) async {
        progress[item.word] = item
        recalcStats()
        await rescheduleReminders()
        if let remote = remoteUserID { try? await api.saveProgress(userID: remote, item) }
    }

    private func rescheduleReminders() async {
        await reminders.reschedule(for: Array(progress.values.filter { !$0.isLearned }))
    }

    // MARK: Profile

    func updateProfile(_ p: UserProfile) async {
        profile = p
        try? await api.saveUserProfile(p)
        await loadVocabulary(force: true)
    }
    func completeOnboarding(goal: String, score: Int) async {
        guard let remote = remoteUserID else { return }
        try? await api.curateOnboarding(userID: remote, goal: goal, score: score)
        profile = (try? await api.userProfile(userID: remote)) ?? profile
        await loadVocabulary(force: true)
    }
    func settingsSummary() async -> String {
        guard let p = profile else { return "Select your categories and level to get started." }
        return await api.settingsSummary(level: p.vocabularyLevel, enabledSets: p.enabledWordSets)
    }

    /// "Restart Onboarding (Test)".
    func markOnboardingIncomplete() {
        guard var p = profile else { return }
        p.hasCompletedOnboarding = false; profile = p
    }

    /// Export / import of learning history (the Settings "Data Management" rows).
    func exportProgressData() -> Data {
        struct Export: Encodable { let progress: [UserWordData]; let activities: [ReviewActivity] }
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601; enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        return (try? enc.encode(Export(progress: Array(progress.values), activities: activities))) ?? Data()
    }
    func importProgress(from url: URL) async -> Bool {
        struct Import: Decodable { let progress: [UserWordData]; let activities: [ReviewActivity]? }
        let scoped = url.startAccessingSecurityScopedResource(); defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url) else { return false }
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        guard let imp = try? dec.decode(Import.self, from: data) else { return false }
        for p in imp.progress { await store.save(p) }
        for a in imp.activities ?? [] { await store.recordActivity(a) }
        await refreshLocal(); recalcStats(); await rescheduleReminders()
        return true
    }

    func signOut() async {
        auth.signOut()
        await store.resetAll()
        progress = [:]; activities = []; profile = nil; plans = []; todaysPlan = nil; loadedFor = nil
        recalcStats()
    }

    // MARK: Study plans

    var dailyMinutes: Int { min(60, max(8, settings.dailyGoal)) }

    func loadTodaysPlan() async {
        guard let remote = remoteUserID else { planError = "Sign in to see your adaptive plan."; return }
        isLoadingPlan = true; planError = nil
        defer { isLoadingPlan = false }
        do { todaysPlan = try await api.todaysPlan(userID: remote, minutes: dailyMinutes) }
        catch { planError = error.localizedDescription }
    }
    func loadPlans() async {
        guard let remote = remoteUserID else { return }
        do { plans = try await api.activePlans(userID: remote); planError = nil } catch { planError = error.localizedDescription }
    }
    func createPlan(totalWords: Int, numDays: Int, wordsPerDay: Int, title: String?, difficultyPref: String, dailyCommitment: String) async throws -> StudyPlan {
        guard let remote = remoteUserID else { throw AuthError.message("User not authenticated") }
        let plan = try await api.createStudyPlan(userID: remote, totalWords: totalWords, numDays: numDays, wordsPerDay: wordsPerDay,
                                                 title: title, difficultyPref: difficultyPref, dailyCommitment: dailyCommitment)
        await loadPlans()
        return plan
    }
    func setDayStatus(_ day: Int, _ status: DayStatus) async {
        guard let remote = remoteUserID else { return }
        try? await api.updateDayStatus(userID: remote, day: day, status: status)
        await loadPlans()
    }
    func completeToday(_ plan: DailyStudyPlan) async {
        guard let remote = remoteUserID else { return }
        try? await api.completeTodaysPlan(userID: remote, wordsCompleted: plan.incentive.dailyGoalWords, points: plan.incentive.pointsIfCompleted)
        await loadTodaysPlan(); await loadPlans()
    }
    func deletePlan(_ id: String) async {
        try? await api.deletePlan(id: id)
        await loadPlans()
    }
}
