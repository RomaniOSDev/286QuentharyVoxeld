import SwiftUI

struct CircularTimerView: View {
    let progress: Double
    let seconds: Int
    let label: String
    let accent: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppSurface"), lineWidth: 18)
                .shadow(color: Color.black.opacity(0.35), radius: 12, y: 8)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    AngularGradient(
                        colors: [accent, Color.brandAccent, accent],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: accent.opacity(0.55), radius: 10, y: 0)
                .animation(.easeInOut(duration: 0.25), value: progress)

            VStack(spacing: 6) {
                Text(label.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .tracking(1.2)

                Text(timeString)
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .monospacedDigit()
                    .shadow(color: accent.opacity(0.35), radius: 8, y: 4)
            }
        }
        .frame(width: 240, height: 240)
    }

    private var timeString: String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
