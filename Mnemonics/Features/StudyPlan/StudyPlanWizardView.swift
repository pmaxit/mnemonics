import SwiftUI
import MnemonicsCore

private struct Option: Identifiable {
    let id = UUID()
    let emoji: String, title: String, subtitle: String, value: String, color: UInt32
}
private struct GoalPreset: Identifiable {
    let id = UUID()
    let emoji: String, title: String, subtitle: String, words: Int, days: Int, color: UInt32
}

private let goalPresets = [
    GoalPreset(emoji: "🚀", title: "Quick Start", subtitle: "30 words in 5 days", words: 30, days: 5, color: 0x4CAF8F),
    GoalPreset(emoji: "📚", title: "SAT Prep", subtitle: "100 words in 14 days", words: 100, days: 14, color: 0xF4A261),
    GoalPreset(emoji: "🎓", title: "GRE Mastery", subtitle: "200 words in 30 days", words: 200, days: 30, color: 0x4CAF8F),
    GoalPreset(emoji: "⚡", title: "Intensive", subtitle: "50 words in 3 days", words: 50, days: 3, color: 0xF4A261),
    GoalPreset(emoji: "🎯", title: "Steady Builder", subtitle: "75 words in 10 days", words: 75, days: 10, color: 0xF8BBD0),
    GoalPreset(emoji: "🏆", title: "Marathon", subtitle: "300 words in 45 days", words: 300, days: 45, color: 0x4CAF8F),
]
private let difficultyOptions = [
    Option(emoji: "🌱", title: "Gentle Start", subtitle: "Easy words first, ramp up gradually", value: "easy_start", color: 0x4CAF8F),
    Option(emoji: "⚖️", title: "Balanced", subtitle: "Steady mix of all levels each day", value: "balanced", color: 0xF4A261),
    Option(emoji: "🔥", title: "Challenging", subtitle: "Hard words early, push your limits", value: "challenging", color: 0xF8BBD0),
]
private let commitmentOptions = [
    Option(emoji: "🍃", title: "Light", subtitle: "~5 words/day — casual pace", value: "light", color: 0x4CAF8F),
    Option(emoji: "📖", title: "Standard", subtitle: "~10 words/day — steady pace", value: "standard", color: 0xF4A261),
    Option(emoji: "💪", title: "Intensive", subtitle: "~20 words/day — deep dive", value: "intensive", color: 0xF8BBD0),
]

/// Port of study_plan_wizard_screen.dart (4 steps → POST /study-plan/create).
struct StudyPlanWizardView: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var totalWords = 50
    @State private var numDays = 7
    @State private var difficulty = "balanced"
    @State private var commitment = "standard"
    @State private var custom = false
    @State private var title = ""
    @State private var creating = false

    private var wordsPerDay: Int { Int((Double(totalWords) / Double(numDays)).rounded(.up)) }
    private var estimatedXP: Int { totalWords * 2 + numDays * 10 }
    private var difficultyLabel: String { difficultyOptions.first { $0.value == difficulty }?.title ?? "Balanced" }

    var body: some View {
        VStack(spacing: 0) {
            if creating { loading } else {
                HStack(spacing: 6) {
                    ForEach(0..<4) { i in Capsule().fill(i <= step ? MColor.primaryGreen : MColor.primaryGreen.opacity(0.2)).frame(height: 6) }
                }.padding(.horizontal, MSpace.l).padding(.top, MSpace.s)
                ScrollView { content.padding(MSpace.l) }
                buttons.padding(MSpace.l)
            }
        }
        .mScreenBackground()
        .navigationTitle("Create Study Plan").navigationBarTitleDisplayModeIfAvailable()
        .navigationBarBackButtonHidden(step > 0)
        .toolbar { if step > 0 { ToolbarItem(placement: .navigation) { Button { step -= 1 } label: { Image(systemName: "chevron.left") } } } }
    }

    @ViewBuilder private var content: some View {
        switch step {
        case 0: goal
        case 1: optionList("Difficulty Curve", "How should the plan ramp up over time?", difficultyOptions, $difficulty)
        case 2:
            VStack(alignment: .leading, spacing: MSpace.l) {
                optionList("Daily Commitment", "How many words per day feels right?", commitmentOptions, $commitment)
                HStack {
                    Image(systemName: "star.fill").foregroundStyle(MColor.secondaryOrange)
                    VStack(alignment: .leading) {
                        Text("Potential XP: ~\(estimatedXP) XP").font(MFont.bodyLarge.weight(.bold))
                        Text("Review days every 4th day give bonus XP!").font(MFont.small).foregroundStyle(MColor.textSecondary)
                    }
                }.padding(MSpace.m).frame(maxWidth: .infinity, alignment: .leading)
                    .background(MColor.secondaryOrange.opacity(0.1), in: RoundedRectangle(cornerRadius: MSpace.radiusL))
            }
        default: summary
        }
    }

    private func header(_ t: String, _ s: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t).font(MFont.headingMedium.bold()); Text(s).foregroundStyle(MColor.textSecondary)
        }
    }

    private var goal: some View {
        VStack(alignment: .leading, spacing: MSpace.m) {
            header("What's your goal?", "Choose a preset or customize your own plan.")
            ForEach(goalPresets) { p in
                let selected = !custom && totalWords == p.words && numDays == p.days
                Button { totalWords = p.words; numDays = p.days; custom = false } label: {
                    optionRow(p.emoji, p.title, p.subtitle, Color(hex: p.color), selected)
                }.buttonStyle(.plain)
            }
            Button { custom = true } label: { optionRow("🛠️", "Custom Plan", "\(totalWords) words / \(numDays) days", MColor.primaryGreen, custom) }.buttonStyle(.plain)
            if custom {
                slider("Total Words", $totalWords, 10...300, 10)
                slider("Duration (days)", $numDays, 1...60, 1)
            }
        }
    }

    private func slider(_ label: String, _ v: Binding<Int>, _ r: ClosedRange<Int>, _ step: Int) -> some View {
        VStack(alignment: .leading) {
            HStack { Text(label).font(MFont.body.weight(.semibold)); Spacer(); Text("\(v.wrappedValue)").bold().foregroundStyle(MColor.primaryGreen) }
            Slider(value: Binding(get: { Double(v.wrappedValue) }, set: { v.wrappedValue = Int($0.rounded()) }),
                   in: Double(r.lowerBound)...Double(r.upperBound), step: Double(step)).tint(MColor.primaryGreen)
        }
    }

    private func optionList(_ t: String, _ s: String, _ opts: [Option], _ sel: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: MSpace.m) {
            header(t, s)
            ForEach(opts) { o in
                Button { sel.wrappedValue = o.value } label: { optionRow(o.emoji, o.title, o.subtitle, Color(hex: o.color), sel.wrappedValue == o.value) }.buttonStyle(.plain)
            }
        }
    }

    private func optionRow(_ emoji: String, _ title: String, _ sub: String, _ color: Color, _ selected: Bool) -> some View {
        HStack(spacing: MSpace.m) {
            Text(emoji).font(.system(size: 22)).frame(width: 44, height: 44).background(color.opacity(0.18), in: RoundedRectangle(cornerRadius: MSpace.radiusL))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.textPrimary)
                Text(sub).font(MFont.small).foregroundStyle(MColor.textSecondary)
            }
            Spacer()
            if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(color) }
        }
        .padding(MSpace.m).background(selected ? color.opacity(0.1) : MColor.card, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
        .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(selected ? color : MColor.border, lineWidth: selected ? 2 : 1))
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: MSpace.m) {
            header("Your Plan Summary", "Review and generate your personalized study plan.")
            VStack(spacing: MSpace.s) {
                row("Total Words", "\(totalWords)"); row("Duration", "\(numDays) days"); row("Words per Day", "~\(wordsPerDay)")
                row("Difficulty", difficultyLabel); row("Potential XP", "~\(estimatedXP) XP")
            }.padding(MSpace.m).mCard()
            Text("Plan Title (Optional)").font(MFont.body.weight(.semibold))
            TextField("e.g. TOEFL Prep, SAT Vocab...", text: $title).textFieldStyle(.roundedBorder)
            Label("AI will mix difficulty levels, insert review days every 4th day, and assign XP rewards to keep you motivated.", systemImage: "sparkles")
                .font(MFont.small).foregroundStyle(MColor.textSecondary)
                .padding(MSpace.m).background(MColor.primaryGreen.opacity(0.08), in: RoundedRectangle(cornerRadius: MSpace.radiusL))
        }
    }
    private func row(_ l: String, _ v: String) -> some View { HStack { Text(l).foregroundStyle(MColor.textSecondary); Spacer(); Text(v).bold() } }

    private var buttons: some View {
        HStack(spacing: 16) {
            if step > 0 { Button("Back") { step -= 1 }.frame(maxWidth: .infinity).frame(height: 52)
                .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(MColor.border)) }
            Button { if step < 3 { withAnimation { step += 1 } } else { Task { await create() } } } label: {
                Text(step == 3 ? "Generate Plan ✨" : "Next").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 52).background(MColor.primaryGreen, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
            }.frame(maxWidth: .infinity)
        }
    }

    private var loading: some View {
        VStack(spacing: MSpace.l) {
            Spacer(); ProgressView().controlSize(.large).tint(MColor.primaryGreen)
            Text("AI is crafting your plan…").font(MFont.headingMedium)
            Text("Analyzing vocabulary, mixing difficulty levels, and building your personalized schedule.")
                .multilineTextAlignment(.center).foregroundStyle(MColor.textSecondary).padding(.horizontal, MSpace.xl)
            Spacer()
        }
    }

    private func create() async {
        creating = true
        defer { creating = false }
        let t = title.trimmingCharacters(in: .whitespaces)
        do {
            let plan = try await model.createPlan(totalWords: totalWords, numDays: numDays, wordsPerDay: wordsPerDay,
                                                  title: t.isEmpty ? nil : t, difficultyPref: difficulty, dailyCommitment: commitment)
            router.popToRoot(); router.switchTo(.progress)
            model.showToast("Study plan \"\(plan.title)\" created! Start practising below.")
        } catch {
            model.showToast("Error: \(error.localizedDescription)", isError: true)
        }
    }
}
