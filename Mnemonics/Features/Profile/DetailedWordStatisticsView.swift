import SwiftUI
import MnemonicsCore

/// Port of detailed_word_statistics_screen.dart: reviewed / remaining sections, search, sort, paging.
struct DetailedWordStatisticsView: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router
    let type: WordStatType
    var category: String? = nil
    @State private var search = ""
    @State private var sortBy = "word"
    @State private var ascending = true
    @State private var showReviewed = true
    @State private var showRemaining = true
    @State private var reviewedCount = 20
    @State private var remainingCount = 20

    private let page = 20

    var body: some View {
        let all = DetailedWords.filter(vocab: model.words, progress: model.progress, type: type, category: category, search: search, sortBy: sortBy, ascending: ascending)
        let reviewed = all.filter(\.isReviewed), remaining = all.filter { !$0.isReviewed }
        ScrollView {
            LazyVStack(alignment: .leading, spacing: MSpace.m) {
                VStack(alignment: .leading, spacing: MSpace.s) {
                    Text(type.detail).font(MFont.body).foregroundStyle(MColor.textSecondary)
                    HStack { Image(systemName: "magnifyingglass").foregroundStyle(MColor.textSecondary); TextField("Search words...", text: $search).autocorrectionDisabled() }
                        .padding(MSpace.m).background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
                    if let category { Label("Category: \(category)", systemImage: "line.3.horizontal.decrease").font(MFont.small) }
                }
                HStack {
                    summary("Reviewed", reviewed.count, "checkmark.circle", MColor.primaryGreen)
                    summary("Remaining", remaining.count, "hourglass", MColor.secondaryOrange)
                    summary("Total", all.count, "books.vertical", .blue)
                }.padding(MSpace.m).mCard(radius: MSpace.radiusL)

                if all.isEmpty {
                    VStack(spacing: MSpace.s) { Image(systemName: "magnifyingglass").font(.system(size: 44)); Text("No words found").font(MFont.bodyLarge); Text("Try adjusting your search criteria") }
                        .foregroundStyle(MColor.textSecondary).frame(maxWidth: .infinity).padding(.top, MSpace.xl)
                }
                if !reviewed.isEmpty {
                    header("Reviewed Words", reviewed.count, "checkmark.circle.fill", MColor.primaryGreen, $showReviewed)
                    if showReviewed { section(reviewed, $reviewedCount, all) }
                }
                if !remaining.isEmpty {
                    header("Remaining Words", remaining.count, "hourglass.circle.fill", MColor.secondaryOrange, $showRemaining)
                    if showRemaining { section(remaining, $remainingCount, all) }
                }
            }.padding(MSpace.m).padding(.bottom, 130)
        }
        .mScreenBackground()
        .navigationTitle(type.title).navigationBarTitleDisplayModeIfAvailable()
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    Picker("Sort", selection: $sortBy) {
                        Text("Sort by Word").tag("word"); Text("Sort by Accuracy").tag("accuracy")
                        Text("Sort by Difficulty").tag("difficulty"); Text("Sort by Last Reviewed").tag("lastReviewed")
                    }
                } label: { Image(systemName: "arrow.up.arrow.down") }
                Button { ascending.toggle() } label: { Image(systemName: ascending ? "arrow.up" : "arrow.down") }
            }
        }
        .onChange(of: sortBy) { _, _ in reviewedCount = page; remainingCount = page }
        .onChange(of: ascending) { _, _ in reviewedCount = page; remainingCount = page }
        .onChange(of: search) { _, _ in reviewedCount = page; remainingCount = page }
    }

    private func summary(_ l: String, _ n: Int, _ sym: String, _ c: Color) -> some View {
        VStack(spacing: 2) { Image(systemName: sym).foregroundStyle(c); Text("\(n)").font(MFont.bodyLarge.weight(.bold)); Text(l).font(.system(size: 12)).foregroundStyle(MColor.textSecondary) }.frame(maxWidth: .infinity)
    }
    private func header(_ t: String, _ n: Int, _ sym: String, _ c: Color, _ open: Binding<Bool>) -> some View {
        Button { withAnimation { open.wrappedValue.toggle() } } label: {
            HStack { Image(systemName: sym).foregroundStyle(c); Text(t).font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.textPrimary); Pill(text: "\(n)", color: c); Spacer()
                Image(systemName: open.wrappedValue ? "chevron.up" : "chevron.down").foregroundStyle(MColor.textSecondary) }
                .padding(MSpace.m).background(c.opacity(0.08), in: RoundedRectangle(cornerRadius: MSpace.radiusL))
        }.buttonStyle(.plain)
    }
    @ViewBuilder private func section(_ words: [WordWithData], _ count: Binding<Int>, _ all: [WordWithData]) -> some View {
        ForEach(words.prefix(count.wrappedValue)) { w in card(w) }
        if count.wrappedValue < words.count {
            Button("Load More (\(words.count - count.wrappedValue) remaining)") { count.wrappedValue = min(words.count, count.wrappedValue + page) }.frame(maxWidth: .infinity)
        }
    }
    private func card(_ w: WordWithData) -> some View {
        Button { router.push(.flashcards(words: [w.word], initialIndex: 0)) } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack { Text(w.word.word).font(MFont.bodyLarge.weight(.bold)).foregroundStyle(MColor.textPrimary); Spacer()
                    Pill(text: w.word.difficulty.displayName, color: w.word.difficulty == .basic ? .green : w.word.difficulty == .intermediate ? .orange : .red) }
                Text(w.word.meaning).font(MFont.small).foregroundStyle(MColor.textSecondary).lineLimit(2).multilineTextAlignment(.leading)
                if let d = w.data, d.totalAnswers > 0 {
                    HStack { Text("\(Int((d.accuracyRate * 100).rounded()))% accuracy"); if let r = d.lastReviewedAt { Text("· " + ago(r)) } }.font(.system(size: 12)).foregroundStyle(MColor.textSecondary)
                }
            }.padding(MSpace.m).frame(maxWidth: .infinity, alignment: .leading).mCard(radius: MSpace.radiusL)
        }.buttonStyle(.plain)
    }
    private func ago(_ d: Date) -> String {
        let diff = Date().timeIntervalSince(d)
        if diff >= 7 * 86_400 { return "\(Int(diff / (7 * 86_400)))w ago" }
        if diff >= 86_400 { return "\(Int(diff / 86_400))d ago" }
        if diff >= 3_600 { return "\(Int(diff / 3_600))h ago" }
        return "Recently"
    }
}
