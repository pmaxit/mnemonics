import SwiftUI
import MnemonicsCore

/// Port of learning_session_screen.dart (Focus tab): setup → countdown → flashcards → completion.
struct LearningSessionView: View {
    @Environment(AppModel.self) private var model
    private var session: LearningSessionModel { model.session }
    @State private var errorText: String?
    @State private var confirmEnd = false

    var body: some View {
        Group {
            switch session.phase {
            case .setup: setup
            case .countdown: countdown
            case .active, .paused: active
            case .completed: SessionCompletionView(summary: session.summary, onNew: { session.reset() })
            }
        }
        .mScreenBackground()
        .toolbar { AppToolbar(title: session.phase == .setup ? nil : "Learning Session") }
        .navigationBarTitleDisplayModeIfAvailable()
        .alert("End Session?", isPresented: $confirmEnd) {
            Button("Cancel", role: .cancel) {}
            Button("End Session", role: .destructive) { session.reset() }
        } message: { Text("Are you sure you want to end this learning session early?") }
        .alert("Can't start session", isPresented: Binding(get: { errorText != nil }, set: { if !$0 { errorText = nil } })) {
            Button("OK") { session.reset() }
        } message: { Text(errorText ?? "") }
    }

    // MARK: Setup

    private var setup: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MSpace.xl) {
                TabHeaderCard(symbol: "graduationcap.fill", title: "Learning Session", subtitle: "Enhance your vocabulary with smart flashcards",
                              trailingSymbol: "play.fill", trailingColor: MColor.primaryGreen)
                TodaysPlanCard().staggeredEntrance(1)
                VStack(alignment: .leading, spacing: MSpace.s) {
                    Text("Session Duration").font(MFont.headingMedium)
                    Text("Choose how long you want to study").font(MFont.body).foregroundStyle(MColor.textSecondary)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MSpace.m) {
                        ForEach(SessionDuration.allCases) { d in
                            Button { Haptics.light(); session.duration = d } label: {
                                VStack(spacing: 4) {
                                    Text(d.displayText).font(MFont.bodyLarge.weight(.bold))
                                    Text(d.detail).font(.system(size: 12))
                                }
                                .foregroundStyle(session.duration == d ? .white : MColor.textPrimary)
                                .frame(maxWidth: .infinity).padding(.vertical, MSpace.m)
                                .background(session.duration == d ? MColor.primaryGreen : MColor.card, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                                .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(session.duration == d ? .clear : MColor.border))
                            }.buttonStyle(.plain)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: MSpace.s) {
                    Text("Study Mode").font(MFont.headingMedium)
                    Text("Select which words to focus on").font(MFont.body).foregroundStyle(MColor.textSecondary)
                    ForEach(SessionMode.allCases) { m in
                        Button { Haptics.light(); session.mode = m } label: {
                            HStack(spacing: MSpace.m) {
                                Image(systemName: m.symbol).foregroundStyle(session.mode == m ? MColor.primaryGreen : MColor.textSecondary)
                                    .frame(width: 36, height: 36).background(MColor.primaryGreen.opacity(session.mode == m ? 0.15 : 0.05), in: Circle())
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(m.title).font(MFont.bodyLarge.weight(.semibold)).foregroundStyle(MColor.textPrimary)
                                    Text(m.detail).font(MFont.small).foregroundStyle(MColor.textSecondary)
                                }
                                Spacer()
                                if session.mode == m { Image(systemName: "checkmark.circle.fill").foregroundStyle(MColor.primaryGreen) }
                            }
                            .padding(MSpace.m).mCard()
                            .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(session.mode == m ? MColor.primaryGreen : .clear, lineWidth: 2))
                        }.buttonStyle(.plain)
                    }
                }
                Button {
                    Task {
                        do { try await session.start(model: model) } catch { errorText = error.localizedDescription }
                    }
                } label: { Label("Start \(session.duration.displayText) Session", systemImage: "play.fill") }
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, MSpace.m).padding(.top, MSpace.m).padding(.bottom, 120)
        }
    }

    // MARK: Countdown

    private var countdown: some View {
        VStack(spacing: MSpace.l) {
            Spacer()
            Text("\(session.countdown)").font(.system(size: 120, weight: .heavy, design: .rounded)).foregroundStyle(MColor.primaryGreen)
                .contentTransition(.numericText()).animation(.spring, value: session.countdown)
            Text("Get Ready!").font(MFont.headingLarge)
            Text("Your learning session is about to begin").foregroundStyle(MColor.textSecondary)
            Spacer()
        }
    }

    // MARK: Active

    @ViewBuilder private var active: some View {
        if let word = session.currentWord {
            VStack(spacing: MSpace.m) {
                let low = session.remaining < 120
                HStack(spacing: MSpace.s) {
                    Image(systemName: "timer")
                    Text(String(format: "%d:%02d", Int(session.remaining) / 60, Int(session.remaining) % 60)).font(MFont.headingMedium.bold()).monospacedDigit()
                    Spacer()
                    Button { session.phase == .paused ? session.resume() : session.pause() } label: {
                        Image(systemName: session.phase == .paused ? "play.fill" : "pause.fill")
                    }
                    Button { confirmEnd = true } label: { Image(systemName: "stop.fill") }
                }
                .foregroundStyle(low ? .red : MColor.primaryGreen)
                .padding(.horizontal, MSpace.m).padding(.vertical, MSpace.s)
                .background((low ? Color.red : MColor.primaryGreen).opacity(0.1), in: RoundedRectangle(cornerRadius: MSpace.radiusL))
                .overlay(RoundedRectangle(cornerRadius: MSpace.radiusL).stroke((low ? Color.red : MColor.primaryGreen).opacity(0.3)))

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Progress").font(.system(size: 12)).foregroundStyle(MColor.textSecondary)
                        ProgressView(value: session.progress).tint(MColor.primaryGreen)
                        Text("\(session.index + 1) of \(session.words.count)").font(.system(size: 12)).foregroundStyle(MColor.textSecondary)
                    }
                    VStack(alignment: .trailing) {
                        Text("\(session.reviews.count)").font(MFont.headingMedium.bold()).foregroundStyle(MColor.primaryGreen)
                        Text("reviewed").font(.system(size: 12)).foregroundStyle(MColor.textSecondary)
                    }.padding(.leading, MSpace.l)
                }

                SessionFlashcard(word: word, revealed: session.revealed, paused: session.phase == .paused,
                                 onFlip: session.flip,
                                 onRate: { r in Task { await session.rate(r, model: model) } },
                                 onSkip: session.skip)
            }
            .padding(.horizontal, MSpace.m).padding(.top, MSpace.s).padding(.bottom, 110)
        } else {
            VStack(spacing: MSpace.m) {
                Image(systemName: "info.circle").font(.system(size: 64)).foregroundStyle(MColor.textSecondary)
                Text("No words available for this session").font(MFont.bodyLarge).foregroundStyle(MColor.textSecondary)
                Button("Back to Setup") { session.reset() }.buttonStyle(.borderedProminent)
            }.frame(maxHeight: .infinity)
        }
    }
}

/// Port of learning_flashcard_widget.dart: 600 ms flip, front = word/category/difficulty stars, back = full detail.
struct SessionFlashcard: View {
    let word: VocabularyWord
    let revealed: Bool
    let paused: Bool
    let onFlip: () -> Void
    let onRate: (ReviewDifficultyRating) -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: MSpace.m) {
            ZStack {
                front.opacity(revealed ? 0 : 1).rotation3DEffect(.degrees(revealed ? 180 : 0), axis: (0, 1, 0))
                back.opacity(revealed ? 1 : 0).rotation3DEffect(.degrees(revealed ? 0 : -180), axis: (0, 1, 0))
            }
            .animation(.easeInOut(duration: 0.6), value: revealed)
            .onTapGesture { if !revealed && !paused { onFlip() } }

            if revealed {
                HStack(spacing: MSpace.s) {
                    rateButton("Hard", "face.dashed", .redAccent, .hard)
                    rateButton("Medium", "face.smiling", .orange, .medium)
                    rateButton("Easy", "face.smiling.inverse", MColor.primaryGreen, .easy)
                }
            }
            Button(action: onSkip) { Label("Skip", systemImage: "forward.fill").font(MFont.small) }.foregroundStyle(MColor.textSecondary)
        }
        .disabled(paused).opacity(paused ? 0.5 : 1)
    }

    private var front: some View {
        VStack(spacing: MSpace.l) {
            Spacer()
            Text(clean(word.word)).font(.system(size: 40, weight: .bold, design: .rounded)).foregroundStyle(MColor.textPrimary).multilineTextAlignment(.center)
            Pill(text: clean(word.category), color: MColor.primaryGreen)
            HStack(spacing: 2) {
                ForEach(0..<3) { i in Image(systemName: i < word.difficulty.rank ? "star.fill" : "star").foregroundStyle(MColor.secondaryOrange) }
            }
            Spacer()
            Label("Tap to reveal meaning", systemImage: "hand.tap").font(MFont.body).foregroundStyle(MColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).padding(MSpace.l).mCard(radius: MSpace.radiusL + 8)
    }

    private var back: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MSpace.m) {
                Text(clean(word.word)).font(.system(size: 28, weight: .bold)).frame(maxWidth: .infinity)
                section("Meaning", clean(word.meaning))
                if !word.mnemonic.isEmpty { section("Mnemonic", clean(word.aiMnemonic?.isEmpty == false ? word.aiMnemonic! : word.mnemonic)) }
                if !word.example.isEmpty { section("Example", clean(word.example)) }
                if !word.synonyms.isEmpty { section("Synonyms", word.synonyms.map(clean).joined(separator: ", ")) }
                if !word.antonyms.isEmpty { section("Antonyms", word.antonyms.map(clean).joined(separator: ", ")) }
            }.padding(MSpace.l)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).mCard(radius: MSpace.radiusL + 8)
    }

    private func section(_ t: String, _ s: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t).font(MFont.small.weight(.bold)).foregroundStyle(MColor.primaryGreen)
            Text(s).font(MFont.body).foregroundStyle(MColor.textPrimary)
        }
    }
    private func rateButton(_ t: String, _ sym: String, _ c: Color, _ r: ReviewDifficultyRating) -> some View {
        Button { Haptics.light(); onRate(r) } label: {
            VStack(spacing: 4) { Image(systemName: sym).font(.system(size: 22)); Text(t).font(MFont.small.weight(.semibold)) }
                .foregroundStyle(c).frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(c.opacity(0.12), in: RoundedRectangle(cornerRadius: MSpace.radiusL))
        }.buttonStyle(.plain)
    }
    /// `_sanitizeText`: strips markdown emphasis.
    private func clean(_ s: String) -> String { s.replacingOccurrences(of: "**", with: "").replacingOccurrences(of: "*", with: "") }
}

/// Port of session_completion_widget.dart.
struct SessionCompletionView: View {
    let summary: LearningSessionSummary
    let onNew: () -> Void
    @Environment(Router.self) private var router

    var body: some View {
        ScrollView {
            VStack(spacing: MSpace.l) {
                VStack(spacing: MSpace.s) {
                    Image(systemName: "party.popper.fill").font(.system(size: 48)).foregroundStyle(MColor.primaryGreen)
                    Text("Session Complete!").font(MFont.headingMedium.bold()).foregroundStyle(MColor.primaryGreen)
                    Text("Great job on completing your study session!").foregroundStyle(MColor.textSecondary)
                }
                .frame(maxWidth: .infinity).padding(MSpace.l)
                .background(LinearGradient(colors: [MColor.primaryGreen.opacity(0.1), MColor.secondaryOrange.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                HStack(spacing: MSpace.m) {
                    StatTile(symbol: "book.fill", value: "\(summary.wordsReviewed)", label: "Words Reviewed")
                    StatTile(symbol: "speedometer", value: String(format: "%.1f", summary.wordsPerMinute), label: "Words/Min", color: MColor.secondaryOrange)
                }
                VStack(alignment: .leading, spacing: MSpace.m) {
                    Text("Session Breakdown").font(MFont.bodyLarge.weight(.bold))
                    HStack(spacing: MSpace.m) {
                        StatTile(symbol: "timer", value: duration, label: "Duration")
                        StatTile(symbol: "bookmark.fill", value: "\(summary.uniqueWordsReviewed)", label: "Unique Words", color: MColor.secondaryOrange)
                    }
                    Text("Difficulty Ratings").font(MFont.bodyLarge.weight(.bold))
                    HStack(spacing: MSpace.m) {
                        StatTile(symbol: "face.smiling.inverse", value: "\(summary.difficultyBreakdown["easy"] ?? 0)", label: "Easy")
                        StatTile(symbol: "face.smiling", value: "\(summary.difficultyBreakdown["medium"] ?? 0)", label: "Medium", color: .orange)
                        StatTile(symbol: "face.dashed", value: "\(summary.difficultyBreakdown["hard"] ?? 0)", label: "Hard", color: .redAccent)
                    }
                    HStack {
                        Text("Accuracy Rate: ").foregroundStyle(MColor.textSecondary)
                        Text(summary.accuracyRate.formatted(.percent.precision(.fractionLength(0)))).bold().foregroundStyle(MColor.primaryGreen)
                    }
                }
                if !summary.masteredWords.isEmpty || !summary.strugglingWords.isEmpty {
                    VStack(alignment: .leading, spacing: MSpace.m) {
                        Text("Performance Insights").font(MFont.bodyLarge.weight(.bold))
                        if !summary.masteredWords.isEmpty { insight("Words You're Mastering", summary.masteredWords, "chart.line.uptrend.xyaxis", MColor.primaryGreen) }
                        if !summary.strugglingWords.isEmpty { insight("Words to Focus On", summary.strugglingWords, "chart.line.downtrend.xyaxis", .redAccent) }
                    }
                }
                HStack(spacing: MSpace.m) {
                    Button(action: onNew) { Label("New Session", systemImage: "arrow.clockwise") }.buttonStyle(PrimaryButtonStyle())
                    Button { router.switchTo(.progress) } label: { Label("Back", systemImage: "arrow.left") }
                        .buttonStyle(PrimaryButtonStyle(color: MColor.secondaryOrange))
                }
            }.padding(.horizontal, MSpace.m).padding(.top, MSpace.m).padding(.bottom, 120)
        }
    }
    private var duration: String {
        let s = Int(summary.sessionDuration); return String(format: "%d:%02d", s / 60, s % 60)
    }
    private func insight(_ title: String, _ words: [String], _ sym: String, _ c: Color) -> some View {
        VStack(alignment: .leading, spacing: MSpace.s) {
            Label(title, systemImage: sym).font(MFont.body.weight(.semibold)).foregroundStyle(c)
            FlowLayout(spacing: 6) {
                ForEach(words.prefix(12), id: \.self) { w in
                    Text(w).font(MFont.small).padding(.horizontal, 10).padding(.vertical, 4).background(c.opacity(0.12), in: Capsule()).foregroundStyle(c)
                }
            }
        }.padding(MSpace.m).frame(maxWidth: .infinity, alignment: .leading).mCard()
    }
}
