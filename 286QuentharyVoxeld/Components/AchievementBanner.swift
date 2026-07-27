import SwiftUI

struct AchievementBanner: View {
    let title: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image("img_trophy")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .shadow(color: Color.brandPrimary.opacity(0.4), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
            }

            Spacer()

            Button {
                HapticsService.light()
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(8)
                    .background(Circle().fill(Color("AppBackground").opacity(0.55)))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface"))
                .shadow(color: Color.black.opacity(0.35), radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.brandPrimary.opacity(0.45), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}
