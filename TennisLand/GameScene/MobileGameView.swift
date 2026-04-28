import SwiftUI
import SpriteKit

struct MobileGameView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var watchManager = WatchSessionManager.shared

    @State private var playerScore = 0
    @State private var aiScore     = 0
    @State private var feedback    = ""
    @State private var scene: TennisScene?
    @State private var isPaused    = false
    @State private var showWin     = false
    @State private var playerWon   = false
    @State private var swingPulse  = false

    var body: some View {
        ZStack {
            // Background
            Color(red:0.04,green:0.06,blue:0.04).ignoresSafeArea()

            VStack(spacing:0) {

                // ── TOP BAR ──
                HStack {
                    // Home button
                    Button(action:{ dismiss() }) {
                        HStack(spacing:5) {
                            Image(systemName:"chevron.left")
                            Text("Home")
                        }
                        .font(.system(size:13,weight:.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal,12).padding(.vertical,7)
                        .background(Capsule().fill(.black.opacity(0.5))
                            .overlay(Capsule().stroke(.white.opacity(0.15),lineWidth:1)))
                    }

                    Spacer()

                    // Score display
                    HStack(spacing:4) {
                        VStack(spacing:1) {
                            Text("AI")
                                .font(.system(size:9,weight:.bold))
                                .foregroundColor(Color(red:1,green:0.38,blue:0.38))
                                .tracking(2)
                            Text("\(aiScore)")
                                .font(.system(size:34,weight:.black))
                                .foregroundColor(Color(red:1,green:0.38,blue:0.38))
                                .contentTransition(.numericText())
                                .animation(.spring(response:0.3),value:aiScore)
                        }.frame(width:52)

                        Text("—").font(.system(size:16)).foregroundColor(.white.opacity(0.2))

                        VStack(spacing:1) {
                            Text("YOU")
                                .font(.system(size:9,weight:.bold))
                                .foregroundColor(Color(red:0.31,green:0.8,blue:0.77))
                                .tracking(2)
                            Text("\(playerScore)")
                                .font(.system(size:34,weight:.black))
                                .foregroundColor(Color(red:0.31,green:0.8,blue:0.77))
                                .contentTransition(.numericText())
                                .animation(.spring(response:0.3),value:playerScore)
                        }.frame(width:52)
                    }
                    .padding(.horizontal,14).padding(.vertical,8)
                    .background(RoundedRectangle(cornerRadius:14).fill(.black.opacity(0.65))
                        .overlay(RoundedRectangle(cornerRadius:14).stroke(.white.opacity(0.1),lineWidth:1)))

                    Spacer()

                    // Watch + Pause
                    HStack(spacing:6) {
                        // Watch dot
                        Circle()
                            .fill(watchManager.isReachable
                                  ? Color(red:0.31,green:0.8,blue:0.77) : .white.opacity(0.2))
                            .frame(width:8,height:8)
                            .shadow(color:watchManager.isReachable
                                    ? Color(red:0.31,green:0.8,blue:0.77):.clear, radius:4)

                        // Pause
                        Button(action:{
                            isPaused.toggle()
                            scene?.isPaused = isPaused
                        }) {
                            Image(systemName:isPaused ? "play.fill":"pause.fill")
                                .font(.system(size:13))
                                .foregroundColor(.white)
                                .padding(9)
                                .background(Circle().fill(.black.opacity(0.5))
                                    .overlay(Circle().stroke(.white.opacity(0.15),lineWidth:1)))
                        }
                    }
                }
                .padding(.horizontal,16).padding(.top,12).padding(.bottom,6)

                // Progress bars (race to 10)
                HStack(spacing:6) {
                    GeometryReader { geo in
                        ZStack(alignment:.trailing) {
                            RoundedRectangle(cornerRadius:2).fill(.white.opacity(0.06))
                            RoundedRectangle(cornerRadius:2)
                                .fill(Color(red:1,green:0.38,blue:0.38).opacity(0.8))
                                .frame(width:geo.size.width * min(CGFloat(aiScore)/10,1))
                                .frame(maxWidth:.infinity,alignment:.trailing)
                        }
                    }.frame(height:4)
                    Circle().fill(.white.opacity(0.2)).frame(width:4,height:4)
                    GeometryReader { geo in
                        ZStack(alignment:.leading) {
                            RoundedRectangle(cornerRadius:2).fill(.white.opacity(0.06))
                            RoundedRectangle(cornerRadius:2)
                                .fill(Color(red:0.31,green:0.8,blue:0.77).opacity(0.8))
                                .frame(width:geo.size.width * min(CGFloat(playerScore)/10,1))
                        }
                    }.frame(height:4)
                }
                .padding(.horizontal,20)
                .animation(.easeOut(duration:0.4),value:playerScore)
                .animation(.easeOut(duration:0.4),value:aiScore)
                .padding(.bottom,8)

                Spacer()

                // ── GAME ──
                TennisGameSpriteView(
                    playerScore: $playerScore,
                    aiScore:     $aiScore,
                    feedback:    $feedback,
                    onSceneReady: { s in
                        scene = s

                        // ✅ Match over → show win screen
                        s.onMatchOver = { winner in
                            DispatchQueue.main.async {
                                playerWon = winner=="player"
                                withAnimation { showWin = true }
                            }
                        }

                        // ✅ Score update → update UI + sync Watch
                        s.onScore = { p, a in
                            DispatchQueue.main.async {
                                playerScore = p
                                aiScore = a
                                // Send score to Watch immediately
                                watchManager.sendScoreToWatch(playerScore: p, aiScore: a)
                            }
                        }

                        // ✅ Point scored → haptic
                        s.onPoint = {
                            UIImpactFeedbackGenerator(style:.medium).impactOccurred()
                        }

                        // ✅ Watch swing → player swings in game
                        watchManager.onSwingDetected = { result in
                            DispatchQueue.main.async {
                                s.playerSwing(intensity: result.intensity)
                                UIImpactFeedbackGenerator(style:.heavy).impactOccurred()
                            }
                        }
                    }
                )
                .frame(maxWidth:.infinity)
                .frame(height: UIScreen.main.bounds.height * 0.58)
                .clipShape(RoundedRectangle(cornerRadius:16))
                .padding(.horizontal,6)
                .shadow(color:Color(red:0.19,green:0.54,blue:0.21).opacity(0.4),radius:20)

                Spacer()

                // Feedback
                Group {
                    if !feedback.isEmpty {
                        Text(feedback)
                            .font(.system(size:22,weight:.black))
                            .foregroundStyle(LinearGradient(
                                colors:[Color(red:0.78,green:0.9,blue:0.29),.white],
                                startPoint:.leading,endPoint:.trailing))
                            .shadow(color:Color(red:0.78,green:0.9,blue:0.29).opacity(0.5),radius:8)
                            .transition(.scale.combined(with:.opacity))
                    } else {
                        Text(" ").font(.system(size:22))
                    }
                }
                .frame(height:30)
                .animation(.easeInOut(duration:0.2),value:feedback)

                // Hint
                HStack(spacing:5) {
                    Image(systemName: watchManager.isReachable
                          ? "applewatch.radiowaves.left.and.right" : "hand.draw.fill")
                        .font(.system(size:11))
                        .foregroundColor(watchManager.isReachable
                                         ? Color(red:0.31,green:0.8,blue:0.77) : .white.opacity(0.25))
                    Text(watchManager.isReachable
                         ? "Swing Watch to hit!"
                         : "DRAG to move  •  SWING to hit")
                        .font(.system(size:10,weight:.semibold))
                        .foregroundColor(.white.opacity(0.28))
                        .tracking(0.5)
                }
                .padding(.top,4)

                // ── SWING BUTTON ──
                Button(action:{
                    withAnimation(.spring(response:0.12)) { swingPulse=true }
                    DispatchQueue.main.asyncAfter(deadline:.now()+0.15) {
                        withAnimation { swingPulse=false }
                    }
                    UIImpactFeedbackGenerator(style:.heavy).impactOccurred()
                    scene?.playerSwing(intensity:0.85)
                }) {
                    HStack(spacing:12) {
                        Text("🎾")
                            .font(.system(size:24))
                            .rotationEffect(.degrees(swingPulse ? 40:0))
                            .animation(.spring(response:0.15),value:swingPulse)
                        Text("SWING")
                            .font(.system(size:18,weight:.black))
                            .tracking(3)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth:.infinity)
                    .padding(.vertical,18)
                    .background(RoundedRectangle(cornerRadius:18)
                        .fill(Color(red:0.78,green:0.9,blue:0.29))
                        .shadow(color:Color(red:0.78,green:0.9,blue:0.29).opacity(0.5),radius:20,y:6))
                    .scaleEffect(swingPulse ? 0.91:1.0)
                    .animation(.spring(response:0.15),value:swingPulse)
                }
                .padding(.horizontal,24)
                .padding(.top,8).padding(.bottom,36)
            }

            // ── PAUSE ──
            if isPaused {
                GamePauseOverlay(
                    onResume:{ isPaused=false; scene?.isPaused=false },
                    onQuit:{ dismiss() }
                )
            }

            // ── WIN ──
            if showWin {
                WinScreen(
                    playerScore: playerScore,
                    aiScore:     aiScore,
                    isPlayerWin: playerWon,
                    courtColor:  Color(red:0.31,green:0.8,blue:0.77),
                    onPlayAgain: {
                        withAnimation { showWin=false }
                        playerScore=0; aiScore=0
                        scene?.playerScore=0; scene?.aiScore=0
                        scene?.rally=0; scene?.state = .waiting
                        watchManager.sendScoreToWatch(playerScore:0, aiScore:0)
                        DispatchQueue.main.asyncAfter(deadline:.now()+0.4) {
                            scene?.serve(playerServes:true)
                        }
                    },
                    onHome:{ dismiss() }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration:0.3),value:showWin)
        .onAppear {
            watchManager.startGame()
            // ✅ Connect Watch swing to game
            // Must be set here so scene is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                watchManager.onSwingDetected = { result in
                    DispatchQueue.main.async {
                        scene?.playerSwing(intensity: result.intensity)
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        print("📱 Watch swing applied to game!")
                    }
                }
                print("📱 Watch swing handler registered")
            }
        }
        .onDisappear {
            watchManager.stopGame()
            watchManager.onSwingDetected = nil
        }
    }
}

// MARK: - Pause Overlay
struct GamePauseOverlay: View {
    let onResume: () -> Void
    let onQuit:   () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()
            VStack(spacing:28) {
                Text("⏸").font(.system(size:60))
                Text("PAUSED")
                    .font(.system(size:32,weight:.black))
                    .foregroundColor(.white).tracking(5)
                VStack(spacing:14) {
                    Button(action:onResume) {
                        Text("RESUME")
                            .font(.system(size:16,weight:.black)).tracking(2)
                            .foregroundColor(.black).frame(width:220).padding(.vertical,16)
                            .background(RoundedRectangle(cornerRadius:16)
                                .fill(Color(red:0.78,green:0.9,blue:0.29))
                                .shadow(color:Color(red:0.78,green:0.9,blue:0.29).opacity(0.4),radius:16))
                    }
                    Button(action:onQuit) {
                        Text("QUIT TO HOME")
                            .font(.system(size:14,weight:.bold)).tracking(1)
                            .foregroundColor(.white.opacity(0.5)).frame(width:220).padding(.vertical,14)
                            .background(RoundedRectangle(cornerRadius:16)
                                .fill(.white.opacity(0.06))
                                .overlay(RoundedRectangle(cornerRadius:16)
                                    .stroke(.white.opacity(0.12),lineWidth:1)))
                    }
                }
            }
        }
    }
}
