import SwiftUI
import MnemonicsCore

/// Shared row/card for the drill-down lists.
struct WordProgressCard: View {
    let item: WordProgressItem
    var showLearnedDate = true
    var showLastUpdate = false
    @State private var showDetail = false

    private var diffColor: Color { item.word.difficulty == .basic ? .green : item.word.difficulty == .intermediate ? .orange : .red }
    private var accColor: Color { item.data.accuracyRate >= 0.8 ? .green : item.data.accuracyRate >= 0.6 ? .orange : .red }

    var body: some View {
        Button { showDetail = true } label: {
            VStack(alignment: .leading, spacing: MSpace.s) {
                HStack {
                    Text(item.word.word).font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.textPrimary)
                    Spacer()
                    Pill(text: item.word.difficulty.displayName, color: diffColor)
                    Pill(text: item.data.learningStage.displayName, color: item.data.learningStage == .mastered ? .yellow : item.data.learningStage == .learning ? .orange : .blue)
                }
                Text(item.word.meaning).font(MFont.small).foregroundStyle(MColor.textSecondary).lineLimit(2).multilineTextAlignment(.leading)
                HStack(spacing: MSpace.m) {
                    if showLearnedDate, let d = item.data.firstLearnedAt {
                        Label(d.formatted(date: .abbreviated, time: .omitted), systemImage: "clock").font(.system(size: 12))
                    }
                    if showLastUpdate, let d = item.data.lastReviewedAt {
                        Label("Updated \(d.formatted(.relative(presentation: .named)))", systemImage: "arrow.triangle.2.circlepath").font(.system(size: 12))
                    }
                    Label("\(item.data.reviewCount) reviews", systemImage: "repeat").font(.system(size: 12))
                    Label("\(Int((item.data.accuracyRate * 100).rounded()))%", systemImage: "target").font(.system(size: 12)).foregroundStyle(accColor)
                }.foregroundStyle(MColor.textSecondary)
            }
            .padding(MSpace.m).frame(maxWidth: .infinity, alignment: .leading).mCard()
        }.buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            NavigationStack {
                List {
                    Section("Meaning") { Text(item.word.meaning) }
                    if !item.word.example.isEmpty { Section("Example") { Text(item.word.example) } }
                    if !item.word.mnemonic.isEmpty { Section("Mnemonic") { Text(item.word.mnemonic) } }
                    Section("Learning Progress") {
                        Text("Stage: \(item.data.learningStage.displayName)"); Text("Reviews: \(item.data.reviewCount)")
                        Text("Accuracy: \(Int((item.data.accuracyRate * 100).rounded()))%")
                        if let n = item.data.nextReview { Text("Next review: \(n.formatted(date: .abbreviated, time: .shortened))") }
                    }
                }
                .navigationTitle(item.word.word).navigationBarTitleDisplayModeIfAvailable()
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showDetail = false } } }
            }.presentationDetents([.medium, .large])
        }
    }
}

struct SummaryCard: View {
    let label: String, value: String, symbol: String, color: Color
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: symbol).foregroundStyle(color)
            Text(value).font(.system(size: 18, weight: .bold)).foregroundStyle(MColor.textPrimary).lineLimit(1).minimumScaleFactor(0.6)
            Text(label).font(.system(size: 11)).foregroundStyle(MColor.textSecondary)
        }.frame(maxWidth: .infinity).padding(.vertical, MSpace.m).mCard(radius: MSpace.radiusL)
    }
}

/// Generic searchable/filterable/sortable list used by Total Words, Words Today, Learning Stages and Breakdown.
struct WordCollectionList: View {
    let items: [WordProgressItem]
    var summary: [(String, String, String, Color)] = []
    var showStageFilter = false
    var recentUsesLastReview = false
    var emptyTitle = "No words yet!"
    var emptySubtitle = "Start learning to see your progress here!"
    var showLastUpdate = false
    var allowSort = true

    @State private var search = ""
    @State private var category = "All"
    @State private var difficulty = "All"
    @State private var stage = "All"
    @State private var sort = "Recent"

    private var categories: [String] { ["All"] + Set(items.map(\.word.category)).sorted() }
    private var filtered: [WordProgressItem] {
        let q = search.lowercased()
        let f = items.filter { i in
            if !q.isEmpty, !(i.word.word.lowercased().contains(q) || i.word.meaning.lowercased().contains(q) || i.word.mnemonic.lowercased().contains(q)) { return false }
            if category != "All", i.word.category != category { return false }
            if difficulty != "All", i.word.difficulty != ["Easy": .basic, "Medium": .intermediate, "Hard": .advanced][difficulty] { return false }
            if stage != "All", i.data.learningStage.displayName != stage { return false }
            return true
        }
        return StatisticsCalculator.sorted(f, by: sort, recentUsesLastReview: recentUsesLastReview)
    }
    private var filtersActive: Bool { !search.isEmpty || category != "All" || difficulty != "All" || stage != "All" }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: MSpace.m) {
                if !summary.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: MSpace.s), count: 2), spacing: MSpace.s) {
                        ForEach(Array(summary.enumerated()), id: \.offset) { _, s in SummaryCard(label: s.0, value: s.1, symbol: s.2, color: s.3) }
                    }.staggeredEntrance(0)
                }
                HStack { Image(systemName: "magnifyingglass").foregroundStyle(MColor.textSecondary)
                    TextField("Search words, meanings, or mnemonics...", text: $search).autocorrectionDisabled() }
                    .padding(MSpace.m).background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusXL)).staggeredEntrance(1)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        menu("Category", $category, categories)
                        menu("Difficulty", $difficulty, ["All", "Easy", "Medium", "Hard"])
                        if showStageFilter { menu("Stage", $stage, ["All", "New", "Learning", "Mastered"]) }
                        if allowSort { menu("Sort", $sort, ["Recent", "Alphabetical", "Difficulty", "Accuracy"]) }
                    }
                }
                HStack {
                    Text("\(filtered.count) word\(filtered.count == 1 ? "" : "s")").font(MFont.small.weight(.semibold)).foregroundStyle(MColor.textSecondary)
                    Spacer()
                    if filtersActive { Button("Clear Filters") { search = ""; category = "All"; difficulty = "All"; stage = "All" }.font(MFont.small) }
                }
                if filtered.isEmpty {
                    VStack(spacing: MSpace.s) {
                        Image(systemName: "magnifyingglass").font(.system(size: 56)).foregroundStyle(MColor.textSecondary)
                        Text(filtersActive ? "No words match your filters" : emptyTitle).font(MFont.bodyLarge)
                        Text(filtersActive ? "Try adjusting your search or filters" : emptySubtitle).foregroundStyle(MColor.textSecondary)
                    }.padding(.top, MSpace.xl)
                } else {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { i, w in WordProgressCard(item: w, showLastUpdate: showLastUpdate).staggeredEntrance(min(i, 8) + 2) }
                }
            }
            .padding(MSpace.m).padding(.bottom, 120)
        }
        .mScreenBackground()
    }

    private func menu(_ title: String, _ sel: Binding<String>, _ opts: [String]) -> some View {
        Menu {
            Picker(title, selection: sel) { ForEach(opts, id: \.self) { Text($0).tag($0) } }
        } label: {
            HStack(spacing: 4) { Text("\(title): \(sel.wrappedValue)").font(MFont.small); Image(systemName: "chevron.down").font(.system(size: 10)) }
                .padding(.horizontal, 12).padding(.vertical, 8).background(MColor.surface, in: Capsule()).overlay(Capsule().stroke(MColor.border))
        }
    }
}

private func mostCommon(_ keys: [String]) -> String {
    Dictionary(grouping: keys, by: { $0 }).max { $0.value.count < $1.value.count }?.key.capitalized ?? "-"
}

// MARK: Total words

struct TotalWordsDetailView: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        let items = StatisticsCalculator.learnedItems(StatisticsCalculator.join(vocab: model.words, userData: Array(model.progress.values)))
        let acc = items.isEmpty ? 0 : items.map(\.data.accuracyRate).reduce(0, +) / Double(items.count)
        WordCollectionList(items: items, summary: [
            ("Total Words", "\(items.count)", "graduationcap.fill", MColor.primaryGreen),
            ("Avg Accuracy", "\(Int((acc * 100).rounded()))%", "target", .purple),
            ("Mastered", "\(items.filter { $0.data.learningStage == .mastered }.count)", "star.fill", .yellow),
            ("Learning", "\(items.filter { $0.data.learningStage == .learning }.count)", "brain.head.profile", .orange),
            ("Most Common", mostCommon(items.map(\.word.category)), "square.grid.2x2", .blue),
            ("Hardest Level", hardest(items), "bolt.fill", .red),
        ], showStageFilter: true, emptyTitle: "No words learned yet!")
        .navigationTitle("🎓 All Learned Words").navigationBarTitleDisplayModeIfAvailable()
    }
    private func hardest(_ items: [WordProgressItem]) -> String {
        items.map(\.word.difficulty).max { $0.rank < $1.rank }?.displayName ?? "-"
    }
}

// MARK: Words today

struct WordsTodayDetailView: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        let items = StatisticsCalculator.todaysItems(StatisticsCalculator.join(vocab: model.words, userData: Array(model.progress.values)))
        let acc = items.isEmpty ? 0 : items.map(\.data.accuracyRate).reduce(0, +) / Double(items.count)
        WordCollectionList(items: items, summary: [
            ("Words Learned", "\(items.count)", "graduationcap.fill", MColor.primaryGreen),
            ("Avg Accuracy", "\(Int((acc * 100).rounded()))%", "brain.head.profile", .purple),
            ("Easiest", items.min { $0.word.difficulty.rank < $1.word.difficulty.rank }?.word.difficulty.displayName ?? "-", "face.smiling", .green),
            ("Hardest", items.max { $0.word.difficulty.rank < $1.word.difficulty.rank }?.word.difficulty.displayName ?? "-", "face.dashed", .red),
        ], emptyTitle: "No words learned today yet!", allowSort: false)
        .navigationTitle("📚 Words Learned Today").navigationBarTitleDisplayModeIfAvailable()
    }
}

// MARK: Learning stages

struct LearningStagesDetailView: View {
    @Environment(AppModel.self) private var model
    let stage: String
    private var title: String {
        switch stage.lowercased() { case "new": "🆕 New Words"; case "learning": "🧠 Learning Words"; case "mastered": "⭐ Mastered Words"; default: "📚 Words" }
    }
    var body: some View {
        let target: LearningStage = stage.lowercased() == "new" ? .newWord : stage.lowercased() == "learning" ? .learning : .mastered
        let items = StatisticsCalculator.join(vocab: model.words, userData: Array(model.progress.values)).filter { $0.data.learningStage == target }
        let acc = items.isEmpty ? 0 : items.map(\.data.accuracyRate).reduce(0, +) / Double(items.count)
        WordCollectionList(items: items, summary: [
            ("\(stage.capitalized) Words", "\(items.count)", "list.bullet", MColor.primaryGreen),
            ("Avg Accuracy", "\(Int((acc * 100).rounded()))%", "target", .purple),
            ("Most Common", mostCommon(items.map(\.word.category)), "square.grid.2x2", .blue),
        ], recentUsesLastReview: true, emptyTitle: "No \(stage.lowercased()) words yet!", showLastUpdate: target == .learning)
        .navigationTitle(title).navigationBarTitleDisplayModeIfAvailable()
    }
}

// MARK: Breakdown

struct BreakdownDetailView: View {
    @Environment(AppModel.self) private var model
    let type: String
    let filter: String?
    @State private var sort = "Frequency"
    @State private var search = ""

    private var byCategory: Bool { type == "category" }
    private var title: String {
        if let f = filter { return f.prefix(1).uppercased() + f.dropFirst() + " Words" }
        return byCategory ? "Progress by Category" : "Progress by Difficulty"
    }

    var body: some View {
        let items = StatisticsCalculator.join(vocab: model.words, userData: Array(model.progress.values))
        let cats = StatisticsCalculator.breakdown(items, byCategory: byCategory)
        Group {
            if let f = filter {
                if let c = cats.first(where: { $0.name == f }) {
                    WordCollectionList(items: c.words, summary: [
                        ("Words", "\(c.totalCount)", "list.bullet", MColor.primaryGreen),
                        ("Avg Accuracy", "\(Int((c.averageAccuracy * 100).rounded()))%", "target", .purple),
                        ("Mastered", "\(c.masteredCount)", "star.fill", .yellow), ("Learning", "\(c.learningCount)", "brain.head.profile", .orange),
                    ], recentUsesLastReview: true)
                } else { Text("No data found for this category").foregroundStyle(MColor.textSecondary).frame(maxHeight: .infinity) }
            } else { overview(cats) }
        }
        .navigationTitle(title).navigationBarTitleDisplayModeIfAvailable()
    }

    private func overview(_ cats: [BreakdownCategory]) -> some View {
        let shown = sorted(cats.filter { search.isEmpty || $0.name.lowercased().contains(search.lowercased()) })
        let total = cats.reduce(0) { $0 + $1.totalCount }
        let acc = total == 0 ? 0 : cats.reduce(0) { $0 + $1.averageAccuracy * Double($1.totalCount) } / Double(total)
        return ScrollView {
            VStack(spacing: MSpace.m) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: MSpace.s), count: 2), spacing: MSpace.s) {
                    SummaryCard(label: "Total \(byCategory ? "Categories" : "Levels")", value: "\(cats.count)", symbol: byCategory ? "square.grid.2x2" : "speedometer", color: MColor.primaryGreen)
                    SummaryCard(label: "Total Words", value: "\(total)", symbol: "list.bullet", color: .blue)
                    SummaryCard(label: "Avg Accuracy", value: "\(Int((acc * 100).rounded()))%", symbol: "target", color: .purple)
                    SummaryCard(label: "Most Popular", value: cats.max { $0.totalCount < $1.totalCount }?.name.capitalized ?? "-", symbol: "star.fill", color: .yellow)
                }
                HStack { Image(systemName: "magnifyingglass").foregroundStyle(MColor.textSecondary)
                    TextField("Search \(type)s...", text: $search).autocorrectionDisabled() }
                    .padding(MSpace.m).background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                Picker("Sort", selection: $sort) { Text("By Frequency").tag("Frequency"); Text("Alphabetical").tag("Alphabetical"); Text("By Word Count").tag("Count") }.pickerStyle(.segmented)
                if shown.isEmpty { Text("No \(type)s found").foregroundStyle(MColor.textSecondary).padding(.top, MSpace.xl) }
                ForEach(shown) { c in
                    NavigationLink(value: Route.breakdown(type: type, filter: c.name)) {
                        VStack(alignment: .leading, spacing: MSpace.s) {
                            HStack { Text(c.name.capitalized).font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.textPrimary); Spacer()
                                Text("\(c.totalCount) words").foregroundStyle(MColor.textSecondary); Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(MColor.textSecondary) }
                            HStack { Pill(text: "Mastered \(c.masteredCount)", color: .yellow); Pill(text: "Learning \(c.learningCount)", color: .orange); Pill(text: "New \(c.newCount)", color: .blue) }
                            ProgressView(value: c.averageAccuracy).tint(MColor.primaryGreen)
                        }.padding(MSpace.m).mCard()
                    }.buttonStyle(.plain)
                }
            }.padding(MSpace.m).padding(.bottom, 120)
        }.mScreenBackground()
    }

    private func sorted(_ c: [BreakdownCategory]) -> [BreakdownCategory] {
        switch sort {
        case "Alphabetical": return c.sorted { $0.name < $1.name }
        case "Count": return c.sorted { $0.totalCount > $1.totalCount }
        default: return c.sorted { $0.totalCount != $1.totalCount ? $0.totalCount > $1.totalCount : $0.averageAccuracy > $1.averageAccuracy }
        }
    }
}
