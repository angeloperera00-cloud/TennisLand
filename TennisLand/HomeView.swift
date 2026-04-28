import SwiftUI

struct HomeView: View {

    // MARK: - Navigation State
    @State private var showCharacterSelect = false
    @State private var showWatchMode = false
    @State private var showSettings = false
    @State private var showTutorial = false
    @State private var showCourtSelect = false
    @State private var showMobileGame = false
    @State private var showWinScreen = false

    // MARK: - Selected player/court
    @State private var selectedPlayer: TennisPlayer = TennisPlayer.all[0]
    @State private var selectedCourt: TennisCourt = TennisCourt.all[0]

    // MARK: - Animation
    @State private var animateLogo = false
    @State private var showTutorialOnFirstLaunch = false

    var body: some View {
        ZStack {

            // ── BACKGROUND ──
            Color(red: 0.05, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

            // Grid pattern
            GeometryReader { geo in
                Path { path in
                    for i in stride(from: 0, to: geo.size.width, by: 32) {
                        path.move(to: CGPoint(x: i, y: 0))
                        path.addLine(to: CGPoint(x: i, y: geo.size.height))
                    }
                    for j in stride(from: 0, to: geo.size.height, by: 32) {
                        path.move(to: CGPoint(x: 0, y: j))
                        path.addLine(to: CGPoint(x: geo.size.width, y: j))
                    }
                }
                .stroke(Color.white.opacity(0.04), lineWidth: 0.5)
            }
            .ignoresSafeArea()

            // Glow effect
            Circle()
                .fill(Color(red: 0.78, green: 0.9, blue: 0.29).opacity(0.06))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(y: -100)

            // ── MAIN CONTENT ──
            VStack(spacing: 0) {

                // Settings button top right
                HStack {
                    Spacer()
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(12)
                            .background(Circle().fill(.white.opacity(0.06)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                // ── LOGO ──
                VStack(spacing: 8) {
                    Text("🎾")
                        .font(.system(size: 72))
                        .scaleEffect(animateLogo ? 1.0 : 0.3)
                        .opacity(animateLogo ? 1.0 : 0.0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.6), value: animateLogo)

                    Text("TENNIS LAND")
                        .font(.system(size: 38, weight: .black))
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 0.78, green: 0.9, blue: 0.29), .white],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .tracking(5)
                        .opacity(animateLogo ? 1.0 : 0.0)
                        .offset(y: animateLogo ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: animateLogo)

                    Text("THE ULTIMATE TENNIS EXPERIENCE")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(3)
                        .opacity(animateLogo ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.5).delay(0.35), value: animateLogo)
                }
                .padding(.bottom, 48)

                // ── SELECTED PLAYER PREVIEW ──
                HStack(spacing: 12) {
                    // Player badge
                    HStack(spacing: 8) {
                        Text(selectedPlayer.emoji)
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(selectedPlayer.name)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(selectedPlayer.color)
                                .tracking(1)
                            Text(selectedPlayer.description)
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.35))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(selectedPlayer.color.opacity(0.1))
                            .overlay(Capsule().stroke(selectedPlayer.color.opacity(0.3), lineWidth: 1))
                    )

                    // Court badge
                    HStack(spacing: 8) {
                        Circle()
                            .fill(selectedCourt.color)
                            .frame(width: 10, height: 10)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(selectedCourt.name)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(selectedCourt.color)
                                .tracking(0.5)
                            Text(selectedCourt.speed)
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.35))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(selectedCourt.color.opacity(0.1))
                            .overlay(Capsule().stroke(selectedCourt.color.opacity(0.3), lineWidth: 1))
                    )
                }
                .opacity(animateLogo ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5).delay(0.45), value: animateLogo)
                .padding(.bottom, 28)

                // ── MAIN BUTTONS ──
                VStack(spacing: 12) {

                    // 1v1 vs AI
                    HomeButton(
                        icon: "📱",
                        title: "1v1 vs AI",
                        subtitle: "Mobile & iPad — touch controls",
                        color: Color(red: 0.31, green: 0.8, blue: 0.77),
                        delay: 0.5
                    ) {
                        showCharacterSelect = true
                    }
                    .opacity(animateLogo ? 1 : 0)
                    .offset(y: animateLogo ? 0 : 30)
                    .animation(.easeOut(duration: 0.45).delay(0.5), value: animateLogo)

                    // Real Play Watch
                    HomeButton(
                        icon: "⌚",
                        title: "Real Play",
                        subtitle: "Apple Watch — swing your arm",
                        color: Color(red: 1.0, green: 0.35, blue: 0.35),
                        delay: 0.6
                    ) {
                        showWatchMode = true
                    }
                    .opacity(animateLogo ? 1 : 0)
                    .offset(y: animateLogo ? 0 : 30)
                    .animation(.easeOut(duration: 0.45).delay(0.6), value: animateLogo)

                    // Multiplayer (coming soon)
                    HomeButton(
                        icon: "👥",
                        title: "Multiplayer",
                        subtitle: "Coming soon — 2 players",
                        color: Color(red: 0.6, green: 0.43, blue: 0.98),
                        delay: 0.7,
                        isDisabled: true
                    ) {}
                    .opacity(animateLogo ? 1 : 0)
                    .offset(y: animateLogo ? 0 : 30)
                    .animation(.easeOut(duration: 0.45).delay(0.7), value: animateLogo)
                }
                .padding(.horizontal, 24)

                Spacer()

                // ── BOTTOM ROW ──
                HStack(spacing: 20) {
                    BottomButton(icon: "questionmark.circle.fill", label: "HOW TO PLAY") {
                        showTutorial = true
                    }
                    BottomButton(icon: "person.fill", label: "PLAYER") {
                        showCharacterSelect = true
                    }
                    BottomButton(icon: "tennisball.fill", label: "COURT") {
                        showCourtSelect = true
                    }
                }
                .opacity(animateLogo ? 1 : 0)
                .animation(.easeOut(duration: 0.45).delay(0.8), value: animateLogo)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation { animateLogo = true }
        }

        // ── NAVIGATION ──
        .fullScreenCover(isPresented: $showCharacterSelect) {
            CharacterSelectView { player in
                selectedPlayer = player
                showCharacterSelect = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showCourtSelect = true
                }
            }
        }

        .fullScreenCover(isPresented: $showCourtSelect) {
            CourtSelectView { court in
                selectedCourt = court
                showCourtSelect = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showMobileGame = true
                }
            }
        }

        .fullScreenCover(isPresented: $showMobileGame) {
            MobileGameView()
        }

        // ✅ FIXED: was WatchGameView() which is Watch-only
        // Now opens TennisGameView which is the iPhone Watch-connected game
        .fullScreenCover(isPresented: $showWatchMode) {
            MobileGameView()
        }

        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }

        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView()
        }
    }
}

// MARK: - Home Button
struct HomeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let delay: Double
    var isDisabled: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: { if !isDisabled { action() } }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(isDisabled ? 0.06 : 0.15))
                        .frame(width: 48, height: 48)
                    Text(icon)
                        .font(.system(size: 24))
                        .opacity(isDisabled ? 0.4 : 1.0)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(isDisabled ? .white.opacity(0.3) : .white)
                            .tracking(0.5)
                        if isDisabled {
                            Text("SOON")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(color.opacity(0.6))
                                .tracking(1)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(color.opacity(0.12)))
                        }
                    }
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(isDisabled ? 0.2 : 0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isDisabled ? .white.opacity(0.1) : color.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(color.opacity(isDisabled ? 0.04 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(color.opacity(isDisabled ? 0.08 : 0.25), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .shadow(color: isDisabled ? .clear : color.opacity(0.15), radius: 16, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isDisabled { isPressed = true } }
                .onEnded   { _ in isPressed = false }
        )
        .animation(.spring(response: 0.25), value: isPressed)
        .disabled(isDisabled)
    }
}

// MARK: - Bottom Button
struct BottomButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.5))
                Text(label)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white.opacity(0.25))
                    .tracking(1.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.07), lineWidth: 1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CourtPatternView: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let h = geo.size.height
                for i in stride(from: 0, to: w, by: 40) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i, y: h))
                }
                for j in stride(from: 0, to: h, by: 40) {
                    path.move(to: CGPoint(x: 0, y: j))
                    path.addLine(to: CGPoint(x: w, y: j))
                }
            }
            .stroke(Color.white, lineWidth: 1)
        }
    }
}

#Preview {
    HomeView()
}
