import SwiftUI
import MnemonicsCore

enum WordSortOption: String, CaseIterable, Identifiable {
    case alphabeticalAsc = "A to Z", alphabeticalDesc = "Z to A", unlearnedFirst = "Unlearned First", learnedFirst = "Learned First"
    case easyFirst = "Easiest First", hardFirst = "Hardest First"
    var id: String { rawValue }
}

/// Port of learn_word_list_screen.dart: search, sort, grouped by category, tap → flashcards pager.
struct WordListView: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router
    let setID: String
    @State private var search = ""
    @State private var sort: WordSortOption = .alphabeticalAsc
    @State private var cloudLearned: Set<String> = []

    private var setName: String { model.wordSets.first { $0.id == setID }?.name ?? "" }
    private var learned: Set<String> { model.learnedWords.union(cloudLearned) }

    private var filtered: [VocabularyWord] {
        let q = search.lowercased()
        let list = model.words.filter { w in
            w.category == setID && (q.isEmpty || w.word.lowercased().contains(q) || w.meaning.lowercased().contains(q) || w.mnemonic.lowercased().contains(q))
        }
        func alpha(_ a: VocabularyWord, _ b: VocabularyWord) -> Bool { a.word.lowercased() < b.word.lowercased() }
        return list.sorted { a, b in
            switch sort {
            case .alphabeticalAsc: return alpha(a, b)
            case .alphabeticalDesc: return alpha(b, a)
            case .easyFirst: return a.difficulty.rank < b.difficulty.rank
            case .hardFirst: return a.difficulty.rank > b.difficulty.rank
            case .learnedFirst:
                let x = learned.contains(a.word) ? 0 : 1, y = learned.contains(b.word) ? 0 : 1
                return x != y ? x < y : alpha(a, b)
            case .unlearnedFirst:
                let x = learned.contains(a.word) ? 1 : 0, y = learned.contains(b.word) ? 1 : 0
                return x != y ? x < y : alpha(a, b)
            }
        }
    }

    var body: some View {
        let list = filtered
        let grouped = Dictionary(grouping: list) { $0.category.isEmpty ? "Uncategorized" : $0.category }
        ScrollView {
            LazyVStack(alignment: .leading, spacing: MSpace.m) {
                TabHeaderCard(title: setName.isEmpty ? "Word List" : setName, subtitle: "Tap any word to start learning",
                              trailingSymbol: "brain.head.profile", trailingColor: MColor.primaryGreen)
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(MColor.textSecondary)
                    TextField("Search words, meanings, or mnemonics", text: $search)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                    if !search.isEmpty { Button { search = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(MColor.textSecondary) } }
                }
                .padding(MSpace.m).background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))

                HStack {
                    Text("\(list.count) words").font(MFont.small.weight(.semibold)).foregroundStyle(MColor.textSecondary)
                    Spacer()
                    Menu {
                        Picker("Sort", selection: $sort) { ForEach(WordSortOption.allCases) { Text($0.rawValue).tag($0) } }
                    } label: { Label("Sort", systemImage: "arrow.up.arrow.down").font(MFont.small) }
                }

                if list.isEmpty {
                    VStack(spacing: MSpace.s) {
                        Image(systemName: "magnifyingglass").font(.system(size: 44)).foregroundStyle(MColor.textSecondary)
                        Text("No words found").font(MFont.headingMedium)
                        Text("Try adjusting your search terms").foregroundStyle(MColor.textSecondary)
                    }.frame(maxWidth: .infinity).padding(.top, MSpace.xl)
                } else {
                    ForEach(grouped.keys.sorted(), id: \.self) { cat in
                        DisclosureGroup(isExpanded: .constant(true)) {
                            ForEach(grouped[cat] ?? []) { w in
                                WordCard(word: w, learned: learned.contains(w.word)) {
                                    router.push(.flashcards(words: list, initialIndex: list.firstIndex(of: w) ?? 0))
                                }
                            }
                        } label: {
                            HStack { Text(cat.capitalized).font(MFont.bodyLarge.weight(.bold)); Pill(text: "\(grouped[cat]?.count ?? 0)") }
                        }
                        .disclosureGroupStyle(AlwaysOpenStyle())
                    }
                }
            }
            .padding(.horizontal, MSpace.m).padding(.bottom, 120)
        }
        .mScreenBackground()
        .navigationTitle(setName.isEmpty ? "Word List" : setName).navigationBarTitleDisplayModeIfAvailable()
        .task { await fetchCloudLearned() }
    }

    /// GET /learned_status/<uid> for the "learned first/unlearned first" sorts.
    private func fetchCloudLearned() async {
        guard let uid = model.remoteUserID else { return }
        cloudLearned = (try? await model.api.learnedWords(userID: uid)) ?? []
    }
}

struct AlwaysOpenStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: MSpace.s) { configuration.label; configuration.content }
    }
}

struct WordCard: View {
    let word: VocabularyWord
    let learned: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: MSpace.m) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(word.word).font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.textPrimary)
                        if learned { Image(systemName: "checkmark.seal.fill").foregroundStyle(MColor.primaryGreen) }
                    }
                    Text(word.meaning).font(MFont.small).foregroundStyle(MColor.textSecondary).lineLimit(2).multilineTextAlignment(.leading)
                    Pill(text: word.difficulty.displayName, color: color)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 13)).foregroundStyle(MColor.textSecondary)
            }
            .padding(MSpace.m).mCard()
        }.buttonStyle(.plain)
    }
    private var color: Color { switch word.difficulty { case .basic: MColor.primaryGreen; case .intermediate: MColor.secondaryOrange; case .advanced: .redAccent } }
}
