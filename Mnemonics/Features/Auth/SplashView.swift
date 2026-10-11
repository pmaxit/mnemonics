import SwiftUI

/// Port of splash_screen.dart: logo, tagline, pulsing CTA.
struct SplashView: View {
    var onContinue: () -> Void
    @State private var appeared = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            MBackground().ignoresSafeArea()
            VStack(alignment: .leading, spacing: MSpace.l) {
                Spacer().frame(height: 48)
                Image("LogoMark").resizable().scaledToFill().frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28)).shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                    .frame(maxWidth: .infinity)
                Spacer()
                VStack(alignment: .leading) {
                    Text("Let's Break").font(MFont.headingLarge).foregroundStyle(MColor.textPrimary)
                    Text("THE BARRIERS OF LANGUAGE").font(MFont.headingLarge).foregroundStyle(MColor.primaryGreen)
                }
                Spacer()
                Button3D(action: onContinue)
                    .scaleEffect(pulse ? 1.06 : 1).frame(maxWidth: .infinity)
                    .accessibilityLabel("Continue")
                Spacer().frame(height: MSpace.xl)
            }
            .padding(.horizontal, MSpace.l)
            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { appeared = true }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}

/// Port of `_Animated3DCTAButton` (orange glossy orb, 0.92 press-scale), with extra bevel/depth.
struct Button3D: View {
    let action: () -> Void
    @State private var pressed = false
    private let light = Color(hex: 0xFFB75E), deep = Color(hex: 0xF57C00)

    var body: some View {
        ZStack {
            // base: gradient orb with a darker lower rim for thickness
            Circle().fill(LinearGradient(colors: [light, deep], startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle().strokeBorder(LinearGradient(colors: [.white.opacity(0.7), .clear, Color(hex: 0xB85400).opacity(0.55)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2.5)
            // soft inner shading toward the bottom-right
            Circle().fill(RadialGradient(colors: [.clear, Color(hex: 0xB85400).opacity(0.35)], center: .init(x: 0.35, y: 0.3), startRadius: 8, endRadius: 52))
            // gloss highlight
            Capsule().fill(LinearGradient(colors: [.white.opacity(0.6), .white.opacity(0)], startPoint: .top, endPoint: .bottom))
                .frame(width: 36, height: 17).offset(y: -22)
            // arrow with its own shadow so it looks embossed
            Image(systemName: "arrow.right").font(.system(size: 32, weight: .heavy)).foregroundStyle(.white)
                .shadow(color: Color(hex: 0xB85400).opacity(0.7), radius: 1, x: 0, y: 2)
                .shadow(color: .black.opacity(0.2), radius: 3, y: 3)
        }
        .frame(width: 76, height: 76)
        // layered shadows: colored glow + contact shadow
        .shadow(color: .orange.opacity(0.4), radius: pressed ? 8 : 16, y: pressed ? 4 : 10)
        .shadow(color: .black.opacity(0.18), radius: pressed ? 2 : 4, y: pressed ? 1 : 3)
        .scaleEffect(pressed ? 0.92 : 1)
        .rotation3DEffect(.degrees(pressed ? 8 : 0), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
        .animation(.easeOut(duration: 0.12), value: pressed)
        .contentShape(Circle())
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in if !pressed { pressed = true } }
            .onEnded { v in
                pressed = false
                if abs(v.translation.width) < 40 && abs(v.translation.height) < 40 { action() }
            })
        .accessibilityAddTraits(.isButton)
    }
}
