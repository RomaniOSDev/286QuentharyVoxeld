import AudioToolbox
import Foundation

enum FeedbackService {
    static var soundEnabled = true

    static func playSuccessSound() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1057)
    }

    static func playPhaseSound() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1003)
    }

    static func vibrate() {
        guard HapticsService.isEnabled else { return }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    static func celebrateAchievement() {
        HapticsService.success()
        playSuccessSound()
    }

    static func confirmSave() {
        HapticsService.medium()
        playSuccessSound()
    }

    static func intervalComplete() {
        HapticsService.success()
        vibrate()
        playSuccessSound()
    }
}
