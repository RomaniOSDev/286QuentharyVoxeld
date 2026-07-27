import Foundation

struct WorkoutSession: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var exerciseType: String
    var durationMinutes: Int
    var date: Date
    var calories: Int
    var note: String?
    var rpe: Int?

    init(
        id: UUID = UUID(),
        title: String,
        exerciseType: String,
        durationMinutes: Int,
        date: Date = Date(),
        calories: Int,
        note: String? = nil,
        rpe: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.exerciseType = exerciseType
        self.durationMinutes = durationMinutes
        self.date = date
        self.calories = calories
        self.note = note
        self.rpe = rpe
    }
}
