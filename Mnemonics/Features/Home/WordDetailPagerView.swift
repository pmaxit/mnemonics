import SwiftUI
import AVKit
import MnemonicsCore

/// Port of learn_word_detail_screen.dart: swipeable pages, learned slider, word explorer,
/// notes (local + cloud), Anki-style Hard/Medium/Easy bar that schedules the next review (SM-2).
struct WordDetailPagerView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let words: [VocabularyWord]
    let initialIndex: Int
    @State private var index = 0
    @State private var toast: String?
    @State private var viewStart = Date()

    init(words: [VocabularyWord], initialIndex: Int) {
        self.words = words
        self.initialIndex = initialIndex
        _index = State(initialValue: initialIndex)
    }

    private var current: VocabularyWord? { words.indices.contains(index) ? words[index] : nil }
    private var currentData: UserWordData? { current.flatMap { model.data(for: $0.word) } }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $index) {
                ForEach(Array(words.enumerated()), id: \.offset) { i, w in
                    WordPage(word: w, isCurrent: i == index).tag(i)
                }
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
            .safeAreaInset(edge: .bottom) { practiceBar }
            if let toast {
                Text(toast).font(MFont.small.weight(.semibold)).foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10).background(.black.opacity(0.8), in: Capsule())
                    .padding(.bottom, 130).transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .mScreenBackground()
        .navigationTitle(current?.word ?? "").navigationBarTitleDisplayModeIfAvailable()
        .toolbar {
            if words.count > 1 {
                ToolbarItem(placement: .primaryAction) {
                    Button { goNext() } label: { Image(systemName: "chevron.right") }.accessibilityLabel("Next word")
                }
            }
        }
        .onChange(of: index) { _, _ in viewStart = Date() }
    }

    // MARK: Practice bar

    @ViewBuilder private var practiceBar: some View {
        if currentData?.isLearned == true {
            Label("Learned — removed from your practice queue", systemImage: "checkmark.circle.fill")
                .font(MFont.body.weight(.semibold)).foregroundStyle(MColor.primaryGreen)
                .frame(maxWidth: .infinity).padding(.vertical, MSpace.m).background(.ultraThinMaterial)
        } else {
            VStack(spacing: MSpace.s) {
                Text("How well did you know this word?").font(.system(size: 12)).foregroundStyle(MColor.textSecondary)
                HStack(spacing: MSpace.s) {
                    ratingButton("Hard", .redAccent, "chart.line.downtrend.xyaxis", .hard)
                    ratingButton("Medium", .orange, "minus", .medium)
                    ratingButton("Easy", MColor.primaryGreen, "checkmark", .easy)
                }
            }
            .padding(.horizontal, MSpace.l).padding(.top, MSpace.s).padding(.bottom, MSpace.s)
            .background(.ultraThinMaterial)
            .padding(.bottom, 72) // clear the floating tab bar when embedded in a tab; harmless when pushed
        }
    }

    private func ratingButton(_ title: String, _ color: Color, _ symbol: String, _ rating: ReviewRating) -> some View {
        Button { Task { await rate(rating) } } label: {
            Label(title, systemImage: symbol).font(MFont.body.weight(.semibold)).foregroundStyle(color)
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: MSpace.radiusL))
        }.buttonStyle(.plain)
    }

    private func rate(_ rating: ReviewRating) async {
        guard let w = current else { return }
        Haptics.light()
        let result = await model.review(w.word, rating: rating)
        if let next = result.nextReview { showToast("Next review: \(Self.format(next))") }
        advanceToNextUnlearned()
    }

    private func showToast(_ s: String) {
        withAnimation { toast = s }
        Task { try? await Task.sleep(nanoseconds: 1_500_000_000); withAnimation { toast = nil } }
    }

    static func format(_ date: Date) -> String {
        let diff = date.timeIntervalSinceNow
        let days = Int(diff / 86_400), hours = Int(diff / 3_600), mins = Int(diff / 60)
        if days > 0 { return "\(days) day(s)" }
        if hours > 0 { return "\(hours) hour(s)" }
        if mins > 0 { return "\(mins) minute(s)" }
        return "now"
    }

    private func goNext() {
        guard words.count > 1 else { return }
        withAnimation { index = (index + 1) % words.count }
    }

    /// Anki-style: move to the next card that isn't learned (wrapping); stay + toast if none.
    private func advanceToNextUnlearned() {
        guard words.count > 1 else { return }
        for step in 1..<words.count {
            let idx = (index + step) % words.count
            if model.data(for: words[idx].word)?.isLearned != true { withAnimation { index = idx }; return }
        }
        showToast("All words in this set are learned. 🎉")
    }
}

// MARK: - Single page

private struct WordPage: View {
    @Environment(AppModel.self) private var model
    let word: VocabularyWord
    let isCurrent: Bool
    @State private var notes = ""
    @State private var notesDirty = false
    @State private var savingNotes = false
    @State private var hindi: String?
    @State private var loadingHindi = false
    @State private var player: AVPlayer?
    @State private var videoFailed = false
    @State private var loadedNotes = false

    private var data: UserWordData? { model.data(for: word.word) }
    private var isLearned: Bool { data?.isLearned ?? false }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MSpace.l) {
                LearnedSlider(isLearned: isLearned) { v in
                    Task { await model.markLearned(word.word, v) }
                }
                Text(word.word).font(.system(size: 32, weight: .heavy)).tracking(0.5)
                    .foregroundStyle(MColor.textPrimary).frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: MSpace.s) {
                    Text(word.meaning).font(MFont.bodyLarge).lineSpacing(4).foregroundStyle(MColor.textPrimary)
                    if loadingHindi { ProgressView().controlSize(.small) }
                    else if let hindi, !hindi.isEmpty { Text(hindi).font(.system(size: 14)).foregroundStyle(MColor.textSecondary) }
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.l)
                .background(MColor.primaryGreen.opacity(0.07), in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                .overlay(RoundedRectangle(cornerRadius: MSpace.radiusXL).stroke(MColor.primaryGreen.opacity(0.2)))

                VocabularyWordImage(word: word)

                if let url = VocabularyMedia.videoURL(for: word) {
                    VideoBox(url: url, player: $player, failed: $videoFailed, active: isCurrent)
                }

                let syn = word.effectiveSynonyms
                if !syn.isEmpty { chips("Synonyms:", syn) }
                if !word.antonyms.isEmpty { chips("Antonyms:", word.antonyms) }

                explorer
                wordInfo
                spacedHint

                Text("Your Notes:").font(MFont.bodyLarge)
                TextField("Add your notes or mnemonic...", text: $notes, axis: .vertical).lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: notes) { _, v in
                        guard loadedNotes else { return }
                        notesDirty = true
                        Task { await model.saveNotes(word.word, v) }
                    }
                if notesDirty {
                    HStack { Spacer()
                        Button { Task { await saveCloud() } } label: {
                            if savingNotes { ProgressView().controlSize(.small) } else { Label("Save to Cloud", systemImage: "icloud.and.arrow.up") }
                        }.buttonStyle(.borderedProminent).disabled(savingNotes)
                    }
                }
            }
            .padding(.horizontal, MSpace.l).padding(.bottom, 160)
        }
        .task(id: isCurrent) { if isCurrent { await onAppear() } else { player?.pause() } }
    }

    // MARK: Sections

    private func chips(_ title: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: MSpace.s) {
            Text(title).font(MFont.bodyLarge)
            FlowLayout(spacing: 8) {
                ForEach(items, id: \.self) { s in
                    Text(s).font(MFont.small).padding(.horizontal, 12).padding(.vertical, 6)
                        .background(MColor.surface, in: Capsule()).overlay(Capsule().stroke(MColor.border))
                }
            }
        }
    }

    private var explorer: some View {
        let definitionText = (word.definition?.isEmpty == false) ? word.definition! : word.meaning
        let memory = (word.aiMnemonic?.isEmpty == false) ? word.aiMnemonic! : word.mnemonic
        let distinct = (word.definition?.trimmingCharacters(in: .whitespaces).isEmpty == false)
            && word.definition!.trimmingCharacters(in: .whitespaces).lowercased() != word.meaning.trimmingCharacters(in: .whitespaces).lowercased()
        return VStack(alignment: .leading, spacing: MSpace.m) {
            Label("Word Explorer", systemImage: "safari").font(MFont.headingMedium).foregroundStyle(MColor.primaryGreen)
            if distinct {
                CollapsibleCard(symbol: "book.fill", title: "Nuance & Extended Meaning", color: Color(hex: 0xF9A825)) {
                    Text(word.definition ?? "").font(MFont.body)
                }
            }
            let usages = Array(word.phraseUsages.prefix(5))
            CollapsibleCard(symbol: "bubble.left", title: "Phrase Context & Usage", color: .blue) {
                if usages.isEmpty {
                    Text("Example sentences are not available for this word yet.").italic().foregroundStyle(MColor.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: MSpace.m) {
                        ForEach(usages, id: \.self) { u in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "tag").font(.system(size: 14)).foregroundStyle(.blue).padding(.top, 3)
                                (Text("\(u.useCase) — ").bold().foregroundColor(MColor.textPrimary)
                                 + Text(u.sentence).italic().foregroundColor(MColor.textSecondary))
                                    .font(MFont.body).lineSpacing(3)
                            }
                        }
                    }
                }
            }
            let sentences = Array(word.contextSentences.prefix(3))
            if !sentences.isEmpty {
                CollapsibleCard(symbol: "questionmark.bubble.fill", title: "Fill in the Blank (Active Recall)", color: .teal) {
                    VStack(alignment: .leading) {
                        ForEach(sentences, id: \.self) { FillInBlankCard(sentence: $0, answer: word.word, hint: definitionText) }
                    }
                }
            }
            let phrases = word.effectivePhrases
            if !phrases.isEmpty {
                CollapsibleCard(symbol: "tag.fill", title: "Key Collocations", color: .purple) {
                    FlowLayout(spacing: 8) {
                        ForEach(phrases, id: \.self) { p in
                            Text(p).font(MFont.small).padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.purple.opacity(0.1), in: Capsule()).overlay(Capsule().stroke(Color.purple.opacity(0.25)))
                        }
                    }
                }
            }
            if !memory.isEmpty {
                CollapsibleCard(symbol: "brain.head.profile", title: "Memory Hook", color: .orange) {
                    Text(memory.replacingOccurrences(of: "**", with: "")).font(MFont.body)
                }
            }
        }
    }

    private var wordInfo: some View {
        VStack(alignment: .leading, spacing: MSpace.s) {
            Text("Word Information").font(MFont.bodyLarge.weight(.semibold))
            FlowLayout(spacing: MSpace.s) {
                chip("Category", word.category, MColor.primaryGreen)
                chip("Difficulty", word.difficulty.displayName, difficultyColor)
                if let d = data {
                    chip("Reviews", "\(d.reviewCount)", MColor.secondaryOrange)
                    chip("Accuracy", "\(Int((d.accuracyRate * 100).rounded()))%", d.accuracyRate >= 0.8 ? .green : d.accuracyRate >= 0.6 ? .orange : .red)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.m)
        .background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusL))
        .overlay(RoundedRectangle(cornerRadius: MSpace.radiusL).stroke(MColor.primaryGreen.opacity(0.3)))
    }
    private var difficultyColor: Color { word.difficulty == .basic ? .green : word.difficulty == .intermediate ? .orange : .red }
    private func chip(_ l: String, _ v: String, _ c: Color) -> some View {
        Text("\(l): \(v)").font(.system(size: 12, weight: .medium)).foregroundStyle(c.opacity(0.85))
            .padding(.horizontal, MSpace.s).padding(.vertical, MSpace.xs)
            .background(c.opacity(0.1), in: RoundedRectangle(cornerRadius: MSpace.radiusS))
            .overlay(RoundedRectangle(cornerRadius: MSpace.radiusS).stroke(c.opacity(0.3)))
    }

    @ViewBuilder private var spacedHint: some View {
        if !isLearned && data?.nextReview == nil {
            Text("Rate this word below to schedule its first spaced-repetition review.").font(MFont.body)
        } else if let next = data?.nextReview, !isLearned {
            Text("Next review: \(WordDetailPagerView.format(next))").font(MFont.body).foregroundStyle(MColor.secondaryOrange)
        } else if isLearned {
            Text("Marked learned — it won't appear in your review queue.").font(MFont.body)
        }
    }

    // MARK: Loading

    private func onAppear() async {
        loadedNotes = false
        notes = data?.notes ?? ""
        notesDirty = false
        loadedNotes = true
        loadingHindi = true
        async let h: Void = loadHindi()
        async let c: Void = loadCloud()
        _ = await (h, c)
    }

    private func loadHindi() async {
        hindi = nil; loadingHindi = true
        hindi = (try? await Translator.translate(word.meaning, to: "hi")) ?? "Translation failed"
        loadingHindi = false
    }

    private func loadCloud() async {
        if let n = await model.cloudNotes(word.word), n != notes { loadedNotes = false; notes = n; loadedNotes = true }
        if let l = await model.cloudLearned(word.word), l != isLearned { await model.markLearned(word.word, l) }
    }

    private func saveCloud() async {
        savingNotes = true
        let ok = await model.syncNotesToCloud(word.word, notes)
        savingNotes = false
        if ok { notesDirty = false }
    }
}

// MARK: - Shared widgets

struct CollapsibleCard<Content: View>: View {
    let symbol: String, title: String, color: Color
    @ViewBuilder var content: Content
    @State private var open = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { withAnimation(.easeInOut(duration: 0.2)) { open.toggle() } } label: {
                HStack(spacing: MSpace.s) {
                    Image(systemName: symbol).font(.system(size: 16)).foregroundStyle(color).padding(6)
                        .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                    Text(title).font(MFont.bodyLarge.weight(.semibold)).foregroundStyle(color.opacity(0.9)).multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: "chevron.down").rotationEffect(.degrees(open ? 180 : 0)).foregroundStyle(MColor.textSecondary)
                }.padding(.horizontal, MSpace.m).padding(.vertical, 10)
            }.buttonStyle(.plain)
            if open { content.padding(.horizontal, MSpace.m).padding(.bottom, MSpace.m).frame(maxWidth: .infinity, alignment: .leading) }
        }
        .background(color.opacity(0.05), in: RoundedRectangle(cornerRadius: MSpace.radiusM))
        .overlay(RoundedRectangle(cornerRadius: MSpace.radiusM).stroke(color.opacity(0.2)))
    }
}

struct LearnedSlider: View {
    let isLearned: Bool
    let onChanged: (Bool) -> Void
    var body: some View {
        ZStack {
            Capsule().fill(LinearGradient(colors: isLearned ? [MColor.primaryGreen, MColor.primaryGreen.opacity(0.7)] : [Color(white: 0.82), Color(white: 0.74)],
                                          startPoint: .leading, endPoint: .trailing))
                .shadow(color: isLearned ? MColor.primaryGreen.opacity(0.4) : .black.opacity(0.1), radius: 8, y: 4)
            HStack {
                if !isLearned { Spacer() }
                Text(isLearned ? "LEARNED" : "UNLEARNED").font(MFont.headingMedium).tracking(1.5)
                    .foregroundStyle(isLearned ? .white : Color(white: 0.45)).padding(.horizontal, 24)
                if isLearned { Spacer() }
            }
            HStack {
                if isLearned { Spacer() }
                Image(systemName: isLearned ? "checkmark.circle.fill" : "circle").font(.system(size: 30))
                    .foregroundStyle(isLearned ? MColor.primaryGreen : Color(white: 0.55))
                    .frame(width: 52, height: 52).background(.white, in: Circle()).shadow(color: .black.opacity(0.12), radius: 4, y: 2).padding(4)
                if !isLearned { Spacer() }
            }
        }
        .frame(height: 60).animation(.easeInOut(duration: 0.3), value: isLearned)
        .contentShape(Capsule())
        .onTapGesture { Haptics.light(); onChanged(!isLearned) }
        .gesture(DragGesture(minimumDistance: 20).onEnded { v in
            if v.translation.width > 0 && !isLearned { onChanged(true) } else if v.translation.width < 0 && isLearned { onChanged(false) }
        })
        .accessibilityLabel(isLearned ? "Learned" : "Unlearned")
        .accessibilityAddTraits(.isButton)
    }
}

struct VocabularyWordImage: View {
    let word: VocabularyWord
    var height: CGFloat? = nil
    var body: some View {
        Group {
            if let url = VocabularyMedia.imageURL(for: word) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFit().frame(maxWidth: .infinity)
                    case .failure: placeholder("photo.badge.exclamationmark")
                    default: ProgressView().frame(maxWidth: .infinity, minHeight: height ?? 160)
                    }
                }
            } else { placeholder("photo") }
        }
        .clipShape(RoundedRectangle(cornerRadius: MSpace.radiusL))
    }
    private func placeholder(_ sym: String) -> some View {
        Image(systemName: sym).font(.system(size: 40)).foregroundStyle(MColor.textSecondary)
            .frame(maxWidth: .infinity, minHeight: height ?? 160).background(MColor.surface)
    }
}

private struct VideoBox: View {
    let url: URL
    @Binding var player: AVPlayer?
    @Binding var failed: Bool
    let active: Bool
    var body: some View {
        Group {
            if let player { VideoPlayer(player: player) }
            else if failed {
                Button { failed = false; start() } label: { Label("Video unavailable — retry", systemImage: "arrow.clockwise") }
            } else { ProgressView() }
        }
        .frame(height: 200).frame(maxWidth: .infinity).background(MColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: MSpace.radiusL))
        .onAppear { if player == nil && active { start() } }
        .onDisappear { player?.pause() }
    }
    private func start() {
        let p = AVPlayer(url: url)
        player = p
        Task {
            let item = p.currentItem
            if let item, (try? await item.asset.load(.isPlayable)) == false { failed = true; player = nil }
        }
    }
}
