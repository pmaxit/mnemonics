import SwiftUI
import MnemonicsCore

private enum PlanColor {
    static let done = MColor.primaryGreen
    static let inProgress = MColor.secondaryOrange
    static let review = MColor.progressPink
    static let notStarted = Color(light: MColor.surfaceLight, dark: MColor.darkBorder)
    static let muted = MColor.textSecondary
}

/// Port of study_calendar_screen.dart + calendar_heatmap_widget.dart ("Study Plan").
struct StudyCalendarView: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router
    @State private var confirmDelete = false

    var body: some View {
        Group {
            if let plan = model.plans.first { content(plan) }
            else if let e = model.planError, !model.isLoadingPlan {
                VStack(spacing: MSpace.m) {
                    Image(systemName: "exclamationmark.circle").font(.system(size: 48)).foregroundStyle(Color.redAccent)
                    Text(e).multilineTextAlignment(.center).foregroundStyle(MColor.textSecondary)
                    Button("Retry") { Task { await model.loadPlans() } }
                }.padding(MSpace.l)
            } else { empty }
        }
        .mScreenBackground()
        .navigationTitle("Study Plan").navigationBarTitleDisplayModeIfAvailable()
        .toolbar {
            if model.plans.first != nil {
                ToolbarItem(placement: .primaryAction) { Button { confirmDelete = true } label: { Image(systemName: "trash") } }
            }
        }
        .alert("Delete Study Plan?", isPresented: $confirmDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let p = model.plans.first { Task { await model.deletePlan(p.id); model.showToast("Study plan deleted") } }
            }
        } message: { Text("This will remove \"\(model.plans.first?.title ?? "")\". This action cannot be undone.") }
        .task { await model.loadPlans() }
    }

    private var empty: some View {
        VStack(spacing: MSpace.m) {
            Spacer()
            Image(systemName: "calendar").font(.system(size: 56)).foregroundStyle(MColor.primaryGreen)
            Text("No active study plan").font(MFont.headingMedium)
            Text("Create a plan with AI-powered difficulty\ncurves and XP rewards.").multilineTextAlignment(.center).foregroundStyle(MColor.textSecondary)
            Button { router.push(.planWizard) } label: { Label("Create Study Plan", systemImage: "plus") }
                .buttonStyle(PrimaryButtonStyle()).padding(.horizontal, MSpace.xl)
            Spacer()
        }
    }

    private func content(_ plan: StudyPlan) -> some View {
        let learned = model.learnedWords
        let done = plan.completedDays, inProg = plan.inProgressDays
        let totalXP = plan.totalXp > 0 ? plan.totalXp : max(1, plan.days.reduce(0) { $0 + $1.xpValue })
        return ScrollView {
            VStack(alignment: .leading, spacing: MSpace.l) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(plan.title).font(MFont.bodyLarge.weight(.bold))
                        Text("\(plan.totalWords) words • \(plan.numDays) days • \(plan.wordsPerDay)/day").font(MFont.small).foregroundStyle(MColor.textSecondary)
                    }
                    Spacer()
                    Button("Practice") { openCurrent(plan) }.buttonStyle(.borderedProminent)
                }.padding(MSpace.m).mCard()

                FlowLayout(spacing: MSpace.s) {
                    Pill(text: "\(done) done"); Pill(text: "\(inProg) in progress", color: MColor.secondaryOrange)
                    Pill(text: "\(plan.numDays - done - inProg) left", color: MColor.textSecondary)
                }
                HStack(spacing: MSpace.m) {
                    xpCard(plan.earnedXp, totalXP)
                    streakCard(plan.streak)
                }
                wordProgress(plan, learned)
                if !plan.unlockedBadges.isEmpty {
                    Text("Badges Earned").font(MFont.bodyLarge.weight(.bold))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack { ForEach(plan.unlockedBadges, id: \.self) { b in
                            VStack(spacing: 4) { Text(b.emoji).font(.system(size: 28)); Text(b.title).font(.system(size: 12, weight: .semibold)); Text(b.detail).font(.system(size: 10)).foregroundStyle(MColor.textSecondary) }
                                .padding(MSpace.m).frame(width: 120).mCard()
                        } }
                    }
                }
                Text("Daily Calendar").font(MFont.bodyLarge.weight(.bold))
                heatmap(plan)
            }
            .padding(MSpace.m).padding(.bottom, 140)
        }
    }

    private func xpCard(_ earned: Int, _ total: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("XP", systemImage: "star.fill").font(MFont.small.weight(.semibold)).foregroundStyle(MColor.primaryGreen)
            Text("\(earned) / \(total)").font(MFont.bodyLarge.weight(.bold))
            ProgressView(value: total > 0 ? min(1, Double(earned) / Double(total)) : 0).tint(MColor.primaryGreen)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.m).mCard()
    }
    private func streakCard(_ s: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Streak", systemImage: "flame.fill").font(MFont.small.weight(.semibold)).foregroundStyle(MColor.secondaryOrange)
            Text("\(s) day\(s == 1 ? "" : "s")").font(MFont.bodyLarge.weight(.bold))
        }.frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.m).mCard()
    }
    private func wordProgress(_ plan: StudyPlan, _ learned: Set<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack { Text("Words learned").font(MFont.body.weight(.semibold)); Spacer()
                Text("\(plan.learnedWordCount(learned)) / \(plan.uniqueWords.count)").foregroundStyle(MColor.textSecondary) }
            ProgressView(value: plan.wordProgress(learned)).tint(MColor.primaryGreen)
        }.padding(MSpace.m).mCard()
    }

    private func heatmap(_ plan: StudyPlan) -> some View {
        let start = Self.parseDate(plan.startDate) ?? Date()
        let days = Dictionary(plan.days.map { ($0.dayNumber, $0) }, uniquingKeysWith: { a, _ in a })
        let cal = Calendar.current
        return VStack(alignment: .leading, spacing: 12) {
            FlowLayout(spacing: 12) {
                legend(PlanColor.notStarted, "Not started"); legend(PlanColor.inProgress, "In progress")
                legend(PlanColor.done, "Done"); legend(PlanColor.review, "Review day")
            }
            let rows = Int((Double(plan.numDays) / 7).rounded(.up))
            VStack(spacing: 6) {
                ForEach(0..<max(rows, 0), id: \.self) { r in
                    HStack(spacing: 6) {
                        ForEach(0..<7, id: \.self) { c in
                            let n = r * 7 + c + 1
                            if n > plan.numDays { Color.clear.aspectRatio(1, contentMode: .fit) }
                            else {
                                let d = days[n]
                                let date = cal.date(byAdding: .day, value: n - 1, to: start) ?? start
                                DayCell(number: n, status: d?.status ?? .notAttempted, isToday: cal.isDateInToday(date),
                                        xp: d?.xpValue ?? 10, isReview: d?.isReviewDay ?? false) {
                                    if let d { open(d, date: date) }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    private func legend(_ c: Color, _ t: String) -> some View {
        HStack(spacing: 4) { RoundedRectangle(cornerRadius: 3).fill(c).frame(width: 12, height: 12); Text(t).font(.system(size: 11)).foregroundStyle(PlanColor.muted) }
    }

    private func openCurrent(_ plan: StudyPlan) {
        let target = plan.days.first { $0.status == .inProgress } ?? plan.days.first { $0.status == .notAttempted } ?? plan.days.first
        if let target { open(target, date: nil) }
    }
    private func open(_ day: StudyPlanDay, date: Date?) {
        if day.status == .notAttempted { Task { await model.setDayStatus(day.dayNumber, .inProgress) } }
        router.push(.planDay(day, date))
    }

    static func parseDate(_ s: String) -> Date? {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withFullDate]
        return f.date(from: String(s.prefix(10)))
    }
}

private struct DayCell: View {
    let number: Int, status: DayStatus, isToday: Bool, xp: Int, isReview: Bool
    let onTap: () -> Void
    private var bg: Color {
        status == .done ? PlanColor.done : status == .inProgress ? PlanColor.inProgress : isReview ? PlanColor.review : PlanColor.notStarted
    }
    private var lightText: Bool { status != .notAttempted }
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                Text("\(number)").font(.system(size: 13, weight: isToday || status != .notAttempted || isReview ? .heavy : .semibold))
                    .foregroundStyle(lightText ? .white : isReview ? MColor.textPrimary : PlanColor.muted)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if status == .done {
                    Text("+\(xp)").font(.system(size: 8, weight: .bold)).foregroundStyle(.white).padding(.horizontal, 3).padding(.vertical, 1)
                        .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 4)).padding(3)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .background(bg, in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(MColor.primaryGreen, lineWidth: isToday && status == .notAttempted && !isReview ? 2 : 0))
            .shadow(color: (status != .notAttempted || isToday || isReview) ? bg.opacity(0.25) : .clear, radius: 6, y: 2)
        }.buttonStyle(.plain)
    }
}

/// Port of study_day_detail_screen.dart.
struct StudyDayDetailView: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    let day: StudyPlanDay
    let date: Date?
    @State private var saving = false

    private var live: StudyPlanDay { model.plans.first?.days.first { $0.dayNumber == day.dayNumber } ?? day }
    private var matched: [VocabularyWord] {
        let by = Dictionary(model.words.map { ($0.word, $0) }, uniquingKeysWith: { a, _ in a })
        return day.words.compactMap { by[$0] }
    }

    var body: some View {
        let d = live
        let words = matched
        let learnedCount = words.filter { model.data(for: $0.word)?.isLearned == true }.count
        ScrollView {
            VStack(alignment: .leading, spacing: MSpace.m) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(d.dayLabel).font(MFont.headingMedium.bold())
                        if let date { Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day())).foregroundStyle(MColor.textSecondary) }
                    }
                    Spacer()
                    Pill(text: d.status == .done ? "Done" : d.status == .inProgress ? "In Progress" : "Not Started",
                         color: d.status == .done ? MColor.primaryGreen : d.status == .inProgress ? MColor.secondaryOrange : MColor.textSecondary)
                }
                HStack {
                    stat("\(learnedCount)/\(words.count)", "Learned"); stat("+\(d.xpValue)", "XP")
                    stat(d.isReviewDay ? "🔄" : "📖", d.isReviewDay ? "Review" : "New")
                }.padding(MSpace.m).mCard()
                if words.isEmpty {
                    VStack(spacing: 8) { Image(systemName: "magnifyingglass").font(.system(size: 40)); Text("Words not found in vocabulary list") }
                        .frame(maxWidth: .infinity).foregroundStyle(MColor.textSecondary).padding(.top, MSpace.xl)
                }
                ForEach(words) { w in
                    let learned = model.data(for: w.word)?.isLearned == true
                    Button { router.push(.flashcards(words: [w], initialIndex: 0)) } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(w.word).font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.textPrimary)
                                Text(w.meaning).font(MFont.small).foregroundStyle(MColor.textSecondary).lineLimit(2)
                            }
                            Spacer()
                            Pill(text: learned ? "LEARNED" : w.difficulty.rawValue.uppercased(), color: learned ? MColor.primaryGreen : MColor.secondaryOrange)
                        }.padding(MSpace.m).mCard()
                    }.buttonStyle(.plain)
                }
            }.padding(MSpace.m).padding(.bottom, 180)
        }
        .mScreenBackground()
        .navigationTitle(d.dayLabel).navigationBarTitleDisplayModeIfAvailable()
        .safeAreaInset(edge: .bottom) { bar(d, words) }
    }

    @ViewBuilder private func bar(_ d: StudyPlanDay, _ words: [VocabularyWord]) -> some View {
        VStack(spacing: 8) {
            if d.status == .done {
                Label("Completed! +\(d.xpValue) XP earned 🎉", systemImage: "checkmark.seal.fill").font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.primaryGreen)
            } else {
                if !words.isEmpty {
                    Button { router.push(.flashcards(words: words, initialIndex: 0)) } label: { Label("Practice \(words.count) Words", systemImage: "play.fill") }
                        .buttonStyle(PrimaryButtonStyle(color: MColor.secondaryOrange))
                }
                Button {
                    saving = true
                    Task { await model.setDayStatus(d.dayNumber, .done); saving = false
                        model.showToast("Day \(d.dayNumber) complete! +\(d.xpValue) XP earned! 🎉"); dismiss() }
                } label: { Label(saving ? "Saving..." : "Mark Complete (+\(d.xpValue) XP)", systemImage: "checkmark") }
                    .buttonStyle(PrimaryButtonStyle()).disabled(saving)
            }
        }.padding(.horizontal, MSpace.m).padding(.vertical, 8).padding(.bottom, 70).background(.ultraThinMaterial)
    }
    private func stat(_ v: String, _ l: String) -> some View {
        VStack { Text(v).font(MFont.bodyLarge.weight(.bold)); Text(l).font(MFont.small).foregroundStyle(MColor.textSecondary) }.frame(maxWidth: .infinity)
    }
}
