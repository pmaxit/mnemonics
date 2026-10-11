import SwiftUI
import MnemonicsCore

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        return h < 12 ? "Good Morning" : h < 17 ? "Good Afternoon" : "Good Evening"
    }
    private var firstName: String? {
        guard let u = model.auth.user, !model.auth.isGuest else { return nil }
        let name = u.displayName.isEmpty ? (u.email.split(separator: "@").first.map(String.init) ?? "") : u.displayName
        return name.split(separator: " ").first.map(String.init)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: MSpace.m) {
                if let n = firstName {
                    TabHeaderCard(title: "\(greeting), \(n)!", subtitle: "Ready to expand your vocabulary?")
                } else {
                    TabHeaderCard(title: "Vocabulary Learning", subtitle: "Master words through mnemonics")
                }
                if model.settings.showMyWords { MyWordsSection().staggeredEntrance(1) }
                if model.isLoading && model.words.isEmpty {
                    ProgressView().frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    KnowledgeTreeCard().padding(.bottom, MSpace.s).staggeredEntrance(2)
                    SmartPathfindingCard().staggeredEntrance(3)
                    Text("Your Vocab Sets").font(MFont.headingMedium).foregroundStyle(MColor.textPrimary).padding(.top, MSpace.s)
                    ForEach(Array(model.visibleWordSets.enumerated()), id: \.element.id) { i, set in
                        WordSetCard(set: set, index: i).staggeredEntrance(4 + i)
                    }
                }
            }
            .padding(.horizontal, MSpace.m).padding(.top, MSpace.m).padding(.bottom, 120)
        }
        .refreshable { await model.loadVocabulary(force: true) }
        .toolbar { AppToolbar() }
        .navigationBarTitleDisplayModeIfAvailable()
    }
}

/// App bar: logo + title on top-level tabs, bell + settings trailing (MainScaffold).
struct AppToolbar: ToolbarContent {
    @Environment(Router.self) private var router
    var title: String? = nil
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if let title { Text(title).font(MFont.headingMedium) }
            else {
                HStack(spacing: MSpace.s) {
                    Image("LogoMark").resizable().scaledToFill().frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: MSpace.radiusM))
                    Text("Mnemonics").font(.system(size: 22, weight: .bold)).tracking(0.5)
                }
            }
        }
        ToolbarItemGroup(placement: .primaryAction) {
            NotificationBellButton()
            Button { router.push(.settings) } label: { Image(systemName: "gearshape") }
        }
    }
}

extension View {
    @ViewBuilder func navigationBarTitleDisplayModeIfAvailable() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

// MARK: My Words

struct MyWordsSection: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router
    private let accent = MColor.primaryGreen

    var body: some View {
        let words = model.recommendedWords
        let preview = Array(words.prefix(6))
        Button { Haptics.light(); router.push(.myWords) } label: {
            VStack(alignment: .leading, spacing: MSpace.m) {
                HStack {
                    Image(systemName: "graduationcap.fill").foregroundStyle(.white).padding(10)
                        .background(accent, in: RoundedRectangle(cornerRadius: MSpace.radiusL))
                    VStack(alignment: .leading) {
                        Text("My Words").font(MFont.headingMedium.bold()).foregroundStyle(MColor.textPrimary)
                        Text("Personalized for you • \(levelLabel)").font(MFont.small).foregroundStyle(MColor.textSecondary)
                    }
                    Spacer()
                    Pill(text: "\(words.count) words", color: accent)
                }
                if words.isEmpty {
                    Text("You're all caught up — pick a new level or category in Settings.").font(MFont.small).foregroundStyle(MColor.textSecondary)
                } else {
                    FlowLayout(spacing: MSpace.s) {
                        ForEach(preview) { w in
                            Text(w.word).font(.system(size: 13, weight: .semibold)).foregroundStyle(MColor.textPrimary)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusM))
                        }
                        if words.count > preview.count {
                            Text("+\(words.count - preview.count) more").font(.system(size: 13, weight: .semibold)).foregroundStyle(accent)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: MSpace.radiusM))
                        }
                    }
                }
                Label("Start practicing your level", systemImage: "play.circle.fill").font(.system(size: 13, weight: .semibold)).foregroundStyle(accent)
            }
            .padding(MSpace.l).frame(maxWidth: .infinity, alignment: .leading).mCard()
        }.buttonStyle(.plain)
    }

    private var levelLabel: String {
        let levels = model.profile?.levels ?? [1]
        if levels.count == 1 { return levels[0] == 1 ? "Beginner" : levels[0] == 2 ? "Intermediate" : "Advanced" }
        return "Levels " + levels.map(String.init).joined(separator: ", ")
    }
}

// MARK: Word sets

struct WordSetCard: View {
    @Environment(Router.self) private var router
    let set: WordSetInfo
    let index: Int
    var body: some View {
        let accent = MColor.setAccents[index % MColor.setAccents.count]
        let symbol = MColor.setSymbols[index % MColor.setSymbols.count]
        Button { Haptics.light(); router.push(.wordList(setID: set.id)) } label: {
            HStack(spacing: MSpace.l) {
                Image(systemName: symbol).font(.system(size: 28)).foregroundStyle(.white).frame(width: 60, height: 60)
                    .background(LinearGradient(colors: [accent, accent.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: MSpace.radiusL))
                    .shadow(color: accent.opacity(0.3), radius: 8, y: 4)
                VStack(alignment: .leading, spacing: MSpace.xs) {
                    Text(set.name).font(MFont.headingMedium.bold()).foregroundStyle(MColor.textPrimary)
                    Text(set.description).font(MFont.body).foregroundStyle(MColor.textSecondary).multilineTextAlignment(.leading)
                    Label("Start Learning", systemImage: "play.fill").font(.system(size: 12, weight: .semibold)).foregroundStyle(accent)
                        .padding(.horizontal, MSpace.s).padding(.vertical, MSpace.xs)
                        .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: MSpace.radiusM))
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").foregroundStyle(accent).padding(MSpace.xs)
                    .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: MSpace.radiusS))
            }
            .padding(MSpace.l).mCard()
        }.buttonStyle(.plain)
    }
}

// MARK: Smart pathfinding

struct SmartPathfindingCard: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router

    var body: some View {
        if let cat = KnowledgeTree.suggestedCategory(model.stats.categoryStats) {
            Button {
                let categoryWords = model.words.filter { $0.category == cat.name }
                if categoryWords.isEmpty { router.switchTo(.focus); return }
                let learned = model.learnedWords
                let unlearned = categoryWords.filter { !learned.contains($0.word) }
                let idx = unlearned.randomElement().flatMap { w in categoryWords.firstIndex(of: w) } ?? 0
                router.push(.flashcards(words: categoryWords, initialIndex: idx))
            } label: {
                HStack(spacing: MSpace.m) {
                    Image(systemName: "signpost.right.fill").font(.system(size: 28)).foregroundStyle(MColor.primaryGreen)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tree Needs Nutrients!").font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.textPrimary)
                        Text("Let's conquer \"\(cat.name)\" next.").font(MFont.small).foregroundStyle(MColor.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(MColor.primaryGreen)
                }
                .padding(MSpace.m)
                .background(LinearGradient(colors: [MColor.primaryGreen.opacity(0.1), .clear], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: MSpace.radiusL))
                .overlay(RoundedRectangle(cornerRadius: MSpace.radiusL).stroke(MColor.primaryGreen.opacity(0.3)))
            }.buttonStyle(.plain)
        }
    }
}

/// Simple wrapping layout (Flutter `Wrap`).
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var alignment: HorizontalAlignment = .leading
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0, maxW: CGFloat = 0
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > width, x > 0 { x = 0; y += rowH + spacing; rowH = 0 }
            x += sz.width + spacing; rowH = max(rowH, sz.height); maxW = max(maxW, x - spacing)
        }
        return CGSize(width: proposal.width ?? maxW, height: y + rowH)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var rows: [[(Subviews.Element, CGSize)]] = [[]]
        var x: CGFloat = 0
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > bounds.width, x > 0 { rows.append([]); x = 0 }
            rows[rows.count - 1].append((s, sz)); x += sz.width + spacing
        }
        var y = bounds.minY
        for row in rows {
            let rowW = row.reduce(0) { $0 + $1.1.width } + spacing * CGFloat(max(row.count - 1, 0))
            var cx = alignment == .center ? bounds.minX + (bounds.width - rowW) / 2 : bounds.minX
            let h = row.map(\.1.height).max() ?? 0
            for (s, sz) in row { s.place(at: CGPoint(x: cx, y: y), proposal: ProposedViewSize(sz)); cx += sz.width + spacing }
            y += h + spacing
        }
    }
}
