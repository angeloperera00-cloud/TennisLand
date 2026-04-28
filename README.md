# 🎾 Tennis Land - Setup Guide

## Project Structure
```
TennisLand/
├── TennisLand/                    ← iPhone + iPad App
│   ├── TennisLandApp.swift        ← App entry point
│   ├── HomeView.swift             ← Home screen (2 mode buttons)
│   ├── GameScene/
│   │   ├── TennisGameScene.swift  ← 3D SceneKit game engine
│   │   ├── TennisSceneView.swift  ← SwiftUI ↔ SceneKit bridge
│   │   ├── MobileGameView.swift   ← Mobile play mode UI
│   │   └── WatchGameView.swift    ← Watch + TV play mode UI
│   ├── WatchConnectivity/
│   │   └── WatchSessionManager.swift ← iPhone ↔ Watch communication
│   └── TV/
│       └── AirPlayManager.swift   ← TV mirroring via AirPlay
└── TennisLandWatch/               ← Apple Watch App
    └── WatchApp/
        └── TennisLandWatchApp.swift ← Watch UI + motion detection

```

---

## Step 1: Create Xcode Project

1. Open **Xcode 26**
2. **File → New → Project**
3. Choose **iOS → App**
4. Set:
   - Product Name: `TennisLand`
   - Bundle ID: `com.yourname.tennisland`
   - Interface: `SwiftUI`
   - Language: `Swift`
5. Click **Create**

---

## Step 2: Add Files

Copy all `.swift` files into your Xcode project:
- Drag files from Finder into Xcode navigator
- Check ✅ "Copy items if needed"
- Add to target: `TennisLand`

---

## Step 3: Add Watch Target

1. **File → New → Target**
2. Choose **watchOS → Watch App**
3. Name it: `TennisLandWatch`
4. ✅ Check "Include Complication"
5. Copy `TennisLandWatchApp.swift` into Watch target

---

## Step 4: Add Frameworks

In your **TennisLand** target → **Frameworks, Libraries**:
- ✅ SceneKit (already available)
- ✅ CoreMotion (already available)
- ✅ WatchConnectivity (already available)
- ✅ ReplayKit (for TV broadcast)
- ✅ AVKit (for AirPlay route picker)

---

## Step 5: Info.plist Keys

Add to **Info.plist**:
```xml
<key>NSMotionUsageDescription</key>
<string>Tennis Land uses motion to detect your swings</string>

<key>NSHealthUpdateUsageDescription</key>
<string>Tennis Land tracks your tennis activity</string>
```

---

## Step 6: WatchConnectivity Capability

1. Select **TennisLand** target
2. **Signing & Capabilities** tab
3. Click **+** → Add **Background Modes**
4. Check ✅ **Audio, AirPlay, and Picture in Picture**
5. Add **WatchKit App** capability

---

## Step 7: Build & Run

1. Connect your iPhone
2. Select iPhone as run target
3. Press **⌘ + R** to build
4. For Watch: select Watch as target, build separately

---

## Week by Week Plan

| Week | What to build |
|------|---------------|
| 1-2  | Court + Ball + Basic 3D (done ✅) |
| 3-4  | Watch motion detection refinement |
| 5-6  | AirPlay TV mirroring |
| 7    | Sound effects + Polish |
| 8    | App Store submission |

---

## Common Issues

**Build error "SceneKit not found"**
→ Add SceneKit.framework in Build Phases

**Watch not connecting**
→ Make sure both are on same Apple ID, Bluetooth on

**AirPlay not working**
→ Add AVKit framework, use AVRoutePickerView

---

## Contact
Built with ❤️ using Claude AI
Tennis Land - The Ultimate Tennis Experience 🎾
