import Foundation
import WatchConnectivity

struct SwingResult {
    let intensity:   Float
    let shotType:    ShotResult
    let displayName: String
}

enum ShotResult: String {
    case forehand = "Forehand! 🎾"
    case backhand = "Backhand! 💪"
    case smash    = "Smash! 🔥"
    case slice    = "Slice! ✂️"
}

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {

    static let shared = WatchSessionManager()

    @Published var isReachable = false

    // This gets set by MobileGameView
    var onSwingDetected: ((SwingResult) -> Void)?

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // Send score to Watch using short keys
    func sendScoreToWatch(playerScore: Int, aiScore: Int) {
        guard WCSession.default.activationState == .activated else { return }
        let msg: [String: Any] = ["p": playerScore, "a": aiScore]
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(msg, replyHandler: nil, errorHandler: nil)
        }
        try? WCSession.default.updateApplicationContext(msg)
    }

    func startGame() {}
    func stopGame()  {}

    // MARK: - Receive from Watch
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleMsg(message)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any],
                 replyHandler: @escaping ([String: Any]) -> Void) {
        handleMsg(message)
        replyHandler(["ok": true])
    }

    func session(_ session: WCSession, didReceiveApplicationContext ctx: [String: Any]) {
        handleMsg(ctx)
    }

    func session(_ session: WCSession, didReceiveUserInfo info: [String: Any]) {
        handleMsg(info)
    }

    private func handleMsg(_ msg: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            // Watch sends: ["t":"swing","i":intensity,"s":shot]
            guard let t = msg["t"] as? String, t == "swing" else { return }
            let intensity = msg["i"] as? Float ?? 0.8
            let shotStr   = msg["s"] as? String ?? "forehand"
            let shotType: ShotResult
            switch shotStr {
            case "backhand": shotType = .backhand
            case "smash":    shotType = .smash
            case "slice":    shotType = .slice
            default:         shotType = .forehand
            }
            let result = SwingResult(intensity: intensity, shotType: shotType,
                                     displayName: shotType.rawValue)
            self?.onSwingDetected?(result)
        }
    }

    // MARK: - Delegate
    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { self.isReachable = session.isReachable }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async { self.isReachable = false }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.isReachable = session.isReachable }
    }
}
