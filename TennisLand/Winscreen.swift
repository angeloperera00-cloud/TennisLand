import SwiftUI

// MARK: - Score Manager
class TennisScoreManager: ObservableObject {
    @Published var playerPoints: Int = 0
    @Published var aiPoints: Int = 0
    @Published var isMatchOver: Bool = false
    @Published var winner: Winner = .none
    @Published var statusMessage: String = ""

    let pointsToWin = 10
    let advantage = 2

    enum Winner {
        case none, player, ai
    }

    var onMatchOver: ((Winner) -> Void)?
    var onPointScored: ((Winner) -> Void)?

    func scorePoint(for winner: Winner) {
        guard !isMatchOver else { return }
        switch winner {
        case .player: playerPoints += 1
        case .ai:     aiPoints += 1
        case .none:   break
        }
        onPointScored?(winner)
        updateStatus()
        checkWinner()
    }

    private func updateStatus() {
        let bothOver = playerPoints >= pointsToWin && aiPoints >= pointsToWin
        let diff = abs(playerPoints - aiPoints)

        if bothOver {
            if playerPoints > aiPoints { statusMessage = "MATCH POINT! 🎾" }
            else if aiPoints > playerPoints { statusMessage = "AI MATCH POINT! 😤" }
            else { statusMessage = "TIED — NEED 2! ⚡" }
        } else if playerPoints == pointsToWin - 1 {
            statusMessage = "MATCH POINT! 🎾"
        } else if aiPoints == pointsToWin - 1 {
            statusMessage = "AI MATCH POINT! 😤"
        } else {
            statusMessage = ""
        }
    }

    private func checkWinner() {
        let diff = abs(playerPoints - aiPoints)
        if playerPoints >= pointsToWin && diff >= advantage {
            isMatchOver = true; winner = .player
            onMatchOver?(.player)
        } else if aiPoints >= pointsToWin && diff >= advantage {
            isMatchOver = true; winner = .ai
            onMatchOver?(.ai)
        }
    }

    func reset() {
        playerPoints = 0; aiPoints = 0
        isMatchOver = false; winner = .none; statusMessage = ""
    }

    var playerProgress: Double { min(Double(playerPoints) / Double(pointsToWin), 1.0) }
    var aiProgress: Double    { min(Double(aiPoints)    / Double(pointsToWin), 1.0) }
}

// MARK: - Win Screen
struct WinScreen: View {
    let playerScore: Int
    let aiScore: Int
    let isPlayerWin: Bool
    let courtColor: Color
    var onPlayAgain: () -> Void
    var onHome: () -> Void

    @State private var animate = false
    @State private var showConfetti = false
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        ZStack {
            // Dark bg
            Color(red: 0.05, green: 0.07, blue: 0.12).ignoresSafeArea()

            // Confetti
            if showConfetti && isPlayerWin {
                ForEach(confettiPieces) { piece in
                    ConfettiView(piece: piece)
                }
            }

            VStack(spacing: 0) {
                Spacer()

                // Trophy / Loss icon
                ZStack {
                    Circle()
                        .fill(isPlayerWin
                              ? Color(red: 0.78, green: 0.9, blue: 0.29).opacity(0.12)
                              : Color.red.opacity(0.08))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)

                    Text(isPlayerWin ? "🏆" : "😤")
                        .font(.system(size: 72))
                        .scaleEffect(animate ? 1.0 : 0.3)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: animate)
                }
                .padding(.bottom, 20)

                // Title
                Text(isPlayerWin ? "YOU WIN!" : "AI WINS!")
                    .font(.system(size: 42, weight: .black))
                    .foregroundColor(isPlayerWin
                                     ? Color(red: 0.78, green: 0.9, blue: 0.29)
                                     : Color(red: 1.0, green: 0.35, blue: 0.35))
                    .tracking(4)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.3), value: animate)

                Text(isPlayerWin ? "MATCH COMPLETE" : "BETTER LUCK NEXT TIME")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(3)
                    .padding(.bottom, 32)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.4), value: animate)

                // Score box
                HStack(spacing: 0) {
                    // Player score
                    VStack(spacing: 6) {
                        Text("YOU")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(2)
                        Text("\(playerScore)")
                            .font(.system(size: 52, weight: .black))
                            .foregroundColor(isPlayerWin
                                             ? Color(red: 0.78, green: 0.9, blue: 0.29)
                                             : .white)
                    }
                    .frame(maxWidth: .infinity)

                    // Divider
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1, height: 60)

                    // AI score
                    VStack(spacing: 6) {
                        Text("AI")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(2)
                        Text("\(aiScore)")
                            .font(.system(size: 52, weight: .black))
                            .foregroundColor(!isPlayerWin
                                             ? Color(red: 1.0, green: 0.35, blue: 0.35)
                                             : .white)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.04))
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.08), lineWidth: 1))
                )
                .padding(.horizontal, 32)
                .opacity(animate ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.5), value: animate)
                .padding(.bottom, 20)

                // Stats row
                HStack(spacing: 12) {
                    WinStatBox(label: "WINNER", value: isPlayerWin ? "YOU" : "AI",
                               color: isPlayerWin ? Color(red: 0.78, green: 0.9, blue: 0.29) : Color(red: 1.0, green: 0.35, blue: 0.35))
                    WinStatBox(label: "TOTAL POINTS", value: "\(playerScore + aiScore)",
                               color: courtColor)
                    WinStatBox(label: "MARGIN", value: "+\(abs(playerScore - aiScore))",
                               color: .white.opacity(0.6))
                }
                .padding(.horizontal, 32)
                .opacity(animate ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.6), value: animate)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: onPlayAgain) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .bold))
                            Text("PLAY AGAIN")
                                .font(.system(size: 16, weight: .black))
                                .tracking(2)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isPlayerWin
                                      ? Color(red: 0.78, green: 0.9, blue: 0.29)
                                      : Color(red: 1.0, green: 0.35, blue: 0.35))
                        )
                        .shadow(color: (isPlayerWin
                                        ? Color(red: 0.78, green: 0.9, blue: 0.29)
                                        : Color(red: 1.0, green: 0.35, blue: 0.35)).opacity(0.4),
                                radius: 20)
                    }

                    Button(action: onHome) {
                        HStack(spacing: 10) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 14))
                            Text("HOME")
                                .font(.system(size: 15, weight: .bold))
                                .tracking(2)
                        }
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.06))
                                .overlay(RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.1), lineWidth: 1))
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 30)
                .animation(.easeOut(duration: 0.4).delay(0.7), value: animate)
            }
        }
        .onAppear {
            animate = true
            if isPlayerWin {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    confettiPieces = (0..<40).map { _ in ConfettiPiece() }
                    showConfetti = true
                }
            }
        }
    }
}

// MARK: - Win Stat Box
struct WinStatBox: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white.opacity(0.3))
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(0.07), lineWidth: 1))
        )
    }
}

// MARK: - Confetti
struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat = CGFloat.random(in: 0...1)
    let delay: Double = Double.random(in: 0...2)
    let duration: Double = Double.random(in: 2...4)
    let color: Color = [
        Color(red: 0.78, green: 0.9, blue: 0.29),
        Color(red: 0.31, green: 0.8, blue: 0.77),
        Color(red: 1.0, green: 0.35, blue: 0.35),
        Color(red: 0.6, green: 0.43, blue: 0.98),
        Color.white
    ].randomElement()!
    let size: CGFloat = CGFloat.random(in: 6...12)
    let rotation: Double = Double.random(in: 0...360)
}

struct ConfettiView: View {
    let piece: ConfettiPiece
    @State private var fall = false

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(piece.color)
                .frame(width: piece.size, height: piece.size * 0.5)
                .rotationEffect(.degrees(piece.rotation))
                .position(
                    x: geo.size.width * piece.x,
                    y: fall ? geo.size.height + 20 : -20
                )
                .animation(
                    .linear(duration: piece.duration)
                    .delay(piece.delay)
                    .repeatForever(autoreverses: false),
                    value: fall
                )
        }
        .ignoresSafeArea()
        .onAppear { fall = true }
    }
}

// MARK: - Score HUD View (used in game)
struct ScoreHUDView: View {
    @ObservedObject var scoreManager: TennisScoreManager

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                // AI side
                VStack(spacing: 2) {
                    Text("AI")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(2)
                    Text("\(scoreManager.aiPoints)")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(red: 1.0, green: 0.35, blue: 0.35))
                }
                .frame(width: 60)

                Text("—")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.horizontal, 8)

                // Player side
                VStack(spacing: 2) {
                    Text("YOU")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(2)
                    Text("\(scoreManager.playerPoints)")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(red: 0.31, green: 0.8, blue: 0.77))
                }
                .frame(width: 60)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.black.opacity(0.55))
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1))
            )

            // Progress bars
            HStack(spacing: 4) {
                // AI bar (left)
                GeometryReader { geo in
                    ZStack(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.06))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.8))
                            .frame(width: geo.size.width * scoreManager.aiProgress)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .frame(height: 3)

                // Player bar (right)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.06))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.31, green: 0.8, blue: 0.77).opacity(0.8))
                            .frame(width: geo.size.width * scoreManager.playerProgress)
                    }
                }
                .frame(height: 3)
            }
            .frame(width: 160)

            // Status message
            if !scoreManager.statusMessage.isEmpty {
                Text(scoreManager.statusMessage)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.78, green: 0.9, blue: 0.29))
                    .tracking(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.78, green: 0.9, blue: 0.29).opacity(0.12))
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: scoreManager.statusMessage)
    }
}
