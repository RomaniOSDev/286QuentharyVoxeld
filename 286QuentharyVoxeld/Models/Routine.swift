import Foundation

struct RoutineExercise: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var reps: Int
    var sets: Int

    init(id: UUID = UUID(), name: String, reps: Int = 10, sets: Int = 3) {
        self.id = id
        self.name = name
        self.reps = reps
        self.sets = sets
    }
}

struct Routine: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var exercises: [RoutineExercise]
    var isCompletedToday: Bool
    var completedOn: Date?

    init(
        id: UUID = UUID(),
        title: String,
        exercises: [RoutineExercise],
        isCompletedToday: Bool = false,
        completedOn: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.exercises = exercises
        self.isCompletedToday = isCompletedToday
        self.completedOn = completedOn
    }

    var totalMoves: Int {
        exercises.reduce(0) { $0 + ($1.reps * $1.sets) }
    }
}

enum ExerciseLibrary {
    static let names: [String] = [
        "Push-ups",
        "Squats",
        "Lunges",
        "Plank",
        "Burpees",
        "Jumping Jacks",
        "Mountain Climbers",
        "Sit-ups",
        "Deadlifts",
        "Pull-ups"
    ]
}

struct RoutineTemplate: Identifiable {
    let id: String
    let title: String
    let detail: String
    let exerciseNames: [String]

    func makeRoutine() -> Routine {
        Routine(
            title: title,
            exercises: exerciseNames.map { RoutineExercise(name: $0) }
        )
    }
}

enum RoutineTemplates {
    static let all: [RoutineTemplate] = [
        RoutineTemplate(
            id: "full_body",
            title: "Full Body Blast",
            detail: "Push, squat, core",
            exerciseNames: ["Push-ups", "Squats", "Plank", "Lunges"]
        ),
        RoutineTemplate(
            id: "hiit_core",
            title: "HIIT Core",
            detail: "Fast metabolic finisher",
            exerciseNames: ["Burpees", "Mountain Climbers", "Jumping Jacks", "Sit-ups"]
        ),
        RoutineTemplate(
            id: "strength_pull",
            title: "Pull Strength",
            detail: "Upper-body pull focus",
            exerciseNames: ["Pull-ups", "Deadlifts", "Plank", "Push-ups"]
        ),
        RoutineTemplate(
            id: "legs_day",
            title: "Legs Day",
            detail: "Lower-body volume",
            exerciseNames: ["Squats", "Lunges", "Deadlifts", "Jumping Jacks"]
        )
    ]
}

struct IntervalPreset: Identifiable {
    let id: String
    let title: String
    let work: Int
    let rest: Int
    let rounds: Int

    var subtitle: String { "\(work)s / \(rest)s × \(rounds)" }
}

enum IntervalPresets {
    static let all: [IntervalPreset] = [
        IntervalPreset(id: "tabata", title: "Tabata", work: 20, rest: 10, rounds: 8),
        IntervalPreset(id: "hiit", title: "HIIT", work: 40, rest: 20, rounds: 6),
        IntervalPreset(id: "emom", title: "EMOM", work: 50, rest: 10, rounds: 10),
        IntervalPreset(id: "endurance", title: "Endurance", work: 60, rest: 30, rounds: 5)
    ]
}

