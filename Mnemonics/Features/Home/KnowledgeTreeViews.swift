import SwiftUI
import MnemonicsCore

/// Deterministic RNG so the tree keeps a consistent shape (Flutter uses Random(42)).
struct SeededRNG {
    var state: UInt64
    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double((state >> 33) & 0x7FFFFFFF) / Double(0x7FFFFFFF)
    }
}

struct TreeCanvas: View {
    let depth: Int
    let health: Double
    let growth: Double
    let branches: [TreeBranchSpec]

    var body: some View {
        Canvas { ctx, size in
            var rng = SeededRNG(state: 42)
            let healthy = Color(hex: 0x6D4C41), dry = Color(hex: 0x8D6E63)
            let trunkColor = lerp(healthy, dry, 1 - health)
            let leafColor = lerp(Color(hex: 0xD84315), MColor.primaryGreen, health)
            let startX = size.width / 2, startY = size.height
            guard growth > 0.01 else { return }

            func line(_ a: CGPoint, _ b: CGPoint, _ w: CGFloat) {
                var p = Path(); p.move(to: a); p.addLine(to: b)
                ctx.stroke(p, with: .color(trunkColor), style: StrokeStyle(lineWidth: w, lineCap: .round))
            }
            func dot(_ c: CGPoint, _ r: CGFloat, _ color: Color) {
                ctx.fill(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)), with: .color(color))
            }

            if branches.isEmpty {
                let heightScale = 0.5 + (Double(depth) / 7.0) * 0.5
                let len = (size.height / 4.5) * growth * heightScale
                line(CGPoint(x: startX, y: startY), CGPoint(x: startX, y: startY - len), CGFloat(4 + depth))
                if health > 0.1 { dot(CGPoint(x: startX, y: startY - len), CGFloat(8 + depth), leafColor.opacity(0.78)) }
                return
            }

            let maxWords = max(1, branches.map(\.wordCount).max() ?? 1)
            let trunkLen = size.height * (0.30 + Double(min(branches.count, 4)) * 0.04)
            let trunkEnd = CGPoint(x: startX, y: startY - trunkLen * growth)
            line(CGPoint(x: startX, y: startY), trunkEnd, 8 + min(Double(branches.count) * 1.5, 8))

            let n = branches.count
            let spread = n == 1 ? 0 : Double.pi * 0.75
            let startAngle = -spread / 2
            for (i, b) in branches.enumerated() {
                let angle = n == 1 ? 0 : startAngle + Double(i) * (spread / Double(n - 1))
                let g = 0.45 + 0.55 * (Double(b.wordCount) / Double(maxWords))
                let twigs = 1 + min(b.wordCount / 3, 2)
                let len = (size.height * 0.34) * g * growth
                let a = angle + (rng.next() * 0.1 - 0.05)
                let end = CGPoint(x: trunkEnd.x + len * sin(a), y: trunkEnd.y - len * cos(a))
                line(trunkEnd, end, 3 + Double(b.wordCount) * 0.8)
                let twigSpread = Double.pi * 0.5
                for t in 0..<twigs {
                    let ta = twigs == 1 ? a : (a - twigSpread / 2) + Double(t) * (twigSpread / Double(twigs - 1))
                    let tl = len * (0.45 + rng.next() * 0.2)
                    let tend = CGPoint(x: end.x + tl * sin(ta), y: end.y - tl * cos(ta))
                    line(end, tend, 2)
                    if health > 0.1 {
                        let cluster = lerp(Color(hex: b.colorHex), leafColor, 0.35).opacity(min(max(200 * health, 120), 255) / 255)
                        let r = 7 + Double(min(b.wordCount, 8)) * 1.1
                        dot(tend, r, cluster)
                        dot(CGPoint(x: tend.x + rng.next() * 8 - 4, y: tend.y + rng.next() * 8 - 4), r * 0.6, cluster)
                    }
                }
                if b.wordCount >= 5 && health > 0.15 { dot(end, 4.5, Color(hex: 0xFFD740)) }
            }
        }
    }

    private func lerp(_ a: Color, _ b: Color, _ t: Double) -> Color {
        #if canImport(UIKit)
        var (ar, ag, ab, aa): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (br, bg, bb, ba): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        UIColor(a).getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        UIColor(b).getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        let k = CGFloat(min(max(t, 0), 1))
        return Color(.sRGB, red: Double(ar + (br - ar) * k), green: Double(ag + (bg - ag) * k), blue: Double(ab + (bb - ab) * k))
        #else
        return t > 0.5 ? b : a
        #endif
    }
}

struct KnowledgeTreeCard: View {
    @Environment(AppModel.self) private var model
    @Environment(Router.self) private var router
    @State private var growth = 0.0

    private var branches: [TreeBranchSpec] {
        let w2c = Dictionary(model.words.map { ($0.word, $0.category) }, uniquingKeysWith: { a, _ in a })
        let learned = model.progress.values.filter { $0.isLearned || $0.hasBeenTested || $0.reviewCount > 0 }.map(\.word)
        return KnowledgeTree.branches(learnedWords: learned, wordToCategory: w2c)
    }
    private var days: Int { model.stats.lastStudyDate.map { Calendar.current.dateComponents([.day], from: $0, to: Date()).day ?? 0 } ?? 0 }
    private var healthColor: Color { days < 2 ? MColor.primaryGreen : days < 5 ? .orange : .brown }

    var body: some View {
        let total = model.stats.totalWordsLearned
        let b = branches
        Button { router.push(.knowledgeTree) } label: {
            VStack(spacing: MSpace.m) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: MSpace.xs) {
                        Text("Your Knowledge Tree").font(MFont.headingMedium).foregroundStyle(MColor.textPrimary)
                        Text(KnowledgeTree.statusMessage(totalLearned: total, daysSincePractice: days, branches: b))
                            .font(MFont.body.weight(.medium)).foregroundStyle(healthColor).multilineTextAlignment(.leading)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: MSpace.xs) {
                        Text(KnowledgeTree.levelName(totalLearned: total)).font(MFont.body.bold()).foregroundStyle(healthColor)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(healthColor.opacity(0.12), in: Capsule()).overlay(Capsule().stroke(healthColor.opacity(0.4)))
                        Text("\(total) Words").font(MFont.body.bold()).foregroundStyle(MColor.textSecondary)
                    }
                }
                TreeCanvas(depth: KnowledgeTree.depth(totalLearned: total), health: KnowledgeTree.healthFactor(daysSincePractice: days),
                           growth: growth, branches: b)
                    .frame(height: 250)
                if !b.isEmpty {
                    FlowLayout(spacing: MSpace.s, alignment: .center) {
                        ForEach(b) { br in
                            let label = br.category.count > 12 ? String(br.category.prefix(12)) + "…" : br.category
                            Text("\(label) • \(br.wordCount)").font(.system(size: 11, weight: .semibold)).foregroundStyle(Color(hex: br.colorHex))
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color(hex: br.colorHex).opacity(0.12), in: RoundedRectangle(cornerRadius: MSpace.radiusM))
                                .overlay(RoundedRectangle(cornerRadius: MSpace.radiusM).stroke(Color(hex: br.colorHex).opacity(0.35)))
                        }
                    }
                }
                Capsule().fill(MColor.primaryGreen.opacity(0.4)).frame(width: 120, height: 4)
            }
            .padding(MSpace.l)
            .background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
            .shadow(color: MColor.primaryGreen.opacity(0.08), radius: 20, y: 10)
        }
        .buttonStyle(.plain)
        .onAppear { growth = 0; withAnimation(.interpolatingSpring(stiffness: 40, damping: 7).speed(0.8)) { growth = 1 } }
        .onChange(of: total) { _, _ in growth = 0; withAnimation(.interpolatingSpring(stiffness: 40, damping: 7)) { growth = 1 } }
    }
}

/// "Your Word Canopy" — port of knowledge_tree_detail_screen.dart with the Tree Spirit AI modal.
struct KnowledgeTreeDetailView: View {
    @Environment(AppModel.self) private var model
    @State private var wisdom: String?
    @State private var loading = false
    @State private var growth = 0.0

    var body: some View {
        let w2c = Dictionary(model.words.map { ($0.word, $0.category) }, uniquingKeysWith: { a, _ in a })
        let learned = model.progress.values.filter { $0.isLearned || $0.hasBeenTested || $0.reviewCount > 0 }.map(\.word)
        let branches = KnowledgeTree.branches(learnedWords: learned, wordToCategory: w2c)
        let days = model.stats.lastStudyDate.map { Calendar.current.dateComponents([.day], from: $0, to: Date()).day ?? 0 } ?? 0
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: MSpace.l) {
                    TreeCanvas(depth: KnowledgeTree.depth(totalLearned: learned.count), health: KnowledgeTree.healthFactor(daysSincePractice: days),
                               growth: growth, branches: branches)
                        .frame(height: 380).padding()
                    ForEach(branches) { b in
                        HStack {
                            Circle().fill(Color(hex: b.colorHex)).frame(width: 14, height: 14)
                            Text(b.category.capitalized).font(MFont.bodyLarge)
                            Spacer()
                            Text("\(b.wordCount) words").foregroundStyle(MColor.textSecondary)
                        }.padding(MSpace.m).mCard()
                    }
                    if branches.isEmpty { Text("Learn some words to grow your canopy.").foregroundStyle(MColor.textSecondary) }
                }.padding(.horizontal, MSpace.m).padding(.bottom, 120)
            }
            Button { Task { await listen() } } label: {
                Label("Tree Spirit", systemImage: "sparkles").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                    .padding(.horizontal, 18).padding(.vertical, 12).background(MColor.primaryGreen, in: Capsule())
            }.padding(MSpace.l).padding(.bottom, 80)
            if loading {
                Color.black.opacity(0.5).ignoresSafeArea()
                VStack(spacing: MSpace.m) { ProgressView().tint(MColor.primaryGreen); Text("Listening to the Tree Spirit...").italic().foregroundStyle(.white) }
            }
        }
        .mScreenBackground()
        .navigationTitle("Your Word Canopy").navigationBarTitleDisplayModeIfAvailable()
        .onAppear { withAnimation(.interpolatingSpring(stiffness: 40, damping: 7)) { growth = 1 } }
        .alert("Tree of Knowledge Says:", isPresented: Binding(get: { wisdom != nil }, set: { if !$0 { wisdom = nil } })) {
            Button("Continue Growing", role: .cancel) {}
        } message: { Text(wisdom ?? "") }
    }

    private func listen() async {
        loading = true; defer { loading = false }
        wisdom = await model.ai.generateTreeWisdom(totalLearned: model.stats.totalWordsLearned, accuracy: model.stats.averageAccuracy, streak: model.stats.streak)
    }
}
