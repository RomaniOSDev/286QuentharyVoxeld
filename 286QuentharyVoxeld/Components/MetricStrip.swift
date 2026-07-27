import SwiftUI

struct MetricItem: Identifiable {
    var id: String { title + value + symbol }
    let title: String
    let value: String
    let symbol: String
}

struct MetricStrip: View {
    let items: [MetricItem]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items) { item in
                    HStack(spacing: 10) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.brandPrimary)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(Color("AppBackground").opacity(0.55)))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.value)
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text(item.title)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color("AppSurface"))
                            .shadow(color: Color.brandPrimary.opacity(0.22), radius: 10, y: 6)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
}
