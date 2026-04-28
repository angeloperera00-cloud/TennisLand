import SpriteKit
import SwiftUI

// MARK: - Tennis Scene (SpriteKit)
class TennisScene: SKScene {

    // MARK: - Dimensions
    var courtW:  CGFloat = 300
    var courtH:  CGFloat = 460
    var playerY: CGFloat = 175
    var aiY:     CGFloat = -175
    var halfW:   CGFloat = 115

    // MARK: - Nodes
    var ballNode:    SKShapeNode!
    var ballShadow:  SKShapeNode!
    var playerNode:  SKSpriteNode!
    var aiNode:      SKSpriteNode!
    var trailNodes:  [SKShapeNode] = []
    var flashNode:   SKShapeNode!
    var statusLabel: SKLabelNode!
    var shotLabel:   SKLabelNode!

    // MARK: - Ball
    var bx:  CGFloat = 0
    var by:  CGFloat = 150
    var bvx: CGFloat = 0
    var bvy: CGFloat = 0
    var bH:  CGFloat = 0
    var bHv: CGFloat = 0

    // MARK: - Players
    var px:       CGFloat = 0
    var pTargetX: CGFloat = 0
    var ax:       CGFloat = 0

    // MARK: - State
    enum State { case waiting, playing, scored, gameOver }
    var state:      State  = .waiting
    var playerScore: Int   = 0
    var aiScore:     Int   = 0
    var rally:       Int   = 0
    var aiCooldown:  Double = 0
    var lastTime:    Double = 0

    // MARK: - Callbacks
    var onScore:     ((Int, Int) -> Void)?
    var onFeedback:  ((String)   -> Void)?
    var onMatchOver: ((String)   -> Void)?
    var onPoint:     (()         -> Void)?

    // MARK: - didMove
    override func didMove(to view: SKView) {
        let W = size.width, H = size.height
        courtW  = W * 0.92
        courtH  = H * 0.92
        playerY = H * 0.34
        aiY     = -H * 0.34
        halfW   = courtW * 0.44
        by      = playerY - 25

        backgroundColor = UIColor(red: 0.10, green: 0.30, blue: 0.11, alpha: 1)
        buildAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.serve(playerServes: true)
        }
    }

    private func buildAll() {
        buildCourt()
        buildNet()
        buildShadow()
        buildBall()
        buildPlayers()
        buildTrail()
        buildLabels()
        buildFlash()
    }

    // MARK: - Court
    private func buildCourt() {
        let outer = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        outer.fillColor = UIColor(red:0.10,green:0.30,blue:0.11,alpha:1)
        outer.strokeColor = .clear; outer.zPosition = 0; addChild(outer)

        let court = SKShapeNode(rectOf: CGSize(width:courtW,height:courtH), cornerRadius:6)
        court.fillColor = UIColor(red:0.20,green:0.56,blue:0.22,alpha:1)
        court.strokeColor = .clear; court.zPosition = 1; addChild(court)

        let c = UIColor.white.withAlphaComponent(0.88)
        hLine(y: courtH/2,  c:c, w:2.5); hLine(y:-courtH/2, c:c, w:2.5)
        vLine(x:-courtW/2,  c:c, w:2.5); vLine(x: courtW/2, c:c, w:2.5)
        let sw = courtW*0.36
        vLine(x:-sw, c:c, w:1.8); vLine(x:sw, c:c, w:1.8)
        hLine(y: courtH*0.19, c:c, w:1.8, x1:-sw, x2:sw)
        hLine(y:-courtH*0.19, c:c, w:1.8, x1:-sw, x2:sw)
        vLine(x:0, c:c, w:1.8, y1:-courtH*0.19, y2:courtH*0.19)
    }

    private func hLine(y:CGFloat, c:UIColor, w:CGFloat, x1:CGFloat?=nil, x2:CGFloat?=nil) {
        let p = CGMutablePath()
        p.move(to:CGPoint(x:x1 ?? -courtW/2, y:y))
        p.addLine(to:CGPoint(x:x2 ?? courtW/2, y:y))
        let n = SKShapeNode(path:p); n.strokeColor=c; n.lineWidth=w; n.zPosition=2; addChild(n)
    }

    private func vLine(x:CGFloat, c:UIColor, w:CGFloat, y1:CGFloat?=nil, y2:CGFloat?=nil) {
        let p = CGMutablePath()
        p.move(to:CGPoint(x:x, y:y1 ?? -courtH/2))
        p.addLine(to:CGPoint(x:x, y:y2 ?? courtH/2))
        let n = SKShapeNode(path:p); n.strokeColor=c; n.lineWidth=w; n.zPosition=2; addChild(n)
    }

    // MARK: - Net
    private func buildNet() {
        let net = SKShapeNode(rectOf:CGSize(width:courtW+6,height:14), cornerRadius:2)
        net.fillColor = UIColor(white:0.28,alpha:0.85)
        net.strokeColor = .clear; net.zPosition = 10; addChild(net)

        let top = SKShapeNode(rectOf:CGSize(width:courtW+6,height:3.5))
        top.fillColor = UIColor.white.withAlphaComponent(0.92)
        top.strokeColor = .clear
        top.position = CGPoint(x:0,y:5); top.zPosition = 11; addChild(top)

        var xi = -courtW/2
        while xi <= courtW/2 {
            let p = CGMutablePath()
            p.move(to:CGPoint(x:xi,y:-6)); p.addLine(to:CGPoint(x:xi,y:6))
            let l = SKShapeNode(path:p)
            l.strokeColor = UIColor.white.withAlphaComponent(0.22)
            l.lineWidth = 1; l.zPosition = 11; addChild(l)
            xi += 12
        }

        for x:CGFloat in [-courtW/2-5, courtW/2+5] {
            let post = SKShapeNode(rectOf:CGSize(width:7,height:20),cornerRadius:3)
            post.fillColor = UIColor(white:0.82,alpha:1)
            post.strokeColor = .clear
            post.position = CGPoint(x:x,y:0); post.zPosition = 12; addChild(post)
        }
    }

    // MARK: - Shadow
    private func buildShadow() {
        ballShadow = SKShapeNode(ellipseOf:CGSize(width:22,height:9))
        ballShadow.fillColor = UIColor.black.withAlphaComponent(0.28)
        ballShadow.strokeColor = .clear; ballShadow.zPosition = 3; addChild(ballShadow)
    }

    // MARK: - Ball
    private func buildBall() {
        ballNode = SKShapeNode(circleOfRadius:10)
        ballNode.fillColor = UIColor(red:0.86,green:0.97,blue:0.22,alpha:1)
        ballNode.strokeColor = UIColor(red:0.62,green:0.78,blue:0.0,alpha:0.7)
        ballNode.lineWidth = 1.5; ballNode.zPosition = 20; ballNode.glowWidth = 4
        addChild(ballNode)
    }

    // MARK: - Trail
    private func buildTrail() {
        for i in 0..<5 {
            let t = SKShapeNode(circleOfRadius: max(1, CGFloat(9-i*2)))
            t.fillColor = UIColor(red:0.86,green:0.97,blue:0.22,alpha:CGFloat(0.25-Double(i)*0.04))
            t.strokeColor = .clear; t.zPosition = CGFloat(19-i)
            t.isHidden = true; addChild(t); trailNodes.append(t)
        }
    }

    // MARK: - Labels
    private func buildLabels() {
        statusLabel = SKLabelNode(fontNamed:"AvenirNext-Heavy")
        statusLabel.fontSize = 13
        statusLabel.fontColor = UIColor(red:0.78,green:0.9,blue:0.29,alpha:1)
        statusLabel.position = CGPoint(x:0, y:courtH/2+18)
        statusLabel.zPosition = 30; statusLabel.text = ""; addChild(statusLabel)

        shotLabel = SKLabelNode(fontNamed:"AvenirNext-Heavy")
        shotLabel.fontSize = 20
        shotLabel.fontColor = UIColor(red:0.78,green:0.9,blue:0.29,alpha:1)
        shotLabel.position = CGPoint(x:0, y:30)
        shotLabel.zPosition = 30; shotLabel.text = ""; addChild(shotLabel)
    }

    // MARK: - Flash
    private func buildFlash() {
        flashNode = SKShapeNode(rectOf:CGSize(width:size.width,height:size.height))
        flashNode.fillColor = .clear; flashNode.strokeColor = .clear
        flashNode.zPosition = 50; addChild(flashNode)
    }

    // MARK: - Players
    private func buildPlayers() {
        playerNode = makePlayer(isPlayer:true)
        playerNode.position = CGPoint(x:px,y:playerY)
        playerNode.zPosition = 15; addChild(playerNode)

        aiNode = makePlayer(isPlayer:false)
        aiNode.position = CGPoint(x:ax,y:aiY)
        aiNode.zPosition = 15; addChild(aiNode)
    }

    private func makePlayer(isPlayer:Bool) -> SKSpriteNode {
        let jersey:UIColor = isPlayer
            ? UIColor(red:0.22,green:0.60,blue:0.95,alpha:1)
            : UIColor(red:0.95,green:0.26,blue:0.26,alpha:1)
        let skin = UIColor(red:0.95,green:0.78,blue:0.62,alpha:1)
        let hair = UIColor(red:0.14,green:0.08,blue:0.02,alpha:1)
        let sz = CGSize(width:52,height:80)
        let img = UIGraphicsImageRenderer(size:sz).image { ctx in
            let c = ctx.cgContext
            c.setFillColor(UIColor.black.withAlphaComponent(0.18).cgColor)
            c.fillEllipse(in:CGRect(x:6,y:68,width:40,height:10))
            c.setFillColor(UIColor.white.cgColor)
            c.fillEllipse(in:CGRect(x:4,y:62,width:18,height:10))
            c.fillEllipse(in:CGRect(x:30,y:62,width:18,height:10))
            c.setFillColor(UIColor(white:0.92,alpha:1).cgColor)
            c.fill(CGRect(x:8,y:44,width:16,height:22))
            c.fill(CGRect(x:28,y:44,width:16,height:22))
            c.setFillColor(jersey.cgColor)
            c.fill(CGRect(x:8,y:22,width:36,height:26))
            c.fill(CGRect(x:2,y:24,width:10,height:18))
            c.fill(CGRect(x:40,y:24,width:10,height:18))
            let rx:CGFloat = isPlayer ? 44 : 0
            c.setStrokeColor(UIColor(white:0.2,alpha:1).cgColor)
            c.setLineWidth(2.5)
            c.strokeEllipse(in:CGRect(x:rx,y:10,width:16,height:20))
            c.setLineWidth(1)
            c.setStrokeColor(UIColor.white.withAlphaComponent(0.5).cgColor)
            for i in 0..<3 {
                let lx = rx+3+CGFloat(i)*4
                c.move(to:CGPoint(x:lx,y:12)); c.addLine(to:CGPoint(x:lx,y:28)); c.strokePath()
            }
            c.setFillColor(skin.cgColor)
            c.fillEllipse(in:CGRect(x:15,y:4,width:22,height:22))
            c.setFillColor(hair.cgColor)
            c.fillEllipse(in:CGRect(x:14,y:3,width:24,height:13))
        }
        let node = SKSpriteNode(texture:SKTexture(image:img), size:sz)
        if !isPlayer { node.yScale = -1 }
        return node
    }

    // MARK: - Serve
    func serve(playerServes:Bool) {
        guard state != .gameOver else { return }
        state = .playing; rally = 0
        bx = CGFloat.random(in:-40...40)
        by = playerServes ? playerY-22 : aiY+22
        bH = 0; bHv = 0
        let targetY:CGFloat = playerServes ? aiY+22 : playerY-22
        let spd:CGFloat = 300
        bvx = CGFloat.random(in:-30...30)
        bvy = targetY > by ? spd : -spd
        bHv = 110
        ballNode.position = CGPoint(x:bx, y:by+bH)
        updateStatus()
    }

    // MARK: - Update
    override func update(_ currentTime:TimeInterval) {
        let dt:CGFloat = lastTime==0 ? 1/60 : min(CGFloat(currentTime-lastTime),0.05)
        lastTime = currentTime
        aiCooldown -= Double(dt)
        guard state == .playing else { return }
        stepBall(dt); stepPlayer(dt); stepAI(dt)
        updateVisuals(); checkScore()
    }

    // MARK: - Ball
    private func stepBall(_ dt:CGFloat) {
        bx += bvx*dt; by += bvy*dt
        bHv -= 260*dt; bH += bHv*dt
        if bH < 0 {
            bH = 0; bHv = abs(bHv)*0.62
            bvx *= 0.90; bvy *= 0.90
        }
        if bx >  halfW { bx =  halfW; bvx = -abs(bvx)*0.65 }
        if bx < -halfW { bx = -halfW; bvx =  abs(bvx)*0.65 }
    }

    // MARK: - Player
    private func stepPlayer(_ dt:CGFloat) {
        px += (pTargetX-px) * min(dt*18, 1.0)
        px = max(-halfW, min(halfW, px))
        playerNode.position = CGPoint(x:px, y:playerY)
    }

    // MARK: - AI
    private func stepAI(_ dt:CGFloat) {
        if by < 0 { ax += (bx-ax)*dt*3.5 }
        else       { ax += (0-ax)*dt*1.5  }
        ax = max(-halfW, min(halfW, ax))
        aiNode.position = CGPoint(x:ax, y:aiY)

        if abs(by-aiY)<40 && by<0 && bvy<0 && aiCooldown<=0 { doAISwing() }
    }

    private func doAISwing() {
        aiCooldown = 0.7; rally += 1
        let err = max(0.05, 0.22 - Double(min(rally,10))*0.015)
        if Double.random(in:0...1) < err { return }
        let tX = CGFloat.random(in:-halfW+20...halfW-20)
        bvx = (tX-ax)*1.1
        bvy = 280 + CGFloat.random(in:0...80)
        bHv = 90 + CGFloat.random(in:0...45); bH = 0
        aiNode.run(SKAction.sequence([
            .moveBy(x:0,y:-14,duration:0.06),
            .moveBy(x:0,y: 14,duration:0.10)
        ]))
    }

    // MARK: - Player Swing
    func playerSwing(intensity:Float=0.85) {
        guard state == .playing else { return }

        let distX = abs(bx-px), distY = abs(by-playerY)
        let canHit = (distX<70 && distY<60 && by>60) || distY<32

        playerNode.run(SKAction.sequence([
            .moveBy(x:0,y: 14,duration:0.06),
            .moveBy(x:0,y:-14,duration:0.10)
        ]))

        if canHit {
            rally += 1
            let spd = CGFloat(270 + intensity*80)
            let tX  = CGFloat.random(in:-halfW+20...halfW-20)
            bvx = (tX-px)*0.95; bvy = -spd
            bHv = 85 + CGFloat.random(in:0...55); bH = 2
            let msgs = ["Great shot! 🎾","Winner! ⚡","Topspin! 🔄","Ace! 🔥","Nice! 💪"]
            let msg = msgs.randomElement()!
            showShot(msg); onFeedback?(msg)
        } else {
            showShot("Missed! 😅"); onFeedback?("Missed! 😅")
        }
    }

    func movePlayer(toX x:CGFloat) { pTargetX = max(-halfW, min(halfW, x)) }

    // MARK: - Shot label
    private func showShot(_ text:String) {
        shotLabel.text = text; shotLabel.alpha = 1
        shotLabel.removeAllActions()
        shotLabel.run(SKAction.sequence([
            .wait(forDuration:1.0),
            .fadeOut(withDuration:0.3)
        ]))
    }

    // MARK: - Status label
    private func updateStatus() {
        let diff = abs(playerScore-aiScore)
        if (playerScore>=10 || aiScore>=10) && diff<2 {
            statusLabel.text = playerScore>aiScore ? "MATCH POINT! 🎾" :
                               aiScore>playerScore ? "AI MATCH POINT! 😤" : "NEED 2 TO WIN! ⚡"
        } else if playerScore==9 && aiScore<9 { statusLabel.text = "MATCH POINT! 🎾" }
        else if aiScore==9 && playerScore<9   { statusLabel.text = "AI MATCH POINT! 😤" }
        else                                   { statusLabel.text = "" }
    }

    // MARK: - Visuals
    private func updateVisuals() {
        ballNode.position = CGPoint(x:bx, y:by+bH)
        let ss = max(0.25, 1.0-bH/130)
        ballShadow.position = CGPoint(x:bx, y:by)
        ballShadow.setScale(ss)
        ballShadow.alpha = max(0.06, 0.32-bH/220)
        for (i,t) in trailNodes.enumerated() {
            t.isHidden = bH<4
            let f = CGFloat(i+1)*0.013
            t.position = CGPoint(x:bx-bvx*f, y:(by+bH)-bvy*f)
        }
        ballNode.setScale(max(0.7, min(1.35, 1.0+bH/350)))
    }

    // MARK: - Score check
    private func checkScore() {
        guard state == .playing else { return }
        var winner:String? = nil
        if by >  courtH/2+25 { winner = "ai"     }
        if by < -courtH/2-25 { winner = "player"  }
        guard let w = winner else { return }
        state = .scored

        if w=="player" { playerScore+=1 } else { aiScore+=1 }

        // Flash
        flashNode.fillColor = w=="player"
            ? UIColor(red:0.31,green:0.8,blue:0.77,alpha:0.28)
            : UIColor(red:1.0,green:0.35,blue:0.35,alpha:0.28)
        flashNode.run(SKAction.sequence([.fadeOut(withDuration:0.35),
                                         .run { self.flashNode.alpha=1; self.flashNode.fillColor = .clear }]))

        onScore?(playerScore, aiScore)
        onPoint?()
        updateStatus()

        // Win check
        let diff = abs(playerScore-aiScore)
        if (playerScore>=10 || aiScore>=10) && diff>=2 {
            state = .gameOver
            showShot(playerScore>aiScore ? "YOU WIN! 🏆" : "AI WINS! 😤")
            DispatchQueue.main.asyncAfter(deadline:.now()+1.5) { [weak self] in
                guard let self = self else { return }
                self.onMatchOver?(self.playerScore > self.aiScore ? "player" : "ai")
            }
            return
        }

        // Next point
        DispatchQueue.main.asyncAfter(deadline:.now()+1.4) { [weak self] in
            guard let s=self else { return }
            s.bx=0; s.by=s.playerY-22; s.bH=0; s.bHv=0
            s.ballNode.position = CGPoint(x:s.bx, y:s.by)
            s.serve(playerServes: w=="ai")
        }
    }
}

// MARK: - SwiftUI Wrapper
struct TennisGameSpriteView: UIViewRepresentable {
    @Binding var playerScore: Int
    @Binding var aiScore:     Int
    @Binding var feedback:    String
    var onSceneReady: (TennisScene) -> Void

    func makeUIView(context:Context) -> SKView {
        let v = SKView()
        v.backgroundColor = UIColor(red:0.10,green:0.30,blue:0.11,alpha:1)
        v.ignoresSiblingOrder = true
        context.coordinator.setup(view:v, bindings:(playerScore:_playerScore,
                                                    aiScore:_aiScore,
                                                    feedback:_feedback),
                                   onReady:onSceneReady)
        let pan = UIPanGestureRecognizer(target:context.coordinator,
                                         action:#selector(Coordinator.onPan(_:)))
        v.addGestureRecognizer(pan)
        return v
    }

    func updateUIView(_ uiView:SKView, context:Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject {
        weak var skView:  SKView?
        weak var scene:   TennisScene?
        var playerScore:  Binding<Int>?
        var aiScore:      Binding<Int>?
        var feedback:     Binding<String>?
        var onReady:      ((TennisScene)->Void)?
        var startTouchX:  CGFloat = 0
        var startPlayerX: CGFloat = 0

        func setup(view:SKView,
                   bindings:(playerScore:Binding<Int>, aiScore:Binding<Int>, feedback:Binding<String>),
                   onReady:@escaping (TennisScene)->Void) {
            skView = view
            playerScore = bindings.playerScore
            aiScore     = bindings.aiScore
            feedback    = bindings.feedback
            self.onReady = onReady
            DispatchQueue.main.asyncAfter(deadline:.now()+0.05) { self.present() }
        }

        func present() {
            guard let v=skView, v.bounds.width>0, v.bounds.height>0 else {
                DispatchQueue.main.asyncAfter(deadline:.now()+0.1) { self.present() }
                return
            }
            let s = TennisScene(size: v.bounds.size)
            s.scaleMode = .resizeFill
            s.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            s.onScore = { [weak self] p,a in DispatchQueue.main.async {
                self?.playerScore?.wrappedValue = p
                self?.aiScore?.wrappedValue     = a
            }}
            s.onFeedback = { [weak self] msg in DispatchQueue.main.async {
                self?.feedback?.wrappedValue = msg
                DispatchQueue.main.asyncAfter(deadline:.now()+1.3) {
                    if self?.feedback?.wrappedValue == msg { self?.feedback?.wrappedValue = "" }
                }
            }}
            v.presentScene(s); scene=s; onReady?(s)
        }

        @objc func onPan(_ g:UIPanGestureRecognizer) {
            guard let v=skView, let s=scene else { return }
            let loc = g.location(in:v)
            switch g.state {
            case .began:
                startTouchX  = loc.x
                startPlayerX = s.px
            case .changed:
                let delta = (loc.x-startTouchX)/v.bounds.width * s.halfW*2.2
                s.movePlayer(toX:startPlayerX+delta)
            default: break
            }
        }
    }
}
