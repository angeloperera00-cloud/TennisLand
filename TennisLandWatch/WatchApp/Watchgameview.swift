import SwiftUI
import WatchKit

// ─────────────────────────────────────────────
// Watch target ONLY
// ─────────────────────────────────────────────

struct WatchGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var connectivity = WatchConnectivityManager.shared

    @State private var isSwinging = false
    @State private var lastShot = ""
    @State private var playerScore = 0
    @State private var aiScore = 0
    @State private var powerLevel: Float = 0

    var body: some View {
        ZStack {
            Color(red: 0.03, green: 0.05, blue: 0.04)
                .ignoresSafeArea()

            VStack(spacing: 6) {

                // Connection status
                HStack(spacing: 4) {
                    Circle()
                        .fill(connectivity.isConnected ? Color.green : Color.orange)
                        .frame(width: 6, height: 6)
                    Text(connectivity.isConnected ? "Connected" : "Ready")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 2)

                // Score — synced from iPhone
                HStack(spacing: 10) {
                    VStack(spacing: 1) {
                        Text("YOU")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(red: 0.31, green: 0.8, blue: 0.77))
                        Text("\(playerScore)")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(Color(red: 0.31, green: 0.8, blue: 0.77))
                            .contentTransition(.numericText())
                    }
                    Text(":")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.3))
                    VStack(spacing: 1) {
                        Text("AI")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.42))
                        Text("\(aiScore)")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.42))
                            .contentTransition(.numericText())
                    }
                }

                // Swing ball
                ZStack {
                    Circle()
                        .stroke(Color(red: 1.0, green: 0.42, blue: 0.42).opacity(0.3), lineWidth: 3)
                        .frame(width: 65, height: 65)
                        .scaleEffect(isSwinging ? 1.5 : 1.0)
                        .opacity(isSwinging ? 0 : 1)
                        .animation(.easeOut(duration: 0.4), value: isSwinging)

                    Circle()
                        .fill(LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.42, blue: 0.42),
                                Color(red: 0.7, green: 0.15, blue: 0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 56, height: 56)
                        .scaleEffect(isSwinging ? 0.85 : 1.0)
                        .animation(.spring(response: 0.2), value: isSwinging)

                    Text(isSwinging ? "💥" : "🎾")
                        .font(.system(size: 24))
                }

                // Shot feedback
                Text(lastShot.isEmpty ? "Swing!" : lastShot)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(
                        lastShot.isEmpty
                        ? .white.opacity(0.35)
                        : Color(red: 0.78, green: 0.9, blue: 0.29)
                    )
                    .multilineTextAlignment(.center)

                // Power bar
                if powerLevel > 0 {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.white.opacity(0.1))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.78, green: 0.9, blue: 0.29))
                            .frame(width: CGFloat(powerLevel) * 90, height: 4)
                    }
                    .frame(width: 90)
                    .transition(.opacity)
                }
            }
            .padding()
        }
        .onAppear {
            connectivity.startMotionDetection()

            // ✅ Receive score from iPhone and update Watch display
            connectivity.onScoreReceived = { p, a in
                withAnimation {
                    playerScore = p
                    aiScore = a
                }
            }

            // ✅ Show swing animation when motion fires
            connectivity.onSwingFired = { shotType in
                withAnimation { isSwinging = true }
                lastShot = shotType
                powerLevel = 0.7
                WKInterfaceDevice.current().play(.success)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation { isSwinging = false }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if lastShot == shotType { lastShot = "" }
                    powerLevel = 0
                }
            }
        }
        .onDisappear {
            connectivity.stopMotionDetection()
        }
        .animation(.easeInOut(duration: 0.2), value: playerScore)
        .animation(.easeInOut(duration: 0.2), value: aiScore)
    }
}
