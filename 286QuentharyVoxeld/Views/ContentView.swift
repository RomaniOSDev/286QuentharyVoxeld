import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            // Store already updated; force view refresh via published flags.
        }
    }
}
