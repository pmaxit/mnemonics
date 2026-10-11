import SwiftUI
import MnemonicsCore

/// Port of onboarding_wizard_screen.dart: welcome → goal → 5-question assessment → result/plan.
struct OnboardingWizardView: View {
    @Environment(AppModel.self) private var model
    @State private var page = 0
    @State private var goal: String?
    @State private var correct = 0
    @State private var answered = 0
    @State private var selected: String?
    @State private var feedback = false
    @State private var generating = false

    private var level: Int { Onboarding.assessedLevel(correct: correct) }
    private var levelName: String { Onboarding.levelName(level) }

    var body: some View {
        ZStack {
            MBackground().ignoresSafeArea()
            if generating {
                VStack(spacing: MSpace.l) { ProgressView().controlSize(.large).tint(MColor.primaryGreen); Text("Creating your personalized plan...").font(MFont.bodyLarge) }
            } else {
                VStack(spacing: MSpace.l) {
                    HStack(spacing: 6) { ForEach(0..<4) { i in Capsule().fill(i <= page ? MColor.primaryGreen : MColor.primaryGreen.opacity(0.2)).frame(height: 6) } }
                    if page > 0 && page < 3 { HStack { Button { withAnimation { page -= 1 } } label: { Label("Back", systemImage: "chevron.left") }; Spacer() } }
                    Group {
                        switch page { case 0: welcome; case 1: goalStep; case 2: quiz; default: result }
                    }.transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))).id(page)
                }.padding(MSpace.l).animation(.easeInOut(duration: 0.4), value: page)
            }
        }
    }

    private var welcome: some View {
        VStack(spacing: MSpace.l) {
            Spacer(); Image(systemName: "sparkles").font(.system(size: 64)).foregroundStyle(MColor.primaryGreen)
            Text("Master Your Vocabulary").font(MFont.headingLarge).multilineTextAlignment(.center)
            Text("Personalized word lists, AI-powered study plans, and interactive practice sessions tailored to your level.")
                .multilineTextAlignment(.center).foregroundStyle(MColor.textSecondary)
            Spacer(); Button("Get Started") { page = 1 }.buttonStyle(PrimaryButtonStyle())
        }
    }

    private var goalStep: some View {
        VStack(alignment: .leading, spacing: MSpace.m) {
            Text("What is your goal?").font(MFont.headingLarge)
            Text("We will tailor your word lists and plans based on your objective.").foregroundStyle(MColor.textSecondary)
            ScrollView { VStack(spacing: MSpace.s) {
                ForEach(Onboarding.goals, id: \.id) { g in
                    Button { goal = g.id } label: {
                        HStack { VStack(alignment: .leading) { Text(g.title).font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.textPrimary); Text(g.desc).font(MFont.small).foregroundStyle(MColor.textSecondary) }
                            Spacer(); if goal == g.id { Image(systemName: "checkmark.circle.fill").foregroundStyle(MColor.primaryGreen) } }
                            .padding(MSpace.m).background(goal == g.id ? MColor.primaryGreen.opacity(0.1) : MColor.card, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                            .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(goal == g.id ? MColor.primaryGreen : MColor.border, lineWidth: goal == g.id ? 2 : 1))
                    }.buttonStyle(.plain)
                }
            } }
            Button("Continue") { page = 2 }.buttonStyle(PrimaryButtonStyle()).disabled(goal == nil).opacity(goal == nil ? 0.5 : 1)
        }
    }

    private var quiz: some View {
        let q = Onboarding.questions[min(answered, Onboarding.questions.count - 1)]
        return VStack(spacing: MSpace.m) {
            Text("Quick Assessment").font(MFont.headingLarge)
            Text("Answer honestly — this sets your starting level.").foregroundStyle(MColor.textSecondary)
            Text("\(answered + 1) of \(Onboarding.questions.count)").font(MFont.small.weight(.semibold)).foregroundStyle(MColor.primaryGreen)
            Text("What is the best synonym for:").foregroundStyle(MColor.textSecondary).padding(.top, MSpace.m)
            Text(q.word).font(.system(size: 34, weight: .heavy)).foregroundStyle(MColor.primaryGreen)
            ForEach(q.options, id: \.self) { o in
                Button { answer(o, q) } label: {
                    Text(o).font(MFont.bodyLarge).foregroundStyle(MColor.textPrimary).frame(maxWidth: .infinity).padding(MSpace.m)
                        .background(optionColor(o, q).opacity(0.15), in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                        .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(optionColor(o, q).opacity(0.6)))
                }.buttonStyle(.plain).disabled(feedback)
            }
            Button("I don't know yet") { answer(nil, q) }.foregroundStyle(MColor.textSecondary).disabled(feedback)
            Spacer()
        }
    }
    private func optionColor(_ o: String, _ q: Onboarding.Question) -> Color {
        guard feedback else { return MColor.textSecondary }
        if o == q.answer { return MColor.primaryGreen }
        return o == selected ? .red : MColor.textSecondary
    }
    private func answer(_ o: String?, _ q: Onboarding.Question) {
        guard !feedback else { return }
        feedback = true; selected = o
        if o == q.answer { correct += 1 }
        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            feedback = false; selected = nil
            if answered < Onboarding.questions.count - 1 { answered += 1 } else { page = 3 }
        }
    }

    private var result: some View {
        let plan = Onboarding.plan(forLevel: level)
        return ScrollView { VStack(spacing: MSpace.l) {
            Image(systemName: "trophy.fill").font(.system(size: 64)).foregroundStyle(MColor.secondaryOrange)
            Text("You're at \(levelName) level").font(MFont.headingLarge)
            Text("Score: \(correct) of \(Onboarding.questions.count) correct").padding(.horizontal, 14).padding(.vertical, 6).background(MColor.primaryGreen.opacity(0.12), in: Capsule())
            Text("Here's what we prepared for you:").foregroundStyle(MColor.textSecondary)
            feature("graduationcap.fill", "My Words", "A word list matched to your \(levelName.lowercased()) level, ready to practice.")
            feature("calendar", "Study plan", "A \(plan.totalWords)-word roadmap across \(plan.numDays) days.")
            feature("slider.horizontal.3", "Full control", "Adjust your level and word sets anytime in Settings.")
            Button("Enter Dashboard") { Task { await complete(plan) } }.buttonStyle(PrimaryButtonStyle())
        } }
    }
    private func feature(_ sym: String, _ t: String, _ d: String) -> some View {
        HStack(spacing: MSpace.m) {
            Image(systemName: sym).foregroundStyle(MColor.primaryGreen).frame(width: 40, height: 40).background(MColor.primaryGreen.opacity(0.12), in: Circle())
            VStack(alignment: .leading) { Text(t).font(MFont.bodyLarge.weight(.bold)); Text(d).font(MFont.small).foregroundStyle(MColor.textSecondary) }
            Spacer()
        }.padding(MSpace.m).mCard()
    }

    private func complete(_ plan: Onboarding.PlanSize) async {
        generating = true
        await model.completeOnboarding(goal: goal ?? "character", score: correct)
        _ = try? await model.createPlan(totalWords: plan.totalWords, numDays: plan.numDays, wordsPerDay: plan.wordsPerDay,
                                        title: "My First \((goal ?? "character").uppercased()) Plan", difficultyPref: plan.difficultyPref, dailyCommitment: "standard")
        generating = false
        model.showToast("Welcome! You start at \(levelName) level — your words are ready.")
    }
}
