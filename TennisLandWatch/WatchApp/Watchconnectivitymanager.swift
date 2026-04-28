import Foundation
import WatchConnectivity
import CoreMotion
import WatchKit

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var isConnected = false
    @Published var lastShotType = ""

    var onGameStarted: (() -> Void)?
    var onGameStopped: (() -> Void)?
    var onScoreReceived: ((Int, Int) -> Void)?
    var onSwingFired: ((String) -> Void)?

    private let motionManager = CMMotionManager()
    private var swingCooldown = false

    private override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func sendSwing(shotType: String, intensity: Float, power: Float) {
        let session = WCSession.default

        let shotKey: String
        switch shotType {
        case "Backhand! 💪": shotKey = "backhand"
        case "Smash! 🔥":    shotKey = "smash"
        case "Slice! ✂️":    shotKey = "slice"
        default:              shotKey = "forehand"
        }

        let message: [String: Any] = [
            "t": "swing",
            "i": intensity,
            "s": shotKey
        ]

        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { _ in
                session.transferUserInfo(message)
            }
        } else {
            session.transferUserInfo(message)
        }
    }

    func startMotionDetection() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            self.processAccelerometer(data)
        }
        guard motionManager.isGyroAvailable else { return }
        motionManager.gyroUpdateInterval = 1.0 / 60.0
        motionManager.startGyroUpdates()
    }

    func stopMotionDetection() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }

    private func processAccelerometer(_ data: CMAccelerometerData) {
        guard !swingCooldown else { return }

        let x = data.acceleration.x
        let y = data.acceleration.y
        let z = data.acceleration.z
        let magnitude = sqrt(x*x + y*y + z*z)

        guard magnitude > 2.2 else { return }

        let gyroX = motionManager.gyroData?.rotationRate.x ?? 0
        let gyroZ = motionManager.gyroData?.rotationRate.z ?? 0

        let intensity = Float(min(max((magnitude - 2.2) / 2.8, 0.0), 1.0) * 0.6 + 0.4)
        let power = intensity * 12.0

        let shotType: String
        if y > 1.5 && magnitude > 3.5 {
            shotType = "Smash! 🔥"
        } else if y < -1.2 && abs(x) < 0.8 {
            shotType = "Lob! 🌙"
        } else if gyroZ > 2.0 {
            shotType = "Slice! ✂️"
        } else if x < -1.0 || gyroX < -1.5 {
            shotType = "Backhand! 💪"
        } else {
            shotType = "Forehand! 🎾"
        }

        DispatchQueue.main.async {
            self.lastShotType = shotType
            self.sendSwing(shotType: shotType, intensity: intensity, power: power)
            self.onSwingFired?(shotType)
            WKInterfaceDevice.current().play(.click)
        }

        swingCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.swingCooldown = false
        }
    }

    private func handleReceivedMessage(_ message: [String: Any]) {
        if let action = message["action"] as? String {
            switch action {
            case "startGame":
                startMotionDetection()
                onGameStarted?()
            case "stopGame":
                stopMotionDetection()
                onGameStopped?()
            default:
                break
            }
        }
        if let p = message["playerScore"] as? Int,
           let a = message["aiScore"] as? Int {
            onScoreReceived?(p, a)
        }
        if let p = message["p"] as? Int,
           let a = message["a"] as? Int {
            onScoreReceived?(p, a)
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = (state == .activated)
            if state == .activated {
                self.startMotionDetection()
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async { self.handleReceivedMessage(message) }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        DispatchQueue.main.async { self.handleReceivedMessage(userInfo) }
    }

    func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
        DispatchQueue.main.async { self.handleReceivedMessage(context) }
    }
}
