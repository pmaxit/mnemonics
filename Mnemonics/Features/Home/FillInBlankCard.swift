import SwiftUI

/// Port of fill_in_blank_card.dart: tap to reveal the blanked word inside a real usage sentence.
struct FillInBlankCard: View {
    let sentence: String
    let answer: String
    var hint: String? = nil
    @State private var revealed = false

    private var parts: (before: String, match: String, after: String)? {
        guard let re = try? NSRegularExpression(pattern: "\\b(\(NSRegularExpression.escapedPattern(for: answer))\\w*)\\b", options: .caseInsensitive),
              let m = re.firstMatch(in: sentence, range: NSRange(sentence.startIndex..., in: sentence)),
              let r = Range(m.range, in: sentence) else { return nil }
        return (String(sentence[..<r.lowerBound]), String(sentence[r]), String(sentence[r.upperBound...]))
    }

    var body: some View {
        Group {
            if let p = parts {
                Button { withAnimation(.easeInOut(duration: 0.2)) { revealed.toggle() } } label: {
                    VStack(alignment: .leading, spacing: MSpace.s) {
                        (Text(p.before) + Text(revealed ? " \(p.match) " : "  ______  ")
                            .bold().foregroundColor(revealed ? MColor.primaryGreen : .gray) + Text(p.after))
                            .font(MFont.body).lineSpacing(5).foregroundStyle(MColor.textPrimary).multilineTextAlignment(.leading)
                        if revealed {
                            if let hint, !hint.isEmpty { Text(hint).font(.system(size: 13)).italic().foregroundStyle(.gray) }
                        } else {
                            Label("Tap to reveal", systemImage: "hand.tap").font(.system(size: 12)).foregroundStyle(.gray)
                        }
                    }
                }.buttonStyle(.plain)
            } else {
                Text(sentence).font(MFont.body).foregroundStyle(MColor.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(MSpace.m)
        .background(MColor.surface, in: RoundedRectangle(cornerRadius: MSpace.radiusM))
        .overlay(RoundedRectangle(cornerRadius: MSpace.radiusM).stroke(Color.gray.opacity(0.3)))
    }
}
