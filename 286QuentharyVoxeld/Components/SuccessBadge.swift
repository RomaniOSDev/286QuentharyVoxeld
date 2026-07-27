import SwiftUI

struct SuccessBadge: View {
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(Color("AppTextPrimary"))
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.brandPrimary, Color.brandAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.brandPrimary.opacity(0.45), radius: 12, y: 6)
        )
    }
}
