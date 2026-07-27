import SwiftUI

struct GradientButton: View {
    let title: String
    var systemImage: String? = nil
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.light()
            action()
        }) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .padding(.horizontal, 16)
            .background(
                LinearGradient(
                    colors: isEnabled
                        ? [Color.brandPrimary, Color.brandAccent]
                        : [Color("AppSurface"), Color("AppSurface")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.brandPrimary.opacity(isEnabled ? 0.4 : 0), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
