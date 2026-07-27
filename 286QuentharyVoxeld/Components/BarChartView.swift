import SwiftUI

struct BarChartView: View {
    let bars: [ChartBar]

    var body: some View {
        GeometryReader { geo in
            let maxValue = max(bars.map(\.value).max() ?? 1, 1)
            let spacing: CGFloat = 8
            let barWidth = max(10, (geo.size.width - spacing * CGFloat(max(bars.count - 1, 0))) / CGFloat(max(bars.count, 1)))

            Canvas { context, size in
                for (index, bar) in bars.enumerated() {
                    let heightRatio = CGFloat(bar.value) / CGFloat(maxValue)
                    let barHeight = max(4, (size.height - 24) * heightRatio)
                    let x = CGFloat(index) * (barWidth + spacing)
                    let y = size.height - 20 - barHeight
                    let rect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                    let path = Path(roundedRect: rect, cornerRadius: 6)
                    context.fill(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [Color.brandPrimary, Color.brandAccent]),
                            startPoint: CGPoint(x: rect.midX, y: rect.maxY),
                            endPoint: CGPoint(x: rect.midX, y: rect.minY)
                        )
                    )
                }
            }
            .overlay(alignment: .bottom) {
                HStack(spacing: spacing) {
                    ForEach(bars) { bar in
                        Text(bar.label)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(width: barWidth)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                }
            }
        }
        .frame(height: 180)
    }
}
