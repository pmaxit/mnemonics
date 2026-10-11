import SwiftUI
import MnemonicsCore

/// Port of my_words_list_screen.dart.
struct MyWordsListView: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router

    var body: some View {
        let words = model.recommendedWords
        ScrollView {
            LazyVStack(spacing: MSpace.m) {
                TabHeaderCard(title: "My Words", subtitle: "Tap a word to study it", trailingSymbol: "graduationcap.fill", trailingColor: MColor.primaryGreen)
                if words.isEmpty {
                    VStack(spacing: MSpace.m) {
                        Image(systemName: "trophy.fill").font(.system(size: 56)).foregroundStyle(MColor.secondaryOrange)
                        Text("Nothing left to practice here").font(MFont.headingMedium)
                        Text("Every recommended word at your level is learned. Pick a new level or category in Settings to grow your list.")
                            .font(MFont.body).foregroundStyle(MColor.textSecondary).multilineTextAlignment(.center)
                    }.padding(MSpace.xl)
                } else {
                    Button { router.push(.flashcards(words: words, initialIndex: 0)) } label: {
                        Label("Practice all", systemImage: "play.fill")
                    }.buttonStyle(PrimaryButtonStyle())
                    ForEach(Array(words.enumerated()), id: \.element.id) { i, w in
                        Button { router.push(.flashcards(words: words, initialIndex: i)) } label: {
                            HStack(spacing: MSpace.m) {
                                ZStack {
                                    Circle().fill(diffColor(w.difficulty).opacity(0.15)).frame(width: 36, height: 36)
                                    if model.data(for: w.word)?.isLearned == true {
                                        Image(systemName: "checkmark.circle.fill").foregroundStyle(MColor.primaryGreen)
                                    } else {
                                        Text("\(i + 1)").font(.system(size: 14, weight: .bold)).foregroundStyle(diffColor(w.difficulty))
                                    }
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(w.word).font(MFont.bodyLarge.weight(.semibold)).foregroundStyle(MColor.textPrimary)
                                    Text(w.meaning).font(MFont.small).foregroundStyle(MColor.textSecondary).lineLimit(2).multilineTextAlignment(.leading)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13)).foregroundStyle(MColor.textSecondary)
                            }
                            .padding(MSpace.m).mCard()
                        }.buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, MSpace.m).padding(.bottom, 120)
        }
        .mScreenBackground()
        .navigationTitle("My Words").navigationBarTitleDisplayModeIfAvailable()
    }

    private func diffColor(_ d: WordDifficulty) -> Color {
        switch d { case .basic: MColor.primaryGreen; case .intermediate: MColor.secondaryOrange; case .advanced: .redAccent }
    }
}

extension Color { static let redAccent = Color(hex: 0xFF5252) }
