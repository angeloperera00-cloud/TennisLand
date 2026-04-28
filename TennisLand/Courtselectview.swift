import SwiftUI

// MARK: - Court Model
struct TennisCourt {
    let id: Int
    let name: String
    let venue: String
    let surface: String
    let speed: String
    let bounce: String
    let time: String
    let color: Color
    let outerColor: Color
    let description: String
    let specialEffect: String

    static let all: [TennisCourt] = [
        TennisCourt(
            id: 0,
            name: "HARD COURT",
            venue: "Grand Slam Arena",
            surface: "Acrylic",
            speed: "FAST",
            bounce: "HIGH",
            time: "NIGHT",
            color: Color(red: 0.22, green: 0.45, blue: 0.72),
            outerColor: Color(red: 0.14, green: 0.28, blue: 0.50),
            description: "Fast surface. Ball bounces high and true. Perfect for power serves.",
            specialEffect: "Night stadium lights"
        ),
        TennisCourt(
            id: 1,
            name: "CLAY COURT",
            venue: "Roland Garros",
            surface: "Clay",
            speed: "SLOW",
            bounce: "HIGH & HEAVY",
            time: "DAY",
            color: Color(red: 0.72, green: 0.28, blue: 0.08),
            outerColor: Color(red: 0.50, green: 0.18, blue: 0.04),
            description: "Slow surface. Heavy topspin is king. Long rallies dominate.",
            specialEffect: "Warm afternoon sun"
        ),
        TennisCourt(
            id: 2,
            name: "GRASS COURT",
            venue: "Wimbledon",
            surface: "Natural Grass",
            speed: "VERY FAST",
            bounce: "LOW & SKIDDING",
            time: "DAY",
            color: Color(red: 0.12, green: 0.42, blue: 0.15),
            outerColor: Color(red: 0.07, green: 0.28, blue: 0.09),
            description: "Fastest surface. Ball stays low. Serve and volley wins.",
            specialEffect: "Classic overcast sky"
        ),
    ]
}

// MARK: - Court Select View
struct CourtSelectView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedID: Int = 0
    @State private var animateIn = false
    var onSelect: (TennisCourt) -> Void

    var selectedCourt: TennisCourt {
        TennisCourt.all[selectedID]
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.12).ignoresSafeArea()

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
                    Text("CHOOSE COURT")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(3)
                    Spacer()
                    Color.clear.frame(width: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Court preview
                MiniCourtPreview(court: selectedCourt)
                    .frame(height: 160)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Court info
                VStack(spacing: 6) {
                    Text(selectedCourt.name)
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(selectedCourt.color)
                        .tracking(3)

                    Text(selectedCourt.venue)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(1)

                    Text(selectedCourt.description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 4)
                }
                .padding(.bottom, 20)

                // Court stats
                HStack(spacing: 12) {
                    CourtStatBadge(label: "SPEED", value: selectedCourt.speed, color: selectedCourt.color)
                    CourtStatBadge(label: "BOUNCE", value: selectedCourt.bounce, color: selectedCourt.color)
                    CourtStatBadge(label: "TIME", value: selectedCourt.time, color: selectedCourt.color)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // Court cards
                VStack(spacing: 10) {
                    ForEach(TennisCourt.all, id: \.id) { court in
                        CourtCard(
                            court: court,
                            isSelected: selectedID == court.id
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedID = court.id
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Play button
                Button(action: { onSelect(selectedCourt) }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                        Text("PLAY ON \(selectedCourt.name)")
                            .font(.system(size: 15, weight: .black))
                            .tracking(1.5)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedCourt.color)
                    )
                    .shadow(color: selectedCourt.color.opacity(0.4), radius: 20)
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

// MARK: - Mini Court Preview
struct MiniCourtPreview: View {
    let court: TennisCourt

    var body: some View {
        ZStack {
            // Outer area
            RoundedRectangle(cornerRadius: 12)
                .fill(court.outerColor)

            // Court surface
            RoundedRectangle(cornerRadius: 8)
                .fill(court.color)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .overlay(
                    // Court lines
                    GeometryReader { geo in
                        let p = EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
                        let w = geo.size.width - p.leading - p.trailing
                        let h = geo.size.height - p.top - p.bottom
                        let lx = p.leading
                        let ly = p.top

                        ZStack {
                            // Outer boundary
                            Rectangle()
                                .stroke(Color.white.opacity(0.85), lineWidth: 1.5)
                                .frame(width: w, height: h)
                                .offset(x: lx - (geo.size.width - w)/2 + w/2 - geo.size.width/2,
                                        y: ly - (geo.size.height - h)/2 + h/2 - geo.size.height/2)

                            // Net line
                            Rectangle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: w, height: 2.5)
                                .offset(x: lx - (geo.size.width - w)/2 + w/2 - geo.size.width/2, y: 0)

                            // Service lines
                            Rectangle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: w * 0.72, height: 1)
                                .offset(x: lx - (geo.size.width - w)/2 + w/2 - geo.size.width/2,
                                        y: -h * 0.22)

                            Rectangle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: w * 0.72, height: 1)
                                .offset(x: lx - (geo.size.width - w)/2 + w/2 - geo.size.width/2,
                                        y: h * 0.22)

                            // Center line
                            Rectangle()
                                .fill(Color.white.opacity(0.6))
                                .frame(width: 1, height: h * 0.44)
                                .offset(x: lx - (geo.size.width - w)/2 + w/2 - geo.size.width/2, y: 0)
                        }
                    }
                )

            // Grass stripes overlay
            if court.id == 2 {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: Array(repeating: [
                                Color.white.opacity(0.04),
                                Color.clear
                            ], count: 8).flatMap { $0 },
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: court.color.opacity(0.3), radius: 15)
    }
}

// MARK: - Court Stat Badge
struct CourtStatBadge: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white.opacity(0.35))
                .tracking(1.5)
            Text(value)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.25), lineWidth: 1))
        )
    }
}

// MARK: - Court Card
struct CourtCard: View {
    let court: TennisCourt
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Mini court swatch
                RoundedRectangle(cornerRadius: 8)
                    .fill(court.color)
                    .frame(width: 56, height: 42)
                    .overlay(
                        VStack(spacing: 3) {
                            Rectangle().fill(Color.white.opacity(0.7)).frame(height: 1)
                            Rectangle().fill(Color.white.opacity(0.5)).frame(height: 0.5)
                            Rectangle().fill(Color.white.opacity(0.7)).frame(height: 1)
                        }
                        .padding(.horizontal, 4)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(court.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(isSelected ? court.color : .white)
                        .tracking(0.5)
                    Text(court.venue)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                    HStack(spacing: 6) {
                        Text(court.surface)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(court.color)
                        Text("•")
                            .foregroundColor(.white.opacity(0.2))
                            .font(.system(size: 9))
                        Text(court.speed)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(court.color)
                        .font(.system(size: 20))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? court.color.opacity(0.12) : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? court.color.opacity(0.5) : Color.white.opacity(0.07),
                                    lineWidth: isSelected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.01 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
