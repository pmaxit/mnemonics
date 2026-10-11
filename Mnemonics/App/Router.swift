import SwiftUI
import Observation
import MnemonicsCore

enum AppTab: Int, CaseIterable, Identifiable {
    case home, progress, focus, profile
    var id: Int { rawValue }
    var title: String { ["Home", "Progress", "Focus", "Profile"][rawValue] }
    var symbol: String { ["house", "chart.bar", "timer", "person"][rawValue] }
    var activeSymbol: String { ["house.fill", "chart.bar.fill", "timer", "person.fill"][rawValue] }
}

/// Mirrors the GoRouter route table in lib/app.dart plus the profile sub-screens.
enum Route: Hashable {
    case wordList(setID: String)
    case flashcards(words: [VocabularyWord], initialIndex: Int)
    case myWords
    case knowledgeTree
    // Practice (Progress tab) details
    case streak, wordsToday, totalWords, accuracy
    case learningStage(String)
    case breakdown(type: String, filter: String?)
    // Study plans
    case todaysPlan, planWizard, planCalendar
    case planDay(StudyPlanDay, Date?)
    // Profile
    case settings
    case detailedWordStats(WordStatType)
    case testNotifications
}

@Observable @MainActor
final class Router {
    var tab: AppTab = .home
    var paths: [AppTab: NavigationPath] = Dictionary(uniqueKeysWithValues: AppTab.allCases.map { ($0, NavigationPath()) })

    func push(_ route: Route) { paths[tab, default: NavigationPath()].append(route) }
    /// Bumped on every switch to a tab so its entrance animation replays (Flutter rebuilds the screen on `go`).
    var visits: [AppTab: Int] = [:]
    func switchTo(_ t: AppTab) {
        guard t != tab else { return }
        Haptics.light(); tab = t; visits[t, default: 0] += 1
    }
    func popToRoot() { paths[tab] = NavigationPath() }
    func binding(for t: AppTab) -> Binding<NavigationPath> {
        Binding(get: { self.paths[t] ?? NavigationPath() }, set: { self.paths[t] = $0 })
    }
}
