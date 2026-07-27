import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SurfaceCard {
                        HStack {
                            metric("Unlocked", "\(store.achievementsUnlocked.count)/8")
                            Spacer()
                            metric("Streak", "\(store.streakDays)d")
                            Spacer()
                            metric("Minutes", "\(store.totalMinutes)")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Achievement.all) { achievement in
                            badge(achievement)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .appScreenBackground()
            .navigationTitle("Badges")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color("AppTextSecondary"))
        }
    }

    private func badge(_ achievement: Achievement) -> some View {
        let unlocked = store.isUnlocked(achievement)
        return SurfaceCard(padding: 14) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(unlocked ? Color.brandPrimary.opacity(0.25) : Color("AppBackground").opacity(0.45))
                        .frame(width: 54, height: 54)
                    Image(systemName: achievement.symbolName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(unlocked ? Color.brandAccent : Color("AppTextSecondary"))
                }
                .shadow(color: unlocked ? Color.brandPrimary.opacity(0.35) : .clear, radius: 8, y: 4)

                Text(achievement.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(achievement.detail)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)

                Text(unlocked ? "Unlocked" : "Locked")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(unlocked ? Color.brandPrimary : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .opacity(unlocked ? 1 : 0.72)
        }
    }
}
