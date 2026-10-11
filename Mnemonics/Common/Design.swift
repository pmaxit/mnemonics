import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// Port of lib/common/design/design_system.dart

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255, opacity: opacity)
    }
    /// Adaptive color (light / dark).
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
        #else
        self = light
        #endif
    }
}

enum MColor {
    static let primaryGreen = Color(hex: 0x4CAF8F)
    static let secondaryOrange = Color(hex: 0xF4A261)
    static let progressPink = Color(hex: 0xF8BBD0)

    static let surfaceLight = Color(hex: 0xF8F9FA)
    static let darkBackground = Color(hex: 0x1A1A1A)
    static let darkSurface = Color(hex: 0x2D2D2D)
    static let darkBorder = Color(hex: 0x404040)

    // Adaptive
    static let background = Color(light: .white, dark: darkBackground)
    static let surface = Color(light: surfaceLight, dark: darkSurface)
    static let card = Color(light: .white, dark: darkSurface)
    static let textPrimary = Color(light: Color(hex: 0x2D3436), dark: Color(hex: 0xE0E0E0))
    static let textSecondary = Color(light: Color(hex: 0x636E72), dark: Color(hex: 0xA0A0A0))
    static let border = Color(light: Color.black.opacity(0.06), dark: darkBorder.opacity(0.3))

    static let success = primaryGreen
    static let warning = secondaryOrange
    static let danger = Color.red

    /// Home word-set accents (home_screen.dart `accentColors`).
    static let setAccents: [Color] = [
        0x4CAF50, 0xE91E63, 0xFF7043, 0x26A69A, 0x5C6BC0, 0x7E57C2, 0xEF5350,
        0x455A64, 0x66BB6A, 0xFFA726, 0x42A5F5, 0x26C6DA, 0xFFCA28, 0x673AB7,
    ].map { Color(hex: $0) }
    static let setSymbols = [
        "graduationcap.fill", "book.fill", "heart.fill", "person.fill", "waveform", "brain.head.profile",
        "bolt.fill", "hammer.fill", "scalemass.fill", "text.bubble.fill", "infinity", "arrow.triangle.2.circlepath",
        "star.fill", "bubble.left.and.bubble.right.fill",
    ]
}

enum MSpace {
    static let xs: CGFloat = 4, s: CGFloat = 8, m: CGFloat = 16, l: CGFloat = 24, xl: CGFloat = 32, xxl: CGFloat = 48
    static let radiusS: CGFloat = 4, radiusM: CGFloat = 8, radiusL: CGFloat = 12, radiusXL: CGFloat = 16
}

enum MFont {
    static let headingLarge = Font.system(size: 32, weight: .bold)
    static let headingMedium = Font.system(size: 24, weight: .semibold)
    static let bodyLarge = Font.system(size: 18, weight: .medium)
    static let body = Font.system(size: 16)
    static let small = Font.system(size: 13)
}

/// White/dark-surface rounded card with the app's soft shadow (`cardShadow` / `darkCardShadow`).
struct CardBackground: ViewModifier {
    var radius: CGFloat = MSpace.radiusXL
    func body(content: Content) -> some View {
        content
            .background(MColor.card, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(MColor.border, lineWidth: 1))
            .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
    }
}
extension View {
    func mCard(radius: CGFloat = MSpace.radiusXL) -> some View { modifier(CardBackground(radius: radius)) }
    /// Static backdrop for pushed screens; only the root shell runs the wave animation.
    func mScreenBackground(animated: Bool = false) -> some View { background(MBackground(animated: animated).ignoresSafeArea()) }
}

/// Port of `AnimatedWaveBackground`: light/dark gradient with two bezier waves (4 s reverse loop).
struct MBackground: View {
    var animated = true
    @Environment(\.colorScheme) private var scheme
    @State private var t = false
    var body: some View {
        let dark = scheme == .dark
        ZStack {
            LinearGradient(colors: dark ? [Color(hex: 0x1A1A1A), Color(hex: 0x0F172A)] : [Color(hex: 0xF8F9FA), Color(hex: 0xE3F6F5)],
                           startPoint: .top, endPoint: .bottom)
            WaveShape(progress: t ? 1 : 0).fill(dark ? Color(hex: 0x4CAF8F).opacity(0.05) : Color(hex: 0xB2DFDB).opacity(0.30))
            WaveShape2(progress: t ? 1 : 0).fill(dark ? Color.white.opacity(0.02) : Color.white.opacity(0.60))
        }
        .onAppear { if animated { withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { t = true } } }
    }
}

private struct WaveShape: Shape {
    var progress: Double
    var animatableData: Double { get { progress } set { progress = newValue } }
    func path(in r: CGRect) -> Path {
        let h = 24 + 12 * progress, w = r.width, ht = r.height
        var p = Path()
        p.move(to: CGPoint(x: 0, y: ht * 0.8))
        p.addQuadCurve(to: CGPoint(x: w * 0.5, y: ht * 0.8 + h), control: CGPoint(x: w * 0.25, y: ht * 0.7 - h))
        p.addQuadCurve(to: CGPoint(x: w, y: ht * 0.8), control: CGPoint(x: w * 0.75, y: ht * 0.9 - h))
        p.addLine(to: CGPoint(x: w, y: ht)); p.addLine(to: CGPoint(x: 0, y: ht)); p.closeSubpath()
        return p
    }
}
private struct WaveShape2: Shape {
    var progress: Double
    var animatableData: Double { get { progress } set { progress = newValue } }
    func path(in r: CGRect) -> Path {
        let o = 32 * progress, w = r.width, ht = r.height
        var p = Path()
        p.move(to: CGPoint(x: 0, y: ht * 0.9))
        p.addQuadCurve(to: CGPoint(x: w * 0.5, y: ht * 0.9 - o), control: CGPoint(x: w * 0.25, y: ht * 0.8 + o))
        p.addQuadCurve(to: CGPoint(x: w, y: ht * 0.9), control: CGPoint(x: w * 0.75, y: ht + o))
        p.addLine(to: CGPoint(x: w, y: ht)); p.addLine(to: CGPoint(x: 0, y: ht)); p.closeSubpath()
        return p
    }
}

/// Port of `AnimatedTabHeaderCard`: fixed 120 pt card; fades in over the first 0.6 of 1.2 s and slides up 50 pt over 0.3–1.0.
struct TabHeaderCard<Leading: View>: View {
    let title: String
    let subtitle: String
    var trailingSymbol: String = "sparkles"
    var trailingColor: Color = MColor.secondaryOrange
    @ViewBuilder var leading: Leading
    @State private var fade = 0.0
    @State private var slide = 50.0

    var body: some View {
        HStack(spacing: MSpace.m) {
            leading.frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 20, weight: .bold)).foregroundStyle(MColor.textPrimary).lineLimit(1)
                Text(subtitle).font(MFont.small).foregroundStyle(MColor.textSecondary).lineLimit(2)
            }
            Spacer(minLength: 0)
            Image(systemName: trailingSymbol).font(.system(size: 20)).foregroundStyle(trailingColor)
                .padding(10).background(trailingColor.opacity(0.12), in: Circle())
        }
        .padding(MSpace.m)
        .frame(maxWidth: .infinity).frame(height: 120)
        .mCard()
        .opacity(fade).offset(y: slide)
        .onAppear {
            withAnimation(.easeOut(duration: 0.72)) { fade = 1 }
            withAnimation(.easeOut(duration: 0.84).delay(0.36)) { slide = 0 }
        }
    }
}

extension TabHeaderCard where Leading == LogoLeading {
    init(symbol: String? = nil, logo: Bool = true, title: String, subtitle: String,
         trailingSymbol: String = "sparkles", trailingColor: Color = MColor.secondaryOrange) {
        self.init(title: title, subtitle: subtitle, trailingSymbol: trailingSymbol, trailingColor: trailingColor) {
            LogoLeading(symbol: symbol ?? "text.book.closed.fill")
        }
    }
}

struct LogoLeading: View {
    let symbol: String
    var body: some View {
        Image(systemName: symbol).font(.system(size: 22, weight: .semibold)).foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(LinearGradient(colors: [MColor.primaryGreen, MColor.primaryGreen.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: MSpace.radiusL))
    }
}

/// Port of `AnimatedProgressUtils.buildStaggeredAnimation`: fade + 30 pt slide, 400 ms ease-out-cubic, 100 ms per index.
struct StaggeredEntrance: ViewModifier {
    let index: Int
    @State private var shown = false
    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0).offset(y: shown ? 0 : 30)
            .onAppear {
                withAnimation(.timingCurve(0.215, 0.61, 0.355, 1, duration: 0.4).delay(Double(index) * 0.1)) { shown = true }
            }
    }
}
extension View {
    func staggeredEntrance(_ index: Int) -> some View { modifier(StaggeredEntrance(index: index)) }
}

struct Pill: View {
    let text: String
    var color: Color = MColor.primaryGreen
    var body: some View {
        Text(text).font(.system(size: 12, weight: .bold)).foregroundStyle(color)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: MSpace.radiusM))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = MColor.primaryGreen
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(MFont.bodyLarge.weight(.semibold)).foregroundStyle(.white)
            .frame(maxWidth: .infinity).padding(.vertical, MSpace.m)
            .background(color, in: RoundedRectangle(cornerRadius: MSpace.radiusXL))
            .shadow(color: color.opacity(0.35), radius: 8, y: 4)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct StatTile: View {
    let symbol: String, value: String, label: String
    var color: Color = MColor.primaryGreen
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol).font(.system(size: 20)).foregroundStyle(color)
            Text(value).font(.system(size: 22, weight: .bold)).foregroundStyle(MColor.textPrimary).minimumScaleFactor(0.6).lineLimit(1)
            Text(label).font(.system(size: 12)).foregroundStyle(MColor.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, MSpace.m).mCard()
    }
}

enum Haptics {
    static func light() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
    static func success() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
}
