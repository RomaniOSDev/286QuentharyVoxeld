import Foundation
import SwiftUI

enum IntervalPhase: Equatable {
    case idle
    case countdown
    case work
    case rest
    case finished
}

final class IntervalCoachViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var isPausedByScene = false
    @Published var phase: IntervalPhase = .idle
    @Published var currentRound = 1
    @Published var phaseEndsAt: Date?
    @Published var phaseTotalSeconds = 0
    @Published var showCelebration = false
    @Published var countdownValue = 3
    @Published var startWithRest = false

    private var pausedRemaining: TimeInterval = 0
    private var activeWork = 0
    private var activeRest = 0
    private var activeRounds = 0

    var keepsScreenAwake: Bool {
        isRunning || phase == .countdown
    }

    func start(work: Int, rest: Int, rounds: Int) {
        guard work > 0, rest >= 0, rounds > 0 else { return }
        HapticsService.medium()
        activeWork = work
        activeRest = rest
        activeRounds = rounds
        isRunning = true
        isPausedByScene = false
        showCelebration = false
        currentRound = 1
        countdownValue = 3
        phase = .countdown
        phaseTotalSeconds = 3
        pausedRemaining = 3
        phaseEndsAt = Date().addingTimeInterval(3)
    }

    func stop() {
        isRunning = false
        isPausedByScene = false
        phase = .idle
        phaseEndsAt = nil
        phaseTotalSeconds = 0
        pausedRemaining = 0
        currentRound = 1
        countdownValue = 3
        showCelebration = false
        HapticsService.light()
    }

    func skipPhase(store: AppStore) {
        guard isRunning, !isPausedByScene, phase == .work || phase == .rest else { return }
        HapticsService.medium()
        advance(from: phase, store: store)
    }

    func skipRound(store: AppStore) {
        guard isRunning, !isPausedByScene else { return }
        guard phase == .work || phase == .rest || phase == .countdown else { return }
        HapticsService.medium()

        if currentRound >= activeRounds {
            finish(store: store)
            return
        }

        currentRound += 1
        beginPhase(.work, duration: activeWork)
    }

    func handleScenePhase(_ scenePhase: ScenePhase, store: AppStore) {
        guard isRunning || phase == .countdown else { return }

        if scenePhase != .active {
            if let endsAt = phaseEndsAt {
                pausedRemaining = max(0, endsAt.timeIntervalSinceNow)
            }
            phaseEndsAt = nil
            isPausedByScene = true
            return
        }

        if isPausedByScene {
            isPausedByScene = false
            if pausedRemaining > 0 {
                phaseEndsAt = Date().addingTimeInterval(pausedRemaining)
            }
        }

        tick(store: store)
    }

    func tick(store: AppStore) {
        guard !isPausedByScene, let endsAt = phaseEndsAt else { return }
        guard Date() >= endsAt else {
            if phase == .countdown {
                countdownValue = max(1, remainingSeconds(at: Date()))
            }
            return
        }

        switch phase {
        case .countdown:
            beginFirstWorkOrRest()
        case .work, .rest:
            advance(from: phase, store: store)
        default:
            break
        }
    }

    func remainingSeconds(at date: Date) -> Int {
        guard let endsAt = phaseEndsAt else {
            return isPausedByScene ? Int(ceil(pausedRemaining)) : phaseTotalSeconds
        }
        return max(0, Int(ceil(endsAt.timeIntervalSince(date))))
    }

    func progress(at date: Date) -> Double {
        guard phaseTotalSeconds > 0 else { return 0 }
        let remaining = Double(remainingSeconds(at: date))
        return 1 - (remaining / Double(phaseTotalSeconds))
    }

    private func beginFirstWorkOrRest() {
        if startWithRest, activeRest > 0 {
            beginPhase(.rest, duration: activeRest)
        } else {
            beginPhase(.work, duration: activeWork)
        }
    }

    private func advance(from current: IntervalPhase, store: AppStore) {
        switch current {
        case .work:
            if activeRest > 0 {
                beginPhase(.rest, duration: activeRest)
            } else if currentRound >= activeRounds {
                finish(store: store)
            } else {
                currentRound += 1
                beginPhase(.work, duration: activeWork)
            }
        case .rest:
            if currentRound >= activeRounds {
                finish(store: store)
            } else {
                currentRound += 1
                beginPhase(.work, duration: activeWork)
            }
        default:
            break
        }
    }

    private func beginPhase(_ next: IntervalPhase, duration: Int) {
        phase = next
        phaseTotalSeconds = max(duration, 0)
        pausedRemaining = TimeInterval(max(duration, 0))
        if duration <= 0 {
            phaseEndsAt = Date()
        } else {
            phaseEndsAt = Date().addingTimeInterval(TimeInterval(duration))
        }
        FeedbackService.playPhaseSound()
        HapticsService.light()
    }

    private func finish(store: AppStore) {
        let total = activeRounds * (activeWork + activeRest)
        phase = .finished
        isRunning = false
        phaseEndsAt = nil
        showCelebration = true
        store.completeIntervalSession(rounds: activeRounds, totalSeconds: total)
    }
}
