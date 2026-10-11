import SwiftUI
import UniformTypeIdentifiers
import MnemonicsCore

/// Port of profile_settings_screen.dart + profile_settings_widget.dart.
struct ProfileSettingsView: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router
    @State private var showGoal = false
    @State private var showFreq = false
    @State private var confirmLogout = false
    @State private var confirmReset = false
    @State private var goalText = ""
    @State private var summary: String?
    @State private var importing = false

    private var enabledSets: Set<String> { model.profile?.enabledSetIDs ?? [] }
    private var levels: Set<Int> { Set(model.profile?.levels ?? [1]) }

    var body: some View {
        @Bindable var m = model
        ScrollView {
            VStack(alignment: .leading, spacing: MSpace.l) {
                section("Learning Preferences") {
                    row("timer", "Daily Goal", "\(m.settings.dailyGoal) minutes") { goalText = "\(m.settings.dailyGoal)"; showGoal = true }
                    row("repeat", "Review Frequency", "\(m.settings.reviewFrequency) minutes/day") { goalText = "\(m.settings.reviewFrequency)"; showFreq = true }
                    Toggle(isOn: $m.settings.showMyWords) {
                        VStack(alignment: .leading) {
                            Label("My Words section", systemImage: "graduationcap.fill").font(MFont.bodyLarge.weight(.semibold))
                            Text("Show a personalized word list for practice on the home screen").font(MFont.small).foregroundStyle(MColor.textSecondary)
                        }
                    }.tint(MColor.primaryGreen).padding(.vertical, 4)
                }

                section("Practice Content") {
                    ForEach(["character", "speech", "intellect", "morality", "conflict", "change"], id: \.self) { id in
                        Toggle(id.capitalized, isOn: Binding(get: { enabledSets.contains(id) }, set: { _ in toggleSet(id) })).tint(MColor.primaryGreen)
                    }
                    Text("Select the levels you want to practice").font(MFont.small).foregroundStyle(MColor.textSecondary)
                    HStack {
                        ForEach(1...3, id: \.self) { l in
                            Button { toggleLevel(l) } label: {
                                Text("Level \(l)").font(MFont.body.weight(.semibold))
                                    .foregroundStyle(levels.contains(l) ? .white : MColor.textPrimary)
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(levels.contains(l) ? MColor.primaryGreen : MColor.surface, in: Capsule())
                            }.buttonStyle(.plain)
                        }
                    }
                    if !enabledSets.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Active Categories").font(MFont.small.weight(.bold))
                            FlowLayout(spacing: 6) { ForEach(enabledSets.sorted(), id: \.self) { Pill(text: label(for: $0)) } }
                        }
                    } else { Text("No categories selected").font(MFont.small).foregroundStyle(MColor.textSecondary) }
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "sparkles").foregroundStyle(MColor.primaryGreen)
                        Text(summary ?? "Select your categories and level to get started.").font(MFont.small).foregroundStyle(MColor.textSecondary)
                    }
                }

                section("Appearance") {
                    Picker("Theme", selection: $m.theme) { ForEach(ThemePreference.allCases) { Text($0.title).tag($0) } }.pickerStyle(.segmented)
                }

                section("Data Management") {
                    ShareLink(item: exportJSON(), preview: SharePreview("mnemonics-export.json")) {
                        Label("Export Data — Download your learning history", systemImage: "square.and.arrow.down")
                    }
                    Button { importing = true } label: { Label("Import Data — Restore your learning history", systemImage: "square.and.arrow.up") }
                }

                section("Advanced") {
                    Button { confirmLogout = true } label: { Label("Log Out — Sign out of your account", systemImage: "rectangle.portrait.and.arrow.right") }
                    Button { model.markOnboardingIncomplete() } label: { Label("Restart Onboarding (Test) — Redo your level assessment", systemImage: "arrow.clockwise") }
                    Button(role: .destructive) { confirmReset = true } label: { Label("Reset Progress — Clear all learning data", systemImage: "arrow.counterclockwise") }
                }

                Button(role: .destructive) { confirmLogout = true } label: {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right").font(MFont.body.weight(.semibold)).frame(maxWidth: .infinity).padding(.vertical, MSpace.l)
                }.mCard()
            }
            .padding(MSpace.m).padding(.bottom, 130)
        }
        .mScreenBackground()
        .navigationTitle("Settings").navigationBarTitleDisplayModeIfAvailable()
        .task(id: model.profile) { summary = await model.settingsSummary() }
        .alert("Daily Goal", isPresented: $showGoal) {
            TextField("Minutes", text: $goalText).keyboardType(.numberPad)
            Button("Cancel", role: .cancel) {}; Button("Save") { if let v = Int(goalText), v > 0 { model.settings.dailyGoal = v } }
        }
        .alert("Review Frequency", isPresented: $showFreq) {
            TextField("Minutes", text: $goalText).keyboardType(.numberPad)
            Button("Cancel", role: .cancel) {}; Button("Save") { if let v = Int(goalText), v > 0 { model.settings.reviewFrequency = v } }
        }
        .alert("Log Out", isPresented: $confirmLogout) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) { Task { await model.signOut() } }
        } message: { Text("Are you sure you want to log out?") }
        .alert("Reset Progress?", isPresented: $confirmReset) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { Task { await model.resetAllProgress(); model.showToast("Progress reset successful") } }
        } message: { Text("This will clear all your learned words and statistics. This action cannot be undone.") }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
            guard case .success(let url) = result else { return }
            Task { let ok = await model.importProgress(from: url); model.showToast(ok ? "Import complete" : "Import failed", isError: !ok) }
        }
    }

    private func label(for id: String) -> String {
        switch id { case "sat": "SAT Prep"; case "gre": "GRE Prep"; case "phrases": "Common Phrases"; case "emotions": "Emotions"; default: id.capitalized }
    }

    private func toggleSet(_ id: String) {
        guard var p = model.profile else { return }
        var sets = enabledSets
        if sets.contains(id) { sets.remove(id) } else { sets.insert(id) }
        p.enabledWordSets = sets.sorted().joined(separator: ",")
        Task { await model.updateProfile(p) }
    }
    private func toggleLevel(_ l: Int) {
        guard var p = model.profile else { return }
        var cur = levels
        if cur.contains(l) { if cur.count > 1 { cur.remove(l) } } else { cur.insert(l) }
        p.vocabularyLevel = cur.sorted().map(String.init).joined(separator: ",")
        Task { await model.updateProfile(p) }
    }

    private func exportJSON() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("mnemonics-export.json")
        try? model.exportProgressData().write(to: url, options: .atomic)
        return url
    }

    private func section<C: View>(_ title: String, @ViewBuilder _ content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: MSpace.m) {
            Text(title).font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.textPrimary)
            VStack(alignment: .leading, spacing: MSpace.m) { content() }
                .frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.m).mCard()
        }
    }
    private func row(_ sym: String, _ title: String, _ sub: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack { Image(systemName: sym).foregroundStyle(MColor.primaryGreen).frame(width: 28)
                VStack(alignment: .leading) { Text(title).font(MFont.bodyLarge.weight(.semibold)).foregroundStyle(MColor.textPrimary); Text(sub).font(MFont.small).foregroundStyle(MColor.textSecondary) }
                Spacer(); Image(systemName: "chevron.right").foregroundStyle(MColor.textSecondary) }
        }.buttonStyle(.plain)
    }
}
