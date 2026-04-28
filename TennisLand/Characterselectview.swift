import SwiftUI

// MARK: - Character Model
struct TennisPlayer {
    let id: Int
    let name: String
    let nationality: String
    let speed: Int
    let power: Int
    let spin: Int
    let serve: Int
    let color: Color
    let emoji: String
    let description: String

    static let all: [TennisPlayer] = [
        TennisPlayer(id: 0, name: "ALEX", nationality: "USA",
                     speed: 88, power: 72, spin: 80, serve: 76,
                     color: Color(red: 0.31, green: 0.8, blue: 0.77),
                     emoji: "🎾", description: "All-round player"),
        TennisPlayer(id: 1, name: "MARCO", nationality: "ITA",
                     speed: 70, power: 95, spin: 65, serve: 90,
                     color: Color(red: 1.0, green: 0.35, blue: 0.35),
                     emoji: "💪", description: "Power hitter"),
        TennisPlayer(id: 2, name: "YUKI", nationality: "JPN",
                     speed: 96, power: 65, spin: 92, serve: 70,
                     color: Color(red: 0.78, green: 0.9, blue: 0.29),
                     emoji: "⚡", description: "Speed & spin"),
        TennisPlayer(id: 3, name: "SOFIA", nationality: "ESP",
                     speed: 80, power: 75, spin: 85, serve: 78,
                     color: Color(red: 0.6, green: 0.43, blue: 0.98),
                     emoji: "🛡️", description: "Defensive master"),
    ]
}

// MARK: - Character Select View
struct CharacterSelectView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedID: Int = 0
    @State private var animateIn = false
    var onSelect: (TennisPlayer) -> Void

    var selectedPlayer: TennisPlayer {
        TennisPlayer.all[selectedID]
    }

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.05, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

            // Grid bg
            GeometryReader { geo in
                Path { path in
                    for i in stride(from: 0, to: geo.size.width, by: 30) {
                        path.move(to: CGPoint(x: i, y: 0))
                        path.addLine(to: CGPoint(x: i, y: geo.size.height))
                    }
                    for j in stride(from: 0, to: geo.size.height, by: 30) {
                        path.move(to: CGPoint(x: 0, y: j))
                        path.addLine(to: CGPoint(x: geo.size.width, y: j))
                    }
                }
                .stroke(Color.white.opacity(0.04), lineWidth: 0.5)
            }
            .ignoresSafeArea()

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
                    Text("CHOOSE PLAYER")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(3)
                    Spacer()
                    // Balance
                    Color.clear.frame(width: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Selected player big display
                ZStack {
                    // Glow
                    Circle()
                        .fill(selectedPlayer.color.opacity(0.15))
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)

                    // Player circle
                    Circle()
                        .fill(selectedPlayer.color.opacity(0.12))
                        .frame(width: 160, height: 160)
                        .overlay(
                            Circle()
                                .stroke(selectedPlayer.color.opacity(0.4), lineWidth: 2)
                        )

                    VStack(spacing: 4) {
                        Text(selectedPlayer.emoji)
                            .font(.system(size: 56))
                        Text(selectedPlayer.name)
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(selectedPlayer.color)
                            .tracking(3)
                        Text(selectedPlayer.nationality)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(2)
                    }
                }
                .frame(height: 180)
                .padding(.bottom, 8)

                // Description
                Text(selectedPlayer.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 24)

                // Stat bars
                VStack(spacing: 10) {
                    StatBar(label: "SPEED", value: selectedPlayer.speed, color: Color(red: 0.31, green: 0.8, blue: 0.77))
                    StatBar(label: "POWER", value: selectedPlayer.power, color: Color(red: 1.0, green: 0.35, blue: 0.35))
                    StatBar(label: "SPIN",  value: selectedPlayer.spin,  color: Color(red: 0.78, green: 0.9, blue: 0.29))
                    StatBar(label: "SERVE", value: selectedPlayer.serve, color: Color(red: 0.6, green: 0.43, blue: 0.98))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 28)

                // Character grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(TennisPlayer.all, id: \.id) { player in
                        CharacterCard(
                            player: player,
                            isSelected: selectedID == player.id
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedID = player.id
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Select button
                Button(action: {
                    onSelect(selectedPlayer)
                }) {
                    HStack(spacing: 12) {
                        Text("SELECT \(selectedPlayer.name)")
                            .font(.system(size: 16, weight: .black))
                            .tracking(2)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedPlayer.color)
                    )
                    .shadow(color: selectedPlayer.color.opacity(0.4), radius: 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 30)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { animateIn = true }
        }
    }
}

// MARK: - Stat Bar
struct StatBar: View {
    let label: String
    let value: Int
    let color: Color
    @State private var animate = false

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .tracking(1.5)
                .frame(width: 44, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.white.opacity(0.06))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: animate ? geo.size.width * CGFloat(value) / 100 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.1), value: animate)
                }
            }
            .frame(height: 6)

            Text("\(value)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
                .frame(width: 28, alignment: .trailing)
        }
        .onAppear { animate = true }
        .onChange(of: value) { _ in
            animate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animate = true
            }
        }
    }
}

// MARK: - Character Card
struct CharacterCard: View {
    let player: TennisPlayer
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(player.emoji)
                    .font(.system(size: 32))
                    .padding(.top, 12)

                Text(player.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isSelected ? player.color : .white)
                    .tracking(1)

                Text(player.description)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected
                          ? player.color.opacity(0.15)
                          : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected
                                    ? player.color.opacity(0.6)
                                    : Color.white.opacity(0.08),
                                    lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
