import SwiftUI
import MnemonicsCore

/// Splash → (welcome/login/signup) → onboarding → main tabs. Port of the GoRouter redirect rules.
struct RootView: View {
    @Environment(AppModel.self) private var model
    @State private var showSplash = true

    var body: some View {
        ZStack {
            Group {
                if !model.auth.isReady { Color.clear }
                else if model.auth.user == nil { AuthFlowView() }
                else if let p = model.profile, !p.hasCompletedOnboarding { OnboardingWizardView() }
                else { MainTabsView() }
            }
            NotificationToastOverlay().zIndex(3)
            if showSplash { SplashView { withAnimation(.easeOut(duration: 0.4)) { showSplash = false } }.transition(.opacity).zIndex(4) }
        }
        .preferredColorScheme(model.theme.scheme)
        .tint(MColor.primaryGreen)
        .task(id: model.auth.user?.uid) {
            if model.auth.user != nil {
                await model.bootstrap()
                await NotificationHub.shared.start(userId: model.remoteUserID)
            } else {
                NotificationHub.shared.stop()
            }
        }
    }
}

struct MainTabsView: View {
    @Environment(AppModel.self) private var model
    @State private var router = Router()

    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack(path: router.binding(for: tab)) {
                    root(for: tab)
                        .id(router.visits[tab] ?? 0)
                        .navigationDestination(for: Route.self) { RouteView(route: $0) }
                }
                .opacity(router.tab == tab ? 1 : 0)
                .allowsHitTesting(router.tab == tab)
            }
            if let t = model.toast {
                Text(t.text).font(MFont.body.weight(.semibold)).foregroundStyle(.white)
                    .padding(.horizontal, MSpace.m).padding(.vertical, 12)
                    .background(t.isError ? Color.redAccent : MColor.primaryGreen, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, MSpace.m).padding(.bottom, 90).transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
            }
            AnimatedTabBar(selection: Binding(get: { router.tab }, set: { if $0 != router.tab { router.switchTo($0) } }),
                           badge: model.dueWords.count)
        }
        .environment(router)
        .animation(.easeInOut, value: model.toast)
        .mScreenBackground(animated: true)
    }

    @ViewBuilder private func root(for tab: AppTab) -> some View {
        switch tab {
        case .home: HomeView()
        case .progress: ProgressOverviewView()
        case .focus: LearningSessionView()
        case .profile: ProfileView()
        }
    }
}

/// Port of `CustomBottomNavBar`: sliding pill, selected tab expands to show its label.
/// The selected tab hugs its content so the label never wraps or clips.
struct AnimatedTabBar: View {
    @Binding var selection: AppTab
    var badge: Int = 0
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let selected = selection == tab
                Button { selection = tab } label: {
                    VStack(spacing: 2) {
                        Image(systemName: selected ? tab.activeSymbol : tab.symbol)
                            .font(.system(size: 20, weight: .semibold))
                        if selected {
                            Text(tab.title).font(.system(size: 11, weight: .semibold))
                                .lineLimit(1).fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    .foregroundStyle(selected ? Color.white : MColor.textSecondary)
                    .padding(.horizontal, selected ? 20 : 0)
                    .frame(height: 54)
                    // Selected tab hugs its content (label stays on one line); the others share the leftover space.
                    .frame(minWidth: 54, maxWidth: selected ? nil : .infinity)
                    .background {
                        if selected { Capsule().fill(MColor.primaryGreen).matchedGeometryEffect(id: "pill", in: pill) }
                    }
                    .overlay(alignment: .topTrailing) {
                        // Flutter: notification dot on Profile unless it is the active tab.
                        if tab == .profile, !selected {
                            Circle().fill(Color.red).frame(width: 8, height: 8).offset(x: -8, y: 6)
                        }
                        // New (not in Flutter): words due for review.
                        if tab == .focus, badge > 0, !selected {
                            Circle().fill(MColor.secondaryOrange).frame(width: 9, height: 9).offset(x: -8, y: 6)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(6)
        .animation(.spring(response: 0.18, dampingFraction: 0.9), value: selection)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(MColor.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
        .padding(.horizontal, MSpace.m).padding(.bottom, 8)
    }
}

/// Destination switch for every pushable route.
struct RouteView: View {
    let route: Route
    var body: some View {
        switch route {
        case .wordList(let id): WordListView(setID: id)
        case .flashcards(let words, let idx): WordDetailPagerView(words: words, initialIndex: idx)
        case .myWords: MyWordsListView()
        case .knowledgeTree: KnowledgeTreeDetailView()
        case .streak: StreakDetailView()
        case .wordsToday: WordsTodayDetailView()
        case .totalWords: TotalWordsDetailView()
        case .accuracy: AccuracyDetailView()
        case .learningStage(let s): LearningStagesDetailView(stage: s)
        case .breakdown(let t, let f): BreakdownDetailView(type: t, filter: f)
        case .todaysPlan: TodaysPlanView()
        case .planWizard: StudyPlanWizardView()
        case .planCalendar: StudyCalendarView()
        case .planDay(let d, let date): StudyDayDetailView(day: d, date: date)
        case .settings: ProfileSettingsView()
        case .detailedWordStats(let t): DetailedWordStatisticsView(type: t)
        case .testNotifications: TestNotificationView()
        }
    }
}
