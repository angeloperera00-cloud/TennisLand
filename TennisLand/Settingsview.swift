import SwiftUI

// MARK: - App Settings
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    @Published var soundEnabled: Bool = true
    @Published var musicEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    @Published var difficulty: Difficulty = .medium
    @Published var preferredCourt: Int = 0

    enum Difficulty: String, CaseIterable {
        case easy   = "EASY"
        case medium = "MEDIUM"
        case hard   = "HARD"
        case pro    = "PRO"

        var description: String {
            switch self {
            case .easy:   return "Perfect for beginners"
            case .medium: return "Balanced challenge"
            case .hard:   return "Fast and aggressive AI"
            case .pro:    return "Almost unbeatable"
            }
        }

        var color: Color {
            switch self {
            case .easy:   return Color(red: 0.31, green: 0.8, blue: 0.77)
            case .medium: return Color(red: 0.78, green: 0.9, blue: 0.29)
            case .hard:   return Color(red: 1.0, green: 0.6, blue: 0.2)
            case .pro:    return Color(red: 1.0, green: 0.35, blue: 0.35)
            }
        }

        var aiSpeed: Float {
            switch self {
            case .easy:   return 0.04
            case .medium: return 0.06
            case .hard:   return 0.09
            case .pro:    return 0.13
            }
        }

        var aiErrorChance: Float {
            switch self {
            case .easy:   return 0.25
            case .medium: return 0.10
            case .hard:   return 0.04
            case .pro:    return 0.01
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = AppSettings.shared
    @State private var animateIn = false

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.12).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.white.opacity(0.08)))
                    }
                    Spacer()
                    Text("SETTINGS")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(3)
                    Spacer()
                    Color.clear.frame(width: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // AUDIO section
                        SettingsSection(title: "AUDIO") {
                            SettingsToggle(
                                icon: "speaker.wave.2.fill",
                                title: "Sound Effects",
                                subtitle: "Ball hits, crowd, net",
                                isOn: $settings.soundEnabled,
                                color: Color(red: 0.31, green: 0.8, blue: 0.77)
                            )
                            Divider().background(Color.white.opacity(0.06))
                            SettingsToggle(
                                icon: "music.note",
                                title: "Music",
                                subtitle: "Background music",
                                isOn: $settings.musicEnabled,
                                color: Color(red: 0.78, green: 0.9, blue: 0.29)
                            )
                            Divider().background(Color.white.opacity(0.06))
                            SettingsToggle(
                                icon: "iphone.radiowaves.left.and.right",
                                title: "Haptic Feedback",
                                subtitle: "Vibration on hits",
                                isOn: $settings.hapticsEnabled,
                                color: Color(red: 0.6, green: 0.43, blue: 0.98)
                            )
                        }

                        // DIFFICULTY section
                        SettingsSection(title: "DIFFICULTY") {
                            VStack(spacing: 8) {
                                ForEach(AppSettings.Difficulty.allCases, id: \.self) { level in
                                    DifficultyOption(
                                        level: level,
                                        isSelected: settings.difficulty == level
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            settings.difficulty = level
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        // ABOUT section
                        SettingsSection(title: "ABOUT") {
                            SettingsInfoRow(icon: "tennisball.fill",
                                          title: "Tennis Land",
                                          value: "Version 1.0")
                            Divider().background(Color.white.opacity(0.06))
                            SettingsInfoRow(icon: "applewatch",
                                          title: "Apple Watch",
                                          value: "Series 6+")
                            Divider().background(Color.white.opacity(0.06))
                            SettingsInfoRow(icon: "iphone",
                                          title: "iPhone",
                                          value: "iOS 17+")
                        }

                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .opacity(animateIn ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) { animateIn = true }
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.35))
                .tracking(2.5)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.07), lineWidth: 1))
            )
        }
    }
}

// MARK: - Settings Toggle
struct SettingsToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 15))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: color))
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Difficulty Option
struct DifficultyOption: View {
    let level: AppSettings.Difficulty
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Circle()
                    .fill(isSelected ? level.color : Color.white.opacity(0.1))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(level.color.opacity(0.4), lineWidth: 1)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.rawValue)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(isSelected ? level.color : .white)
                        .tracking(1)
                    Text(level.description)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(level.color)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? level.color.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Info Row
struct SettingsInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.4))
                .font(.system(size: 15))
                .frame(width: 36)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.35))
        }
        .padding(.vertical, 8)
    }
}
