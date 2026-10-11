import SwiftUI
import Charts
import MnemonicsCore

/// Port of progress_overview_screen.dart (the "Progress" tab).
struct ProgressOverviewView: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router
    @State private var confirmDelete: StudyPlan?

    private var s: LearningStatistics { model.stats }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MSpace.xl) {
                VStack(alignment: .leading, spacing: MSpace.m) {
                    TabHeaderCard(symbol: nil, logo: true, title: "Your Progress", subtitle: "Track your learning journey",
                                  trailingSymbol: "chart.bar.fill", trailingColor: MColor.secondaryOrange)
                    tagline.staggeredEntrance(1)
                }
                VStack(spacing: MSpace.m) {
                    HStack(spacing: MSpace.m) {
                        AnimatedStatCard(label: "Total Learned", value: s.totalLearned, symbol: "graduationcap.fill", color: MColor.primaryGreen, highlight: true) { router.push(.totalWords) }
                        AnimatedStatCard(label: "Learned Today", value: s.learnedToday, symbol: "calendar", color: MColor.secondaryOrange, highlight: s.learnedToday > 0) { router.push(.wordsToday) }
                    }
                    HStack(spacing: MSpace.m) {
                        AnimatedStatCard(label: "🔥 Day Streak", value: s.streak, symbol: "flame.fill", color: .orange, highlight: s.streak > 0) { router.push(.streak) }
                        AnimatedStatCard(label: "Accuracy", value: Int((s.averageAccuracy * 100).rounded()), suffix: "%", symbol: "target",
                                         color: accuracyColor(s.averageAccuracy)) { router.push(.accuracy) }
                    }
                }
                WeeklyProgressChart(days: s.weeklyProgress).staggeredEntrance(3)
                TodaysPlanCard().staggeredEntrance(4)
                studyPlanSection.staggeredEntrance(5)
                VStack(alignment: .leading, spacing: MSpace.m) {
                    Text("Learning Stages").font(.system(size: 20, weight: .semibold))
                    HStack(spacing: MSpace.s) {
                        AnimatedStatCard(label: "New", value: s.newCount, symbol: "sparkles", color: .blue) { router.push(.learningStage("new")) }
                        AnimatedStatCard(label: "Learning", value: s.inProgressCount, symbol: "brain.head.profile", color: .orange) { router.push(.learningStage("learning")) }
                        AnimatedStatCard(label: "Mastered", value: s.masteredCount, symbol: "star.fill", color: .yellow, highlight: true) { router.push(.learningStage("mastered")) }
                    }
                }
                BreakdownSection(title: "Progress by Category", data: s.categoryBreakdown) { router.push(.breakdown(type: "category", filter: $0)) }
                BreakdownSection(title: "Progress by Difficulty", data: Dictionary(uniqueKeysWithValues: s.difficultyBreakdown.map { ($0.key.rawValue, $0.value) })) {
                    router.push(.breakdown(type: "difficulty", filter: $0))
                }
            }
            .padding(.horizontal, MSpace.m).padding(.top, MSpace.m).padding(.bottom, 130)
        }
        .refreshable { await model.loadVocabulary(force: true); await model.loadPlans() }
        .toolbar { AppToolbar() }
        .navigationBarTitleDisplayModeIfAvailable()
        .task { await model.loadPlans() }
        .alert("Delete Study Plan?", isPresented: Binding(get: { confirmDelete != nil }, set: { if !$0 { confirmDelete = nil } })) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { if let p = confirmDelete { Task { await model.deletePlan(p.id); model.showToast("Study plan deleted") } } }
        } message: { Text("This will remove \"\(confirmDelete?.title ?? "")\". This action cannot be undone.") }
    }

    private func accuracyColor(_ a: Double) -> Color { a >= 0.8 ? .green : a >= 0.6 ? .orange : .red }

    // MARK: Tagline

    private var tagline: some View {
        let n = s.totalLearned
        let color: Color = n == 0 ? MColor.primaryGreen : n < 50 ? MColor.secondaryOrange : n < 100 ? .purple : n < 250 ? .indigo : .yellow
        let symbol = n == 0 ? "leaf.fill" : n < 10 ? "paperplane.fill" : n < 50 ? "flame.fill" : n < 100 ? "trophy.fill" : n < 250 ? "bolt.fill" : "crown.fill"
        let msg: String = n == 0 ? "Every expert was once a beginner. Start your journey today! 🌱"
            : n < 10 ? "Great start! You're building momentum. Keep going! 🚀"
            : n < 50 ? "You're on fire! \(n) words mastered and counting! 🔥"
            : n < 100 ? "Impressive progress! You're becoming a vocabulary champion! 🏆"
            : n < 250 ? "Wow! \(n) words conquered. You're unstoppable! ⚡"
            : "Legendary! \(n) words mastered. You're a language master! 👑"
        let prog: Double = n < 10 ? Double(n) / 10 : n < 50 ? Double(n - 10) / 40 : n < 100 ? Double(n - 50) / 50 : n < 250 ? Double(n - 100) / 150 : 1
        return HStack(spacing: MSpace.m) {
            Image(systemName: symbol).font(.system(size: 22)).foregroundStyle(color).padding(10).background(color.opacity(0.2), in: Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text(msg).font(MFont.body.weight(.semibold)).foregroundStyle(color)
                if n > 0 { ProgressView(value: prog).tint(color) }
            }
        }
        .padding(MSpace.m)
        .background(LinearGradient(colors: [color.opacity(0.1), color.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
        .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(color.opacity(0.3)))
    }

    // MARK: Study plan section

    private var studyPlanSection: some View {
        VStack(alignment: .leading, spacing: MSpace.m) {
            HStack {
                Text("Study Plan").font(.system(size: 20, weight: .semibold))
                Spacer()
                Button { router.push(.planWizard) } label: { Label("New Plan", systemImage: "plus") }.font(MFont.small.weight(.semibold))
            }
            if model.plans.isEmpty {
                if model.planError != nil && !model.isLoadingPlan && model.remoteUserID != nil {
                    VStack(spacing: MSpace.s) {
                        Image(systemName: "icloud.slash").font(.system(size: 28)).foregroundStyle(MColor.textSecondary)
                        Text("Couldn't load study plans").font(MFont.bodyLarge.weight(.semibold))
                        Text("Tap retry, or create a new plan.").foregroundStyle(MColor.textSecondary)
                        Button("Retry") { Task { await model.loadPlans() } }
                    }.frame(maxWidth: .infinity).padding(MSpace.l).mCard()
                } else {
                    Button { router.push(.planWizard) } label: {
                        VStack(spacing: MSpace.m) {
                            Image(systemName: "calendar").font(.system(size: 24)).foregroundStyle(MColor.primaryGreen).frame(width: 48, height: 48)
                                .background(MColor.primaryGreen.opacity(0.1), in: Circle())
                            Text("No active study plan").font(MFont.bodyLarge.weight(.semibold)).foregroundStyle(MColor.textPrimary)
                            Text("Create an AI-powered plan to practise\nwords day by day").multilineTextAlignment(.center).foregroundStyle(MColor.textSecondary)
                            Label("Generate Plan with AI", systemImage: "sparkles").font(MFont.body.weight(.semibold)).foregroundStyle(.white)
                                .padding(.horizontal, 24).padding(.vertical, 12).background(MColor.primaryGreen, in: RoundedRectangle(cornerRadius: MSpace.radiusL))
                        }.frame(maxWidth: .infinity).padding(MSpace.l).mCard()
                    }.buttonStyle(.plain)
                }
            } else {
                ForEach(model.plans) { plan in activeCard(plan) }
            }
        }
    }

    private func activeCard(_ plan: StudyPlan) -> some View {
        let done = plan.completedDays, inProg = plan.inProgressDays, total = plan.days.count
        let progress = total == 0 ? 0 : Double(done) / Double(total)
        return Button { router.push(.planCalendar) } label: {
            VStack(alignment: .leading, spacing: MSpace.s) {
                HStack {
                    Label("Active Plan", systemImage: "calendar").font(MFont.body.weight(.semibold)).foregroundStyle(MColor.primaryGreen)
                    Spacer()
                    Button { confirmDelete = plan } label: { Image(systemName: "trash").foregroundStyle(MColor.textSecondary) }.buttonStyle(.plain)
                }
                .padding(.horizontal, 10).padding(.vertical, 4).background(MColor.primaryGreen.opacity(0.12), in: RoundedRectangle(cornerRadius: MSpace.radiusM))
                Text(plan.title).font(.system(size: 17, weight: .bold)).foregroundStyle(MColor.textPrimary)
                HStack(spacing: MSpace.s) {
                    Pill(text: "\(done) done"); Pill(text: "\(inProg) in progress", color: MColor.secondaryOrange); Pill(text: "\(total - done) left", color: MColor.textSecondary)
                }
                HStack { Text("Progress").font(MFont.body.weight(.medium)); Spacer()
                    Text("\(Int((progress * 100).rounded()))%").font(MFont.body.weight(.bold)).foregroundStyle(MColor.primaryGreen) }
                ProgressView(value: progress).tint(MColor.primaryGreen)
                Label("Tap to open your calendar", systemImage: "hand.tap").font(MFont.small).foregroundStyle(MColor.textSecondary)
            }.padding(MSpace.l).mCard()
        }.buttonStyle(.plain)
    }
}

// MARK: - Components

/// Port of AnimatedStatCard (count-up number + accent icon).
struct AnimatedStatCard: View {
    let label: String
    let value: Int
    var suffix: String = ""
    let symbol: String
    let color: Color
    var highlight = false
    var onTap: (() -> Void)? = nil
    @State private var shown = 0

    var body: some View {
        Button { Haptics.light(); onTap?() } label: {
            VStack(spacing: 8) {
                Image(systemName: symbol).font(.system(size: 20)).foregroundStyle(color)
                    .frame(width: 40, height: 40).background(color.opacity(0.15), in: Circle())
                Text("\(shown)\(suffix)").font(.system(size: 28, weight: .bold, design: .rounded)).foregroundStyle(highlight ? color : MColor.textPrimary)
                    .contentTransition(.numericText()).monospacedDigit()
                Text(label).font(.system(size: 12, weight: .medium)).foregroundStyle(MColor.textSecondary).lineLimit(1).minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity).padding(.vertical, MSpace.m).padding(.horizontal, 6).mCard()
            .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(highlight ? color.opacity(0.4) : .clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .onAppear { withAnimation(.easeOut(duration: 0.8)) { shown = value } }
        .onChange(of: value) { _, v in withAnimation(.easeOut(duration: 0.6)) { shown = v } }
    }
}

struct WeeklyProgressChart: View {
    let days: [DailyProgress]
    var body: some View {
        VStack(alignment: .leading, spacing: MSpace.m) {
            Text("Weekly Progress").font(.system(size: 20, weight: .semibold))
            if days.isEmpty || days.allSatisfy({ $0.wordsLearned == 0 && $0.reviewsCompleted == 0 }) {
                Text(days.isEmpty ? "No data available" : "No activity this week yet — review a word to start your line.")
                    .foregroundStyle(MColor.textSecondary).frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart(days) { d in
                    AreaMark(x: .value("Day", d.date, unit: .day), y: .value("Words", d.wordsLearned))
                        .foregroundStyle(LinearGradient(colors: [MColor.primaryGreen.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.catmullRom)
                    LineMark(x: .value("Day", d.date, unit: .day), y: .value("Words", d.wordsLearned))
                        .foregroundStyle(MColor.primaryGreen).lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round)).interpolationMethod(.catmullRom)
                    PointMark(x: .value("Day", d.date, unit: .day), y: .value("Words", d.wordsLearned)).foregroundStyle(MColor.primaryGreen)
                }
                .chartXAxis { AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.abbreviated)) } }
                .chartYScale(domain: 0...max(5, (days.map(\.wordsLearned).max() ?? 0) + 1))
                .frame(height: 180)
            }
        }
        .padding(MSpace.l).mCard()
    }
}

/// Port of AnimatedBreakdownSection: tappable horizontal bars.
struct BreakdownSection: View {
    let title: String
    let data: [String: Int]
    let onTap: (String) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: MSpace.m) {
            Text(title).font(.system(size: 20, weight: .semibold))
            if data.isEmpty { Text("No data yet").foregroundStyle(MColor.textSecondary) }
            let total = max(1, data.values.reduce(0, +))
            ForEach(data.sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }, id: \.key) { k, v in
                Button { onTap(k) } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack { Text(k.capitalized).font(MFont.body.weight(.medium)).foregroundStyle(MColor.textPrimary); Spacer()
                            Text("\(v)").font(MFont.body.weight(.bold)).foregroundStyle(MColor.primaryGreen)
                            Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(MColor.textSecondary) }
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule().fill(MColor.primaryGreen.opacity(0.12))
                                Capsule().fill(MColor.primaryGreen).frame(width: g.size.width * CGFloat(v) / CGFloat(total))
                            }
                        }.frame(height: 8)
                    }
                }.buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.l).mCard()
    }
}
