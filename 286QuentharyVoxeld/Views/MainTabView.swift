import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedTab = 0
    @State private var bannerTitle: String?
    @State private var bannerTask: DispatchWorkItem?

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                IntervalCoachView()
                    .tabItem {
                        Label("Coach", systemImage: "timer")
                    }
                    .tag(0)

                TrainHubView()
                    .tabItem {
                        Label("Train", systemImage: "dumbbell.fill")
                    }
                    .tag(1)

                AchievementsView()
                    .tabItem {
                        Label("Badges", systemImage: "medal.fill")
                    }
                    .tag(2)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tint(Color.brandPrimary)
            .onChange(of: selectedTab) { _ in
                HapticsService.light()
            }

            if let bannerTitle {
                AchievementBanner(title: bannerTitle) {
                    dismissBanner()
                }
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .achievementUnlocked)) { note in
            if let title = note.object as? String {
                presentBanner(title)
            }
        }
        .onChange(of: store.latestAchievementTitle) { title in
            if let title {
                presentBanner(title)
                store.latestAchievementTitle = nil
            }
        }
    }

    private func presentBanner(_ title: String) {
        bannerTask?.cancel()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            bannerTitle = title
        }
        let task = DispatchWorkItem {
            dismissBanner()
        }
        bannerTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: task)
    }

    private func dismissBanner() {
        bannerTask?.cancel()
        withAnimation(.easeInOut(duration: 0.3)) {
            bannerTitle = nil
        }
    }
}
