import SwiftUI
import MnemonicsCore

struct StreakDetailView: View {
    @Environment(AppModel.self) private var model
    private var s: LearningStatistics { model.stats }

    private func nextGoal(_ n: Int) -> Int { n < 3 ? 3 : n < 7 ? 7 : n < 30 ? 30 : n < 100 ? 100 : ((n / 100) + 1) * 100 }

    var body: some View {
        let streak = s.streak
        let color: Color = streak > 0 ? .orange : .gray
        ScrollView {
            VStack(alignment: .leading, spacing: MSpace.l) {
                VStack(spacing: MSpace.s) {
                    Image(systemName: streak > 0 ? "flame.fill" : "flame").font(.system(size: 44)).foregroundStyle(color).padding(MSpace.m).background(color.opacity(0.2), in: Circle())
                    Text("\(streak)\(streak == 1 ? " Day" : " Days")").font(.system(size: 44, weight: .heavy, design: .rounded)).foregroundStyle(color)
                    Text(streak > 0 ? "Keep the fire burning!" : "Start your streak today!").foregroundStyle(MColor.textSecondary)
                }
                .frame(maxWidth: .infinity).padding(MSpace.l)
                .background(LinearGradient(colors: [color.opacity(0.1), color.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(color.opacity(0.3)))
                .staggeredEntrance(0)

                Text("Streak Insights").font(MFont.headingMedium.bold())
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MSpace.m) {
                    SummaryCard(label: "Personal Best", value: "\(max(s.longestStreak, streak))", symbol: "trophy.fill", color: .yellow)
                    SummaryCard(label: "This Week", value: "\(s.weeklyProgress.filter { $0.wordsLearned > 0 || $0.reviewsCompleted > 0 }.count)", symbol: "calendar", color: .blue)
                    SummaryCard(label: "Next Goal", value: "\(nextGoal(streak))", symbol: "flag.fill", color: .green)
                    SummaryCard(label: "Progress", value: "\(Int((Double(streak) / Double(nextGoal(streak)) * 100).rounded()))%", symbol: "chart.line.uptrend.xyaxis", color: .purple)
                }

                Text("This Week").font(MFont.headingMedium.bold())
                HStack {
                    ForEach(Array(week.enumerated()), id: \.offset) { _, d in
                        VStack(spacing: MSpace.s) {
                            Text(d.label).font(.system(size: 12)).foregroundStyle(MColor.textSecondary)
                            Circle().fill(d.active ? Color.orange : Color.gray.opacity(0.3)).frame(width: 32, height: 32)
                                .overlay { if d.active { Image(systemName: "flame.fill").font(.system(size: 14)).foregroundStyle(.white) } }
                        }.frame(maxWidth: .infinity)
                    }
                }.padding(MSpace.l).mCard(radius: MSpace.radiusL)

                Text("Milestones").font(MFont.headingMedium.bold())
                ForEach([(3, "Getting Started", "play.fill"), (7, "One Week Wonder", "calendar"), (30, "Monthly Master", "calendar.badge.clock"), (100, "Century Club", "star.fill")], id: \.0) { days, title, sym in
                    let done = max(s.longestStreak, streak) >= days
                    HStack(spacing: MSpace.m) {
                        Image(systemName: sym).foregroundStyle(done ? .yellow : MColor.textSecondary).frame(width: 40, height: 40).background((done ? Color.yellow : Color.gray).opacity(0.15), in: Circle())
                        VStack(alignment: .leading) { Text(title).font(MFont.bodyLarge.weight(.semibold)); Text("\(days) days").font(MFont.small).foregroundStyle(MColor.textSecondary) }
                        Spacer(); if done { Image(systemName: "checkmark.circle.fill").foregroundStyle(.yellow) }
                    }.padding(MSpace.m).mCard(radius: MSpace.radiusL)
                }

                Text("Tips for Building Streaks").font(MFont.headingMedium.bold())
                VStack(alignment: .leading, spacing: MSpace.s) {
                    ForEach(["Set a specific time each day for learning", "Start with just 5-10 minutes daily", "Use notifications to remind yourself", "Celebrate small wins along the way"], id: \.self) { tip in
                        Label(tip, systemImage: "lightbulb.fill").font(MFont.body).foregroundStyle(MColor.textPrimary)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.m).mCard(radius: MSpace.radiusL)
            }.padding(MSpace.m).padding(.bottom, 120)
        }
        .mScreenBackground()
        .navigationTitle("🔥 Streak Details").navigationBarTitleDisplayModeIfAvailable()
    }

    /// Mon…Sun of the current week, marked active from real review activity.
    private var week: [(label: String, active: Bool)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let offset = (cal.component(.weekday, from: today) + 5) % 7
        let monday = cal.date(byAdding: .day, value: -offset, to: today)!
        let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return (0..<7).map { i in
            let d = cal.date(byAdding: .day, value: i, to: monday)!
            let active = model.activities.contains { cal.isDate($0.reviewedAt, inSameDayAs: d) }
                || model.progress.values.contains { $0.lastReviewedAt.map { cal.isDate($0, inSameDayAs: d) } ?? false }
            return (labels[i], active)
        }
    }
}

struct AccuracyDetailView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let items = StatisticsCalculator.join(vocab: model.words, userData: Array(model.progress.values))
        let a = StatisticsCalculator.accuracyAnalysis(items)
        let overall = model.stats.averageAccuracy
        let color: Color = overall >= 0.8 ? .green : overall >= 0.6 ? .orange : .red
        ScrollView {
            VStack(alignment: .leading, spacing: MSpace.l) {
                VStack(spacing: 6) {
                    ZStack {
                        Circle().stroke(color.opacity(0.15), lineWidth: 12)
                        Circle().trim(from: 0, to: overall).stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round)).rotationEffect(.degrees(-90))
                        Text("\(Int((overall * 100).rounded()))%").font(.system(size: 36, weight: .heavy, design: .rounded)).foregroundStyle(color)
                    }.frame(width: 140, height: 140)
                    Text("Overall Accuracy").font(MFont.bodyLarge.weight(.semibold))
                    Text(message(overall)).font(MFont.body).foregroundStyle(MColor.textSecondary).multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity).padding(MSpace.l).mCard().staggeredEntrance(0)

                breakdown("Accuracy by Difficulty", a.difficultyAccuracy)
                breakdown("Accuracy by Category", a.categoryAccuracy)

                Text("Performance Insights").font(MFont.headingMedium.bold())
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MSpace.m) {
                    insight("Strongest Level", a.difficultyAccuracy.max { $0.value < $1.value }, "star.fill", .green)
                    insight("Needs Practice", a.difficultyAccuracy.min { $0.value < $1.value }, "exclamationmark.triangle.fill", .orange)
                    insight("Best Category", a.categoryAccuracy.max { $0.value < $1.value }, "trophy.fill", .yellow)
                    insight("Focus Area", a.categoryAccuracy.min { $0.value < $1.value }, "scope", .red)
                }

                list("Most Challenging Words", a.challengingWords, empty: "Great job! No challenging words found.")
                list("Best Performing Words", a.bestWords, empty: "Keep practicing to see your best words here!")

                Text("Tips for Improvement").font(MFont.headingMedium.bold())
                VStack(alignment: .leading, spacing: MSpace.s) {
                    ForEach(tips(a), id: \.self) { Label($0, systemImage: "lightbulb.fill").font(MFont.body) }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.m).mCard(radius: MSpace.radiusL)
            }.padding(MSpace.m).padding(.bottom, 120)
        }
        .mScreenBackground()
        .navigationTitle("🎯 Accuracy Analytics").navigationBarTitleDisplayModeIfAvailable()
    }

    private func message(_ a: Double) -> String {
        a >= 0.9 ? "Excellent! You're mastering your vocabulary!" : a >= 0.8 ? "Great job! Keep up the good work!"
            : a >= 0.7 ? "Good progress! Room for improvement." : a >= 0.6 ? "Making progress! Focus on review." : "Keep practicing! Every attempt helps you learn."
    }
    private func breakdown(_ title: String, _ data: [String: Double]) -> some View {
        VStack(alignment: .leading, spacing: MSpace.s) {
            Text(title).font(MFont.bodyLarge.weight(.bold))
            if data.isEmpty { Text("No data available yet").foregroundStyle(MColor.textSecondary) }
            ForEach(data.sorted { $0.value > $1.value }, id: \.key) { k, v in
                HStack { Text(k.capitalized).frame(width: 110, alignment: .leading); ProgressView(value: v).tint(v >= 0.8 ? .green : v >= 0.6 ? .orange : .red)
                    Text("\(Int((v * 100).rounded()))%").font(MFont.small.bold()).frame(width: 44, alignment: .trailing) }
            }
        }.frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.m).mCard()
    }
    private func insight(_ label: String, _ e: Dictionary<String, Double>.Element?, _ sym: String, _ c: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: sym).foregroundStyle(c)
            Text(label).font(.system(size: 11)).foregroundStyle(MColor.textSecondary)
            Text(e?.key.capitalized ?? "-").font(MFont.body.weight(.bold)).lineLimit(1).minimumScaleFactor(0.6)
            Text(e.map { "\(Int(($0.value * 100).rounded()))%" } ?? "").font(MFont.small).foregroundStyle(c)
        }.frame(maxWidth: .infinity).padding(MSpace.m).mCard(radius: MSpace.radiusL)
    }
    private func list(_ title: String, _ words: [WordProgressItem], empty: String) -> some View {
        VStack(alignment: .leading, spacing: MSpace.s) {
            Text(title).font(MFont.headingMedium.bold())
            if words.isEmpty { Text(empty).foregroundStyle(MColor.textSecondary).padding(MSpace.m) }
            ForEach(words) { w in
                HStack { VStack(alignment: .leading) { Text(w.word.word).font(MFont.bodyLarge.weight(.bold)); Text("\(w.data.correctAnswers)/\(w.data.totalAnswers) correct").font(MFont.small).foregroundStyle(MColor.textSecondary) }
                    Spacer(); Text("\(Int((w.data.accuracyRate * 100).rounded()))%").font(MFont.bodyLarge.weight(.bold)).foregroundStyle(w.data.accuracyRate >= 0.8 ? .green : .red) }
                    .padding(MSpace.m).mCard(radius: MSpace.radiusL)
            }
        }
    }
    private func tips(_ a: AccuracyAnalysis) -> [String] {
        var t: [String] = []
        if !a.challengingWords.isEmpty { t += ["Focus on reviewing challenging words more frequently", "Try creating personal mnemonics for difficult words"] }
        if let w = a.difficultyAccuracy.min(by: { $0.value < $1.value }), w.value < 0.7 { t.append("Spend extra time on \(w.key) difficulty words") }
        t += ["Practice consistently for better retention", "Use the spaced repetition system to optimize learning",
              "Take breaks between study sessions for better performance", "Review incorrect answers to understand patterns"]
        return Array(t.prefix(5))
    }
}
