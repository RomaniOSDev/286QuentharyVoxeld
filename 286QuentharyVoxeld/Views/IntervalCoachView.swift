import SwiftUI
import UIKit

struct IntervalCoachView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = IntervalCoachViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !store.seenCoachTip {
                        TipBanner(text: "Pick a preset, tweak work/rest/rounds, then Start. You’ll get a 3–2–1 countdown first.") {
                            store.seenCoachTip = true
                        }
                    }

                    MetricStrip(items: [
                        MetricItem(title: "Work", value: "\(store.workDurationSec)s", symbol: "flame.fill"),
                        MetricItem(title: "Rest", value: "\(store.restDurationSec)s", symbol: "wind"),
                        MetricItem(title: "Rounds", value: "\(store.roundsCount)", symbol: "repeat")
                    ])

                    if viewModel.phase == .idle && !viewModel.isRunning {
                        emptySetup
                    } else {
                        activeTimer
                    }

                    controls
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .appScreenBackground()
            .navigationTitle("Interval Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        store.soundEnabled.toggle()
                    } label: {
                        Image(systemName: store.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .foregroundStyle(store.soundEnabled ? Color.brandPrimary : Color("AppTextSecondary"))
                    }
                    .accessibilityLabel(store.soundEnabled ? "Mute sounds" : "Enable sounds")

                    Button {
                        store.hapticsEnabled.toggle()
                    } label: {
                        Image(systemName: store.hapticsEnabled ? "hand.tap.fill" : "hand.raised.slash.fill")
                            .foregroundStyle(store.hapticsEnabled ? Color.brandAccent : Color("AppTextSecondary"))
                    }
                    .accessibilityLabel(store.hapticsEnabled ? "Disable haptics" : "Enable haptics")
                }
            }
            .overlay {
                if viewModel.showCelebration {
                    SuccessBadge(title: "Intervals Complete")
                        .transition(.scale.combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.showCelebration = false
                                    viewModel.phase = .idle
                                }
                            }
                        }
                }
            }
            .onAppear {
                viewModel.startWithRest = store.startWithRest
                updateIdleTimer()
            }
            .onChange(of: viewModel.keepsScreenAwake) { _ in
                updateIdleTimer()
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            .onChange(of: scenePhase) { newPhase in
                viewModel.handleScenePhase(newPhase, store: store)
            }
            .onChange(of: store.startWithRest) { value in
                viewModel.startWithRest = value
            }
        }
    }

    private var emptySetup: some View {
        VStack(spacing: 18) {
            EmptyStateView(
                symbolName: "stopwatch.fill",
                message: "Get Started by Configuring Your Workout",
                secondary: "Set work, rest, and rounds, then hit Start."
            )

            presetsRow
                .padding(.horizontal, 16)

            if store.hasLastIntervalConfig {
                Button {
                    store.restoreLastIntervalConfig()
                } label: {
                    Label(
                        "Last: \(store.lastWorkDurationSec)s / \(store.lastRestDurationSec)s × \(store.lastRoundsCount)",
                        systemImage: "arrow.counterclockwise"
                    )
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.brandAccent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(.plain)
            }

            steppers
                .padding(.horizontal, 16)

            Toggle(isOn: $store.startWithRest) {
                Text("Start with Rest")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .tint(Color.brandPrimary)
            .padding(.horizontal, 20)
        }
    }

    private var presetsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(IntervalPresets.all) { preset in
                    Button {
                        store.applyIntervalPreset(preset)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(preset.title)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text(preset.subtitle)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color("AppSurface").opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.brandPrimary.opacity(0.35), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var activeTimer: some View {
        TimelineView(.periodic(from: .now, by: 0.2)) { context in
            let seconds = viewModel.remainingSeconds(at: context.date)
            let progress = viewModel.progress(at: context.date)
            let label: String = {
                switch viewModel.phase {
                case .countdown: return "Get Ready"
                case .work: return viewModel.isPausedByScene ? "Paused" : "Work"
                case .rest: return viewModel.isPausedByScene ? "Paused" : "Rest"
                case .finished: return "Done"
                case .idle: return "Ready"
                }
            }()

            VStack(spacing: 16) {
                CircularTimerView(
                    progress: progress,
                    seconds: viewModel.phase == .countdown ? viewModel.countdownValue : seconds,
                    label: label,
                    accent: viewModel.phase == .rest ? Color.brandAccent : Color.brandPrimary
                )

                if viewModel.phase != .countdown {
                    Text("Round \(viewModel.currentRound) / \(store.roundsCount)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                if viewModel.isPausedByScene {
                    Text("Timer paused while inactive")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.brandAccent)
                }
            }
            .onChange(of: context.date) { _ in
                viewModel.tick(store: store)
            }
        }
        .padding(.top, 8)
    }

    private var steppers: some View {
        SurfaceCard {
            VStack(spacing: 14) {
                stepperRow(title: "Work Seconds", value: $store.workDurationSec, range: 5...300, step: 5)
                Divider().overlay(Color("AppTextSecondary").opacity(0.25))
                stepperRow(title: "Rest Seconds", value: $store.restDurationSec, range: 0...180, step: 5)
                Divider().overlay(Color("AppTextSecondary").opacity(0.25))
                stepperRow(title: "Rounds", value: $store.roundsCount, range: 1...50, step: 1)
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            if !viewModel.isRunning && viewModel.phase != .countdown {
                if viewModel.phase != .idle {
                    steppers
                        .padding(.horizontal, 16)
                }

                GradientButton(title: "Start", systemImage: "play.fill") {
                    store.rememberIntervalConfig()
                    viewModel.startWithRest = store.startWithRest
                    viewModel.start(
                        work: store.workDurationSec,
                        rest: store.restDurationSec,
                        rounds: store.roundsCount
                    )
                }
                .padding(.horizontal, 16)
            } else {
                HStack(spacing: 10) {
                    Button {
                        viewModel.skipPhase(store: store)
                    } label: {
                        Label("Skip Phase", systemImage: "forward.end.fill")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color("AppSurface")))
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.skipRound(store: store)
                    } label: {
                        Label("Skip Round", systemImage: "goforward")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color("AppSurface")))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)

                GradientButton(title: "Stop", systemImage: "stop.fill") {
                    viewModel.stop()
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func stepperRow(title: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            HStack(spacing: 12) {
                roundButton(system: "minus") {
                    value.wrappedValue = max(range.lowerBound, value.wrappedValue - step)
                }
                Text("\(value.wrappedValue)")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(minWidth: 36)
                    .monospacedDigit()
                roundButton(system: "plus") {
                    value.wrappedValue = min(range.upperBound, value.wrappedValue + step)
                }
            }
        }
    }

    private func roundButton(system: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticsService.light()
            action()
        } label: {
            Image(systemName: system)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.brandPrimary))
                .shadow(color: Color.brandPrimary.opacity(0.35), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }

    private func updateIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = viewModel.keepsScreenAwake
    }
}
