import SwiftUI
import MnemonicsCore

func wordsForPlan(_ plan: DailyStudyPlan, _ all: [VocabularyWord]) -> [VocabularyWord] {
    let by = Dictionary(all.map { ($0.word, $0) }, uniquingKeysWith: { a, _ in a })
    return plan.items.compactMap { by[$0.word] }
}

/// Port of TodaysStudyPlanCard (shown above the session setup).
struct TodaysPlanCard: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router

    var body: some View {
        VStack(alignment: .leading, spacing: MSpace.m) {
            Text("Today's plan").font(.system(size: 20, weight: .semibold)).foregroundStyle(MColor.textPrimary)
            if model.isLoadingPlan && model.todaysPlan == nil {
                ProgressView().frame(maxWidth: .infinity)
            } else if let plan = model.todaysPlan {
                planCard(plan)
            } else {
                VStack(spacing: MSpace.s) {
                    Text("Couldn't load today's mix").font(MFont.bodyLarge.weight(.semibold))
                    if let e = model.planError { Text(e).font(MFont.small).foregroundStyle(MColor.textSecondary).multilineTextAlignment(.center) }
                    Button("Retry") { Task { await model.loadTodaysPlan() } }
                }.frame(maxWidth: .infinity).padding(MSpace.l).mCard()
            }
        }
        .task { if model.todaysPlan == nil { await model.loadTodaysPlan() } }
    }

    private func planCard(_ plan: DailyStudyPlan) -> some View {
        let inc = plan.incentive
        return VStack(alignment: .leading, spacing: MSpace.s) {
            HStack {
                Image(systemName: "sparkles").foregroundStyle(MColor.primaryGreen)
                Text(plan.completed ? "Finished for today" : "Personalized mix").font(MFont.body.weight(.bold)).foregroundStyle(MColor.primaryGreen)
                Spacer()
                Text("~\(plan.estimatedMinutes) min").font(MFont.body.weight(.semibold)).foregroundStyle(MColor.textSecondary)
            }
            Text(plan.strategy.headline).font(.system(size: 17, weight: .bold)).foregroundStyle(MColor.textPrimary)
            Text(plan.strategy.nextAction).font(MFont.body).foregroundStyle(MColor.textSecondary)
            FlowLayout(spacing: MSpace.s) {
                if plan.split.review > 0 { chip("\(plan.split.review) due", MColor.primaryGreen) }
                if plan.split.weak > 0 { chip("\(plan.split.weak) weak", MColor.secondaryOrange) }
                if plan.split.newWords > 0 { chip("\(plan.split.newWords) new", MColor.primaryGreen) }
                if plan.split.bonus > 0 { chip("\(plan.split.bonus) bonus", MColor.progressPink) }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(inc.streakDays)-day streak  ·  \(inc.pointsIfCompleted) pts if you finish").font(MFont.body.weight(.bold))
                Text(inc.copy).font(.system(size: 12)).foregroundStyle(MColor.textSecondary)
                if let m = inc.nextMilestone {
                    Text("Next: \(m.label) (\(m.remaining) to go)").font(.system(size: 12, weight: .semibold)).foregroundStyle(MColor.primaryGreen)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.m)
            .background(MColor.secondaryOrange.opacity(0.08), in: RoundedRectangle(cornerRadius: MSpace.radiusM))
            Button { router.push(.todaysPlan) } label: {
                Text(plan.completed ? "Review again" : "Start next words").font(MFont.body.weight(.bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 12).background(MColor.primaryGreen, in: RoundedRectangle(cornerRadius: MSpace.radiusL))
            }
        }
        .padding(MSpace.l).mCard()
    }

    private func chip(_ t: String, _ c: Color) -> some View {
        Text(t).font(.system(size: 11, weight: .semibold)).foregroundStyle(c)
            .padding(.horizontal, 8).padding(.vertical, 2).background(c.opacity(0.1), in: RoundedRectangle(cornerRadius: MSpace.radiusS))
    }
}

/// Port of todays_study_plan_screen.dart.
struct TodaysPlanView: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router
    @State private var completing = false

    var body: some View {
        ScrollView {
            if let plan = model.todaysPlan {
                VStack(spacing: MSpace.m) {
                    box { VStack(alignment: .leading, spacing: 8) {
                        Text(plan.strategy.headline).font(.system(size: 18, weight: .heavy))
                        Text("\(plan.estimatedMinutes) min  ·  \(plan.incentive.dailyGoalWords) words  ·  \(plan.profileSnapshot.dueCount) due  ·  \(Int((plan.profileSnapshot.accuracy * 100).rounded()))% accuracy")
                            .font(MFont.body).foregroundStyle(MColor.textSecondary)
                    } }
                    box { VStack(alignment: .leading, spacing: 8) {
                        Text("Why finish today").font(MFont.bodyLarge.weight(.bold))
                        Text(plan.incentive.copy).font(MFont.body)
                        Text("\(plan.incentive.streakDays)-day streak · \(plan.incentive.pointsIfCompleted) pts · \(plan.incentive.pointsNote)").font(.system(size: 12))
                    } }
                    box { VStack(alignment: .leading, spacing: 8) {
                        Text("How to study").font(MFont.bodyLarge.weight(.bold))
                        Text(plan.strategy.howToStudy).font(MFont.body)
                        ForEach(plan.strategy.tips, id: \.self) { tip in HStack(alignment: .top) { Text("•"); Text(tip).font(MFont.body) } }
                    } }
                    ForEach(plan.tracks) { track in
                        box { VStack(alignment: .leading, spacing: 8) {
                            Text(track.title).font(MFont.bodyLarge.weight(.bold))
                            Text(track.why).font(.system(size: 13)).foregroundStyle(MColor.textSecondary)
                            ForEach(track.items) { item in
                                Button {
                                    let all = wordsForPlan(plan, model.words)
                                    guard !all.isEmpty else { return }
                                    router.push(.flashcards(words: all, initialIndex: all.firstIndex { $0.word == item.word } ?? 0))
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.word).font(.system(size: 16, weight: .bold)).foregroundStyle(MColor.textPrimary)
                                            Text(item.reasonLabel + (item.category.isEmpty ? "" : " · \(item.category)") + (item.mnemonicHint ? " · mnemonic ready" : ""))
                                                .font(MFont.small).foregroundStyle(MColor.textSecondary)
                                        }
                                        Spacer(); Image(systemName: "chevron.right").foregroundStyle(MColor.textSecondary)
                                    }
                                }.buttonStyle(.plain)
                            }
                        } }
                    }
                }.padding(MSpace.m).padding(.bottom, 160)
            } else if model.isLoadingPlan { ProgressView().padding(.top, 80) }
            else { Button("Retry") { Task { await model.loadTodaysPlan() } }.padding(.top, 80) }
        }
        .mScreenBackground()
        .navigationTitle("Today's study plan").navigationBarTitleDisplayModeIfAvailable()
        .safeAreaInset(edge: .bottom) {
            if let plan = model.todaysPlan, !plan.completed {
                VStack(spacing: 4) {
                    Button {
                        let words = wordsForPlan(plan, model.words)
                        guard !words.isEmpty else { return }
                        router.push(.flashcards(words: words, initialIndex: 0))
                    } label: { Text("Start this mix") }.buttonStyle(PrimaryButtonStyle())
                    Button("Mark today complete") { completing = true; Task { await model.completeToday(plan); completing = false } }.disabled(completing)
                }.padding(.horizontal, MSpace.m).padding(.vertical, 8).padding(.bottom, 70).background(.ultraThinMaterial)
            }
        }
        .task { if model.todaysPlan == nil { await model.loadTodaysPlan() } }
    }

    private func box<C: View>(@ViewBuilder _ c: () -> C) -> some View {
        c().frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.l).mCard()
    }
}
