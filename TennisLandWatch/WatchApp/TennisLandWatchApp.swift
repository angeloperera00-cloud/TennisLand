import SwiftUI
import WatchKit
import WatchConnectivity
import CoreMotion

@main
struct TennisLandWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject var vm = WatchVM()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(vm.connected ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(vm.connected ? "Connected" : "Connecting...")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
                HStack(spacing: 12) {
                    VStack(spacing: 0) {
                        Text("YOU").font(.system(size: 9, weight: .bold)).foregroundColor(.cyan)
                        Text("\(vm.myScore)").font(.system(size: 32, weight: .black)).foregroundColor(.cyan)
                    }
                    Text(":").foregroundColor(.white.opacity(0.3)).font(.system(size: 20))
                    VStack(spacing: 0) {
                        Text("AI").font(.system(size: 9, weight: .bold)).foregroundColor(.red)
                        Text("\(vm.aiScore)").font(.system(size: 32, weight: .black)).foregroundColor(.red)
                    }
                }
                Text(vm.shotText).font(.system(size: 12, weight: .bold)).foregroundColor(.yellow).frame(height: 18)
                Button(action: { vm.swing(intensity: 0.8, shot: "forehand") }) {
                    ZStack {
                        Circle().fill(Color.red).frame(width: 60, height: 60)
                            .scaleEffect(vm.animating ? 0.85 : 1.0)
                        Text("🎾").font(.system(size: 28))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .animation(.spring(response: 0.2), value: vm.animating)
                Text("Swing or tap").font(.system(size: 9)).foregroundColor(.white.opacity(0.3))
            }
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}

class WatchVM: NSObject, ObservableObject, WCSessionDelegate {
    @Published var connected = false
    @Published var myScore   = 0
    @Published var aiScore   = 0
    @Published var shotText  = ""
    @Published var animating = false

    private let motion   = CMMotionManager()
    private var lastSwing = Date.distantPast
    private let cooldown: TimeInterval = 0.7

    func start() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
        startMotion()
    }

    func stop() { motion.stopAccelerometerUpdates() }

    // MARK: - WCSession
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { self.connected = state == .activated }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.connected = session.isReachable }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let p = message["p"] as? Int { self.myScore = p }
            if let a = message["a"] as? Int { self.aiScore = a }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext ctx: [String: Any]) {
        DispatchQueue.main.async {
            if let p = ctx["p"] as? Int { self.myScore = p }
            if let a = ctx["a"] as? Int { self.aiScore = a }
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo info: [String: Any]) {
        DispatchQueue.main.async {
            if let p = info["p"] as? Int { self.myScore = p }
            if let a = info["a"] as? Int { self.aiScore = a }
        }
    }

    // MARK: - Swing
    func swing(intensity: Float, shot: String) {
        withAnimation { animating = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { withAnimation { self.animating = false } }
        WKInterfaceDevice.current().play(.success)
        let names = ["forehand":"Forehand! 🎾","backhand":"Backhand! 💪","smash":"Smash! 🔥","slice":"Slice! ✂️"]
        withAnimation { shotText = names[shot] ?? "Hit! 🎾" }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { withAnimation { self.shotText = "" } }

        let msg: [String: Any] = ["t":"swing","i":intensity,"s":shot]
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(msg, replyHandler: nil) { _ in
                WCSession.default.transferUserInfo(msg)
            }
        } else {
            WCSession.default.transferUserInfo(msg)
        }
    }

    // MARK: - Motion
    private func startMotion() {
        guard motion.isAccelerometerAvailable else { return }
        motion.accelerometerUpdateInterval = 1.0/60.0
        motion.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            let mag = sqrt(x*x + y*y + z*z)
            guard mag > 2.5 else { return }
            guard Date().timeIntervalSince(self.lastSwing) > self.cooldown else { return }
            self.lastSwing = Date()
            let intensity = Float(min(mag/5.0, 1.0))
            let shot = y > 1.5 ? "smash" : x > 0.5 ? "forehand" : x < -0.5 ? "backhand" : "forehand"
            self.swing(intensity: intensity, shot: shot)
        }
    }
}
