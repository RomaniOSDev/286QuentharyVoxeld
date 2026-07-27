import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Feedback")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))

                            Toggle(isOn: $store.soundEnabled) {
                                Label {
                                    Text("Sound")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                } icon: {
                                    Image(systemName: store.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                        .foregroundStyle(Color.brandPrimary)
                                        .frame(width: 24)
                                }
                            }
                            .tint(Color.brandPrimary)

                            Divider().overlay(Color("AppTextSecondary").opacity(0.2))

                            Toggle(isOn: $store.hapticsEnabled) {
                                Label {
                                    Text("Haptic Feedback")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                } icon: {
                                    Image(systemName: store.hapticsEnabled ? "hand.tap.fill" : "hand.raised.slash.fill")
                                        .foregroundStyle(Color.brandAccent)
                                        .frame(width: 24)
                                }
                            }
                            .tint(Color.brandAccent)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Accent Theme")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))

                            HStack(spacing: 12) {
                                ForEach(AccentTheme.allCases) { theme in
                                    Button {
                                        HapticsService.light()
                                        store.accentTheme = theme
                                    } label: {
                                        VStack(spacing: 8) {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [theme.primary, theme.accent],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 36, height: 36)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color("AppTextPrimary"), lineWidth: store.accentTheme == theme ? 2 : 0)
                                                )
                                            Text(theme.title)
                                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                .foregroundStyle(Color("AppTextSecondary"))
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Weekly Goals")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))

                            Stepper("Workouts: \(store.weeklyWorkoutGoal)", value: $store.weeklyWorkoutGoal, in: 1...14)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))

                            Stepper("Minutes: \(store.weeklyMinuteGoal)", value: $store.weeklyMinuteGoal, in: 15...600, step: 15)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                    .padding(.horizontal, 16)

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Stats")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))

                            HStack {
                                stat("Workouts", "\(store.workoutsCompleted)")
                                Spacer()
                                stat("Minutes", "\(store.totalMinutes)")
                                Spacer()
                                stat("Streak", "\(store.streakDays)")
                            }

                            HStack {
                                stat("Rounds", "\(store.roundsCompleted)")
                                Spacer()
                                stat("Routines", "\(store.routines.count)")
                                Spacer()
                                stat("Freeze", store.streakFreezeAvailable ? "Ready" : "Used")
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    SurfaceCard(padding: 0) {
                        VStack(spacing: 0) {
                            settingsButton(title: "Rate Us", system: "star.fill") {
                                requestReview()
                            }
                            Divider().overlay(Color("AppTextSecondary").opacity(0.2))
                            settingsButton(title: "Privacy Policy", system: "hand.raised.fill") {
                                openLink(AppLinks.privacy.url)
                            }
                            Divider().overlay(Color("AppTextSecondary").opacity(0.2))
                            settingsButton(title: "Terms of Use", system: "doc.text.fill") {
                                openLink(AppLinks.terms.url)
                            }
                            Divider().overlay(Color("AppTextSecondary").opacity(0.2))
                            settingsButton(title: "Reset All Data", system: "trash.fill", destructive: true) {
                                showResetAlert = true
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 24)
            }
            .appScreenBackground()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    store.resetAllData()
                }
            } message: {
                Text("This clears workouts, routines, achievements, and settings on this device.")
            }
        }
    }

    private func openLink(_ url: URL) {
        UIApplication.shared.open(url)
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color("AppTextSecondary"))
        }
    }

    private func settingsButton(title: String, system: String, destructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button {
            HapticsService.light()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: system)
                    .foregroundStyle(destructive ? Color.red : Color.brandPrimary)
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(destructive ? Color.red : Color("AppTextPrimary"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) ?? UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
