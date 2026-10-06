import SwiftUI

/// Animated splash after the static launch storyboard. Matches the LinguaPath icon: indigo field, speech bubble, golden path.
struct LaunchView: View {
    var onFinished: () -> Void

    @EnvironmentObject var profile: UserProfileStore

    @State private var rings = false
    @State private var bubble = false
    @State private var pathAmount: CGFloat = 0
    @State private var star = false
    @State private var wordmark = false
    @State private var skills = false
    @State private var fadeOut = false

    private let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    private let indigoTop = Color(red: 0.14, green: 0.29, blue: 0.55)
    private let indigoBottom = Color(red: 0.07, green: 0.14, blue: 0.27)

    var body: some View {
        ZStack {
            LinearGradient(colors: [indigoTop, indigoBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 1.5)
                    .frame(width: 160 + CGFloat(i) * 70, height: 160 + CGFloat(i) * 70)
                    .scaleEffect(rings ? 1.12 : 0.72)
                    .opacity(rings ? 0 : 0.7)
                    .animation(
                        .easeOut(duration: 1.35).repeatForever(autoreverses: false).delay(Double(i) * 0.18),
                        value: rings
                    )
            }

            VStack(spacing: 28) {
                ZStack {
                    LinguaMark(pathAmount: pathAmount, starVisible: star)
                        .frame(width: 168, height: 168)
                        .scaleEffect(bubble ? 1 : 0.35)
                        .opacity(bubble ? 1 : 0)
                        .rotationEffect(.degrees(bubble ? 0 : -12))

                    skillChip("ear", x: -118, y: -36, delay: 0)
                    skillChip("mic.fill", x: 122, y: -28, delay: 0.08)
                    skillChip("book.fill", x: -108, y: 78, delay: 0.16)
                    skillChip("pencil.line", x: 112, y: 82, delay: 0.24)
                }
                .frame(height: 220)

                VStack(spacing: 8) {
                    Text(profile.text(.appName))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .tracking(0.6)
                    Text(profile.text(.launchTagline))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(gold.opacity(0.95))
                }
                .opacity(wordmark ? 1 : 0)
                .offset(y: wordmark ? 0 : 16)
            }
        }
        .opacity(fadeOut ? 0 : 1)
        .onAppear { runAnimation() }
        .accessibilityHidden(true)
    }

    private func skillChip(_ icon: String, x: CGFloat, y: CGFloat, delay: Double) -> some View {
        Image(systemName: icon)
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(Circle().fill(.white.opacity(0.16)))
            .offset(x: skills ? x : 0, y: skills ? y : 0)
            .opacity(skills ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.72).delay(0.55 + delay), value: skills)
    }

    private func runAnimation() {
        rings = true
        withAnimation(.spring(response: 0.7, dampingFraction: 0.68)) {
            bubble = true
        }
        withAnimation(.easeInOut(duration: 0.85).delay(0.22)) {
            pathAmount = 1
        }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.55).delay(0.85)) {
            star = true
        }
        withAnimation(.easeOut(duration: 0.45).delay(0.5)) {
            wordmark = true
        }
        skills = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.15) {
            withAnimation(.easeInOut(duration: 0.42)) {
                fadeOut = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
                onFinished()
            }
        }
    }
}

private struct LinguaMark: View {
    var pathAmount: CGFloat
    var starVisible: Bool

    var body: some View {
        ZStack {
            SpeechBubbleShape()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.99), Color(red: 0.96, green: 0.93, blue: 0.86)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.28), radius: 16, y: 10)

            GoldenPath()
                .trim(from: 0, to: pathAmount)
                .stroke(
                    LinearGradient(
                        colors: [Color(red: 0.98, green: 0.82, blue: 0.28), Color(red: 0.92, green: 0.58, blue: 0.12)],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    ),
                    style: StrokeStyle(lineWidth: 11, lineCap: .round, lineJoin: .round)
                )
                .padding(36)

            Image(systemName: "sparkle")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color(red: 0.98, green: 0.82, blue: 0.28))
                .offset(x: 40, y: -44)
                .scaleEffect(starVisible ? 1 : 0.1)
                .opacity(starVisible ? 1 : 0)
        }
    }
}

private struct SpeechBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let inset = rect.insetBy(dx: 6, dy: 10)
        let bubble = CGRect(x: inset.minX, y: inset.minY, width: inset.width, height: inset.height * 0.78)
        let radius = min(bubble.width, bubble.height) * 0.28
        var path = Path(roundedRect: bubble, cornerRadius: radius)
        var tail = Path()
        let start = CGPoint(x: bubble.maxX - bubble.width * 0.34, y: bubble.maxY - 4)
        tail.move(to: start)
        tail.addQuadCurve(
            to: CGPoint(x: bubble.maxX - bubble.width * 0.12, y: inset.maxY - 4),
            control: CGPoint(x: bubble.maxX - bubble.width * 0.18, y: bubble.maxY + 8)
        )
        tail.addQuadCurve(
            to: CGPoint(x: bubble.maxX - bubble.width * 0.22, y: bubble.maxY - 2),
            control: CGPoint(x: bubble.maxX - bubble.width * 0.14, y: bubble.maxY + 2)
        )
        path.addPath(tail)
        return path
    }
}

private struct GoldenPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 4, y: rect.maxY - 8))
        path.addCurve(
            to: CGPoint(x: rect.midX - 6, y: rect.midY + 10),
            control1: CGPoint(x: rect.minX + 28, y: rect.maxY - 36),
            control2: CGPoint(x: rect.midX - 30, y: rect.midY + 38)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX - 8, y: rect.minY + 10),
            control1: CGPoint(x: rect.midX + 28, y: rect.midY - 22),
            control2: CGPoint(x: rect.maxX - 36, y: rect.minY + 36)
        )
        return path
    }
}

#Preview {
    LaunchView(onFinished: {})
        .environmentObject(UserProfileStore.shared)
}
