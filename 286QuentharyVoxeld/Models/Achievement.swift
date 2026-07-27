import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let detail: String
    let symbolName: String

    static let all: [Achievement] = [
        Achievement(
            id: "first_step",
            title: "First Step",
            detail: "You completed your first workout.",
            symbolName: "figure.run"
        ),
        Achievement(
            id: "routine_builder",
            title: "Routine Builder",
            detail: "You created 5 custom routines.",
            symbolName: "list.bullet.rectangle.fill"
        ),
        Achievement(
            id: "time_tracker",
            title: "Time Tracker",
            detail: "You exercised for over 100 minutes total.",
            symbolName: "timer"
        ),
        Achievement(
            id: "consistent_trainer",
            title: "Consistent Trainer",
            detail: "You worked out for three consecutive days.",
            symbolName: "flame.fill"
        ),
        Achievement(
            id: "hundred_sessions",
            title: "+100 Sessions",
            detail: "You completed more than 100 rounds.",
            symbolName: "bolt.circle.fill"
        ),
        Achievement(
            id: "longest_session",
            title: "Longest Session",
            detail: "Set a session record over one hour.",
            symbolName: "clock.badge.checkmark.fill"
        ),
        Achievement(
            id: "fitness_enthusiast",
            title: "Fitness Enthusiast",
            detail: "Keep a long streak with steady weekly workouts.",
            symbolName: "star.circle.fill"
        ),
        Achievement(
            id: "avid_exerciser",
            title: "Avid Exerciser",
            detail: "Stay active for four weeks without missing a day.",
            symbolName: "trophy.fill"
        )
    ]
}
