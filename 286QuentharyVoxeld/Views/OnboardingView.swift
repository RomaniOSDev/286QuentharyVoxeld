import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStore
    @State private var page = 0

    private let pages: [(symbol: String, title: String, detail: String)] = [
        ("figure.run.circle.fill", "Get Started", "Discover how the app helps you log and plan workouts effectively."),
        ("list.clipboard.fill", "Log Workouts", "Easily input your completed exercises and view your history."),
        ("dumbbell.fill", "Create Routines", "Start by setting up a custom workout plan tailored to your needs.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    pageView(pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: page)

            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? Color.brandPrimary : Color("AppTextSecondary").opacity(0.35))
                        .frame(width: index == page ? 22 : 8, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: page)
                }
            }
            .padding(.bottom, 20)

            GradientButton(
                title: page == pages.count - 1 ? "Get Started" : "Next",
                systemImage: page == pages.count - 1 ? "checkmark" : "arrow.right"
            ) {
                if page < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        page += 1
                    }
                } else {
                    store.completeOnboarding()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .appScreenBackground()
    }

    private func pageView(_ item: (symbol: String, title: String, detail: String)) -> some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: item.symbol)
                .font(.system(size: 72, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.brandPrimary, Color.brandAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.brandPrimary.opacity(0.45), radius: 18, y: 10)
                .scaleEffect(1)
                .padding(28)
                .background(
                    Circle()
                        .fill(Color("AppSurface").opacity(0.85))
                        .shadow(color: Color.brandPrimary.opacity(0.25), radius: 20, y: 10)
                )
                .transition(.scale.combined(with: .opacity))

            Text(item.title)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(Color("AppTextPrimary"))

            Text(item.detail)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}
