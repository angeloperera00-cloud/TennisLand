import SwiftUI

// MARK: - Tutorial View
struct TutorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    @State private var animateIn = false

    let pages: [TutorialPage] = [
        TutorialPage(
            icon: "🎾",
            title: "Welcome to\nTennis Land",
            description: "The ultimate mobile tennis experience. Play with your fingers or use Apple Watch as your racket!",
            color: Color(red: 0.78, green: 0.9, blue: 0.29),
            tips: []
        ),
        TutorialPage(
            icon: "📱",
            title: "Mobile Play",
            description: "Control your player using touch on screen.",
            color: Color(red: 0.31, green: 0.8, blue: 0.77),
            tips: [
                TutorialTip(icon: "hand.draw.fill", text: "Drag finger LEFT or RIGHT to position"),
                TutorialTip(icon: "hand.tap.fill", text: "Tap SWING button to hit the ball"),
                TutorialTip(icon: "figure.run", text: "Player AUTO-RUNS toward the ball"),
            ]
        ),
        TutorialPage(
            icon: "⌚",
            title: "Real Play\nApple Watch",
            description: "Wear Watch on your racket hand and swing your arm naturally.",
            color: Color(red: 1.0, green: 0.35, blue: 0.35),
            tips: [
                TutorialTip(icon: "applewatch", text: "Wear Watch on your RACKET hand"),
                TutorialTip(icon: "arrow.right.circle.fill", text: "Tilt RIGHT = Forehand shot"),
                TutorialTip(icon: "arrow.left.circle.fill", text: "Tilt LEFT = Backhand shot"),
                TutorialTip(icon: "arrow.up.circle.fill", text: "Swing UP hard = Smash!"),
            ]
        ),
        TutorialPage(
            icon: "🏆",
            title: "Scoring\nSystem",
            description: "Simple and exciting scoring rules.",
            color: Color(red: 0.6, green: 0.43, blue: 0.98),
            tips: [
                TutorialTip(icon: "10.circle.fill", text: "First to 10 points WINS"),
                TutorialTip(icon: "2.circle.fill", text: "Must win by 2 points gap"),
                TutorialTip(icon: "bolt.fill", text: "9-9 = Need 2 points to win"),
                TutorialTip(icon: "trophy.fill", text: "11-9 = WINNER!"),
            ]
        ),
        TutorialPage(
            icon: "🎯",
            title: "Shot Types",
            description: "Different swings create different shots.",
            color: Color(red: 0.78, green: 0.9, blue: 0.29),
            tips: [
                TutorialTip(icon: "bolt.horizontal.fill", text: "Flat Shot ⚡ — Fast and direct"),
                TutorialTip(icon: "arrow.clockwise", text: "Topspin 🔄 — Heavy bounce"),
                TutorialTip(icon: "scissors", text: "Slice ✂️ — Stays low"),
                TutorialTip(icon: "moon.fill", text: "Lob 🌙 — High arc over AI"),
            ]
        ),
    ]

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.12).ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Text("SKIP")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.35))
                            .tracking(2)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(.white.opacity(0.06)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Page indicator
                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage
                                  ? pages[currentPage].color
                                  : Color.white.opacity(0.15))
                            .frame(width: i == currentPage ? 24 : 6, height: 6)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 32)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        TutorialPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Navigation
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation { currentPage -= 1 }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.white.opacity(0.06))
                            )
                        }
                    }

                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation { currentPage += 1 }
                        } else {
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentPage < pages.count - 1 ? "Next" : "LET'S PLAY!")
                                .font(.system(size: 15, weight: .black))
                                .tracking(currentPage < pages.count - 1 ? 0 : 2)
                            Image(systemName: currentPage < pages.count - 1 ? "chevron.right" : "play.fill")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(pages[currentPage].color)
                        )
                        .shadow(color: pages[currentPage].color.opacity(0.35), radius: 15)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) { animateIn = true }
        }
    }
}

// MARK: - Tutorial Page Model
struct TutorialPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let tips: [TutorialTip]
}

struct TutorialTip {
    let icon: String
    let text: String
}

// MARK: - Tutorial Page View
struct TutorialPageView: View {
    let page: TutorialPage
    @State private var animate = false

    var body: some View {
        VStack(spacing: 0) {
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Text(page.icon)
                    .font(.system(size: 64))
                    .scaleEffect(animate ? 1.0 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animate)
            }
            .padding(.bottom, 20)

            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .tracking(1)
                .padding(.bottom, 12)
                .opacity(animate ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.1), value: animate)

            // Description
            Text(page.description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 28)
                .opacity(animate ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: animate)

            // Tips
            if !page.tips.isEmpty {
                VStack(spacing: 10) {
                    ForEach(Array(page.tips.enumerated()), id: \.offset) { index, tip in
                        TutorialTipRow(tip: tip, color: page.color)
                            .opacity(animate ? 1 : 0)
                            .offset(x: animate ? 0 : 20)
                            .animation(
                                .easeOut(duration: 0.35).delay(0.3 + Double(index) * 0.08),
                                value: animate
                            )
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()
        }
        .padding(.top, 8)
        .onAppear {
            animate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animate = true
            }
        }
        .onChange(of: page.title) { _ in
            animate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animate = true
            }
        }
    }
}

// MARK: - Tip Row
struct TutorialTipRow: View {
    let tip: TutorialTip
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: tip.icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
            }
            Text(tip.text)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.12), lineWidth: 1))
        )
    }
}
