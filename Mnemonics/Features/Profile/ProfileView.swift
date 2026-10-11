import SwiftUI
import MnemonicsCore

/// Port of enhanced_profile_screen.dart: header, "This Week" quick stats, complexity breakdown.
struct ProfileView: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router
    @State private var sheet: QuickStat?

    enum QuickStat: String, Identifiable { case words, sessions, pace, streak; var id: String { rawValue } }

    private var s: ProfileSummary { model.profileSummary }
    private var displayName: String {
        guard let u = model.auth.user else { return "Vocabulary Learner" }
        if !u.displayName.isEmpty { return u.displayName }
        return u.email.split(separator: "@").first.map(String.init) ?? "Vocabulary Learner"
    }
    private var initials: String {
        let parts = displayName.split(separator: " ")
        if parts.count >= 2 { return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased() }
        if let f = parts.first, f.count >= 2 { return String(f.prefix(2)).uppercased() }
        return "U"
    }
    private var subtitle: String {
        if let d = model.auth.user?.createdAt { return "Learning since " + d.formatted(.dateTime.month(.wide).year()) }
        return "Welcome to Mnemonics!"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MSpace.m) {
                TabHeaderCard(title: displayName, subtitle: subtitle, trailingSymbol: "flame.fill", trailingColor: MColor.secondaryOrange) {
                    Text(initials).font(MFont.bodyLarge.weight(.bold)).foregroundStyle(.white).frame(width: 48, height: 48)
                        .background(LinearGradient(colors: [MColor.primaryGreen, MColor.primaryGreen.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: MSpace.radiusL))
                }

                // This week
                VStack(alignment: .leading, spacing: MSpace.m) {
                    Text("This Week").font(MFont.headingMedium.bold())
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MSpace.s) {
                        quick("Words Learned", "\(s.wordsLearnedThisWeek)", "plus.circle", MColor.primaryGreen, .words)
                        quick("Study Sessions", "\(s.studySessions)", "play.circle", MColor.secondaryOrange, .sessions)
                        quick("Learning Pace", String(format: "%.1f words/week", s.learningVelocity), "chart.line.uptrend.xyaxis",
                              s.learningVelocity >= 10 ? .green : s.learningVelocity >= 5 ? MColor.primaryGreen : s.learningVelocity >= 2 ? MColor.secondaryOrange : .red, .pace)
                        quick("Longest Streak", "\(s.longestStreak) days", "trophy.fill", .yellow, .streak)
                    }
                }.padding(MSpace.l).mCard().staggeredEntrance(1)

                // Complexity breakdown
                VStack(alignment: .leading, spacing: MSpace.m) {
                    Text("Complexity Breakdown").font(MFont.headingMedium)
                    Text("Track your progress across different complexity levels").foregroundStyle(MColor.textSecondary)
                    ForEach(s.difficultyStats) { d in difficultyCard(d) }
                }.padding(MSpace.l).mCard().staggeredEntrance(2)
            }
            .padding(.horizontal, MSpace.m).padding(.top, MSpace.m).padding(.bottom, 130)
        }
        .toolbar { AppToolbar(title: "My Profile") }
        .navigationBarTitleDisplayModeIfAvailable()
        .sheet(item: $sheet) { quickSheet($0) }
    }

    private func quick(_ label: String, _ value: String, _ sym: String, _ c: Color, _ kind: QuickStat) -> some View {
        Button { if kind == .words { router.push(.detailedWordStats(.learned)) } else { sheet = kind } } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack { Image(systemName: sym).foregroundStyle(c); Text(label).font(.system(size: 12)).foregroundStyle(MColor.textSecondary).lineLimit(1)
                    Spacer(); Image(systemName: "chevron.right").font(.system(size: 10)).foregroundStyle(c.opacity(0.5)) }
                Text(value).font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.textPrimary).minimumScaleFactor(0.6).lineLimit(1)
            }
            .padding(MSpace.s).frame(maxWidth: .infinity, alignment: .leading)
            .background(c.opacity(0.1), in: RoundedRectangle(cornerRadius: MSpace.radiusL))
            .overlay(RoundedRectangle(cornerRadius: MSpace.radiusL).stroke(c.opacity(0.2)))
        }.buttonStyle(.plain)
    }

    private func difficultyCard(_ d: DifficultyStats) -> some View {
        let c: Color = d.difficulty == .basic ? .green : d.difficulty == .intermediate ? .orange : .red
        let pct = d.totalWords > 0 ? Double(d.wordsLearned) / Double(d.totalWords) : 0
        return VStack(alignment: .leading, spacing: MSpace.s) {
            HStack {
                HStack(spacing: 4) { Text(d.difficulty.emoji); Text(d.difficulty.displayName).font(MFont.bodyLarge.weight(.semibold)).foregroundStyle(c) }
                    .padding(.horizontal, MSpace.s).padding(.vertical, MSpace.xs).background(c.opacity(0.1), in: RoundedRectangle(cornerRadius: MSpace.radiusS))
                Spacer()
                Text("\(d.wordsLearned)/\(d.totalWords)").font(MFont.bodyLarge.weight(.semibold))
            }
            ProgressView(value: pct).tint(c.opacity(0.8))
            Text("Accuracy: \(Int((d.averageAccuracy * 100).rounded()))%").font(MFont.small).foregroundStyle(MColor.textSecondary)
        }.padding(MSpace.m).background(MColor.card, in: RoundedRectangle(cornerRadius: MSpace.radiusL))
            .overlay(RoundedRectangle(cornerRadius: MSpace.radiusL).stroke(c.opacity(0.3)))
    }

    @ViewBuilder private func quickSheet(_ k: QuickStat) -> some View {
        NavigationStack {
            List {
                switch k {
                case .words:
                    Text("Words learned this week: \(s.wordsLearnedThisWeek)"); Text("Words learned today: \(s.wordsLearnedToday)")
                    Text("Total words learned: \(s.totalWordsLearned)")
                case .sessions:
                    Text("Total sessions: \(s.studySessions)")
                    Text("Total study time: \(String(format: "%.1f", Double(s.totalStudyTimeMinutes) / 60)) hours")
                                case .pace:
                    Text("Current pace: \(String(format: "%.1f", s.learningVelocity)) words/week")
                    Text("Words learned today: \(s.wordsLearnedToday)"); Text("Words learned this week: \(s.wordsLearnedThisWeek)")
                case .streak:
                    Text("Current streak: \(s.currentStreak) days"); Text("Longest streak: \(s.longestStreak) days")
                }
            }
            .navigationTitle(k == .words ? "Words Learned This Week" : k == .sessions ? "Study Sessions This Week" : k == .pace ? "Learning Pace Analytics" : "Streak History")
            .navigationBarTitleDisplayModeIfAvailable()
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Close") { sheet = nil } } }
        }.presentationDetents([.medium])
    }
}
