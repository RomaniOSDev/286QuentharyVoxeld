import SwiftUI

struct EmptyStateView: View {
    let symbolName: String
    let message: String
    var secondary: String? = nil
    var imageName: String? = nil

    var body: some View {
        VStack(spacing: 18) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.brandPrimary.opacity(0.35), radius: 16, y: 8)
            } else {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.brandPrimary.opacity(0.35), Color.brandAccent.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 96, height: 96)
                        .shadow(color: Color.brandPrimary.opacity(0.35), radius: 16, y: 8)

                    Image(systemName: symbolName)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.brandPrimary, Color.brandAccent],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }

            Text(message)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            if let secondary {
                Text(secondary)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
