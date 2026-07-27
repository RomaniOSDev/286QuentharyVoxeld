import Foundation
import Combine

final class AppStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let workDurationSec = "workDurationSec"
        static let restDurationSec = "restDurationSec"
        static let roundsCount = "roundsCount"
        static let workoutsCompleted = "workoutsCompleted"
        static let totalMinutes = "totalMinutes"
        static let roundsCompleted = "roundsCompleted"
        static let longestSession = "longestSession"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let routines = "routines"
        static let sessions = "sessions"
        static let routinesCreated = "routinesCreated"
        static let soundEnabled = "soundEnabled"
        static let hapticsEnabled = "hapticsEnabled"
        static let lastWorkDurationSec = "lastWorkDurationSec"
        static let lastRestDurationSec = "lastRestDurationSec"
        static let lastRoundsCount = "lastRoundsCount"
        static let hasLastIntervalConfig = "hasLastIntervalConfig"
        static let weeklyWorkoutGoal = "weeklyWorkoutGoal"
        static let weeklyMinuteGoal = "weeklyMinuteGoal"
        static let streakFreezeWeek = "streakFreezeWeek"
        static let accentTheme = "accentTheme"
        static let seenCoachTip = "seenCoachTip"
        static let seenBuilderTip = "seenBuilderTip"
        static let seenStatsTip = "seenStatsTip"
        static let startWithRest = "startWithRest"
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var workDurationSec: Int {
        didSet { defaults.set(workDurationSec, forKey: Keys.workDurationSec) }
    }

    @Published var restDurationSec: Int {
        didSet { defaults.set(restDurationSec, forKey: Keys.restDurationSec) }
    }

    @Published var roundsCount: Int {
        didSet { defaults.set(roundsCount, forKey: Keys.roundsCount) }
    }

    @Published var workoutsCompleted: Int {
        didSet { defaults.set(workoutsCompleted, forKey: Keys.workoutsCompleted) }
    }

    @Published var totalMinutes: Int {
        didSet { defaults.set(totalMinutes, forKey: Keys.totalMinutes) }
    }

    @Published var roundsCompleted: Int {
        didSet { defaults.set(roundsCompleted, forKey: Keys.roundsCompleted) }
    }

    @Published var longestSession: Int {
        didSet { defaults.set(longestSession, forKey: Keys.longestSession) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var routinesCreated: Int {
        didSet { defaults.set(routinesCreated, forKey: Keys.routinesCreated) }
    }

    @Published var achievementsUnlocked: Set<String> {
        didSet {
            defaults.set(Array(achievementsUnlocked), forKey: Keys.achievementsUnlocked)
        }
    }

    @Published var routines: [Routine] {
        didSet { save(routines, key: Keys.routines) }
    }

    @Published var sessions: [WorkoutSession] {
        didSet { save(sessions, key: Keys.sessions) }
    }

    @Published var latestAchievementTitle: String?

    @Published var soundEnabled: Bool {
        didSet {
            defaults.set(soundEnabled, forKey: Keys.soundEnabled)
            FeedbackService.soundEnabled = soundEnabled
        }
    }

    @Published var hapticsEnabled: Bool {
        didSet {
            defaults.set(hapticsEnabled, forKey: Keys.hapticsEnabled)
            HapticsService.isEnabled = hapticsEnabled
        }
    }

    @Published var lastWorkDurationSec: Int {
        didSet { defaults.set(lastWorkDurationSec, forKey: Keys.lastWorkDurationSec) }
    }

    @Published var lastRestDurationSec: Int {
        didSet { defaults.set(lastRestDurationSec, forKey: Keys.lastRestDurationSec) }
    }

    @Published var lastRoundsCount: Int {
        didSet { defaults.set(lastRoundsCount, forKey: Keys.lastRoundsCount) }
    }

    @Published var hasLastIntervalConfig: Bool {
        didSet { defaults.set(hasLastIntervalConfig, forKey: Keys.hasLastIntervalConfig) }
    }

    @Published var weeklyWorkoutGoal: Int {
        didSet { defaults.set(weeklyWorkoutGoal, forKey: Keys.weeklyWorkoutGoal) }
    }

    @Published var weeklyMinuteGoal: Int {
        didSet { defaults.set(weeklyMinuteGoal, forKey: Keys.weeklyMinuteGoal) }
    }

    @Published var accentTheme: AccentTheme {
        didSet {
            defaults.set(accentTheme.rawValue, forKey: Keys.accentTheme)
            AccentTheme.current = accentTheme
        }
    }

    @Published var seenCoachTip: Bool {
        didSet { defaults.set(seenCoachTip, forKey: Keys.seenCoachTip) }
    }

    @Published var seenBuilderTip: Bool {
        didSet { defaults.set(seenBuilderTip, forKey: Keys.seenBuilderTip) }
    }

    @Published var seenStatsTip: Bool {
        didSet { defaults.set(seenStatsTip, forKey: Keys.seenStatsTip) }
    }

    @Published var startWithRest: Bool {
        didSet { defaults.set(startWithRest, forKey: Keys.startWithRest) }
    }

    @Published private(set) var streakFreezeUsedThisWeek: Bool = false

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        workDurationSec = defaults.object(forKey: Keys.workDurationSec) as? Int ?? 30
        restDurationSec = defaults.object(forKey: Keys.restDurationSec) as? Int ?? 10
        roundsCount = defaults.object(forKey: Keys.roundsCount) as? Int ?? 5
        workoutsCompleted = defaults.integer(forKey: Keys.workoutsCompleted)
        totalMinutes = defaults.integer(forKey: Keys.totalMinutes)
        roundsCompleted = defaults.integer(forKey: Keys.roundsCompleted)
        longestSession = defaults.integer(forKey: Keys.longestSession)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        routinesCreated = defaults.integer(forKey: Keys.routinesCreated)
        let unlocked = defaults.stringArray(forKey: Keys.achievementsUnlocked) ?? []
        achievementsUnlocked = Set(unlocked)
        routines = Self.load([Routine].self, key: Keys.routines, defaults: defaults) ?? []
        sessions = Self.load([WorkoutSession].self, key: Keys.sessions, defaults: defaults) ?? []
        soundEnabled = defaults.object(forKey: Keys.soundEnabled) as? Bool ?? true
        hapticsEnabled = defaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true
        lastWorkDurationSec = defaults.object(forKey: Keys.lastWorkDurationSec) as? Int ?? 30
        lastRestDurationSec = defaults.object(forKey: Keys.lastRestDurationSec) as? Int ?? 10
        lastRoundsCount = defaults.object(forKey: Keys.lastRoundsCount) as? Int ?? 5
        hasLastIntervalConfig = defaults.bool(forKey: Keys.hasLastIntervalConfig)
        weeklyWorkoutGoal = defaults.object(forKey: Keys.weeklyWorkoutGoal) as? Int ?? 3
        weeklyMinuteGoal = defaults.object(forKey: Keys.weeklyMinuteGoal) as? Int ?? 60
        let themeRaw = defaults.string(forKey: Keys.accentTheme) ?? AccentTheme.ember.rawValue
        accentTheme = AccentTheme(rawValue: themeRaw) ?? .ember
        seenCoachTip = defaults.bool(forKey: Keys.seenCoachTip)
        seenBuilderTip = defaults.bool(forKey: Keys.seenBuilderTip)
        seenStatsTip = defaults.bool(forKey: Keys.seenStatsTip)
        startWithRest = defaults.bool(forKey: Keys.startWithRest)
        streakFreezeUsedThisWeek = false

        FeedbackService.soundEnabled = soundEnabled
        HapticsService.isEnabled = hapticsEnabled
        AccentTheme.current = accentTheme
        streakFreezeUsedThisWeek = defaults.string(forKey: Keys.streakFreezeWeek) == currentWeekKey()
        refreshRoutineCompletionFlags()
    }

    var weeklySessionsCount: Int {
        sessionsThisWeek.count
    }

    var weeklyMinutesCount: Int {
        sessionsThisWeek.reduce(0) { $0 + $1.durationMinutes }
    }

    var workoutGoalProgress: Double {
        min(1, Double(weeklySessionsCount) / Double(max(weeklyWorkoutGoal, 1)))
    }

    var minuteGoalProgress: Double {
        min(1, Double(weeklyMinutesCount) / Double(max(weeklyMinuteGoal, 1)))
    }

    var streakFreezeAvailable: Bool {
        !streakFreezeUsedThisWeek
    }

    private var sessionsThisWeek: [WorkoutSession] {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        return sessions.filter { $0.date >= start }
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        HapticsService.medium()
    }

    func applyIntervalPreset(_ preset: IntervalPreset) {
        workDurationSec = preset.work
        restDurationSec = preset.rest
        roundsCount = preset.rounds
        HapticsService.light()
    }

    func rememberIntervalConfig() {
        lastWorkDurationSec = workDurationSec
        lastRestDurationSec = restDurationSec
        lastRoundsCount = roundsCount
        hasLastIntervalConfig = true
    }

    func restoreLastIntervalConfig() {
        guard hasLastIntervalConfig else { return }
        workDurationSec = lastWorkDurationSec
        restDurationSec = lastRestDurationSec
        roundsCount = lastRoundsCount
        HapticsService.light()
    }

    func duplicateRoutine(_ routine: Routine) {
        let copy = Routine(
            title: "\(routine.title) Copy",
            exercises: routine.exercises.map {
                RoutineExercise(name: $0.name, reps: $0.reps, sets: $0.sets)
            }
        )
        addRoutine(copy)
    }

    func addRoutineFromTemplate(_ template: RoutineTemplate) {
        addRoutine(template.makeRoutine())
    }

    func recordActivity() {
        let today = dayFormatter.string(from: Date())
        let last = defaults.string(forKey: Keys.lastActivityDate)

        if last == today {
            evaluateAchievements()
            return
        }

        if let last,
           let lastDate = dayFormatter.date(from: last) {
            let calendar = Calendar.current
            let dayGap = calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: lastDate),
                to: calendar.startOfDay(for: Date())
            ).day ?? 0

            if dayGap == 1 {
                streakDays += 1
            } else if dayGap == 2, streakFreezeAvailable {
                streakDays += 1
                markStreakFreezeUsed()
            } else if last == nil && streakDays == 0 {
                streakDays = 1
            } else {
                streakDays = 1
            }
        } else if last == nil && streakDays == 0 {
            streakDays = 1
        } else {
            streakDays = 1
        }

        defaults.set(today, forKey: Keys.lastActivityDate)
        evaluateAchievements()
    }

    func addRoutine(_ routine: Routine) {
        routines.insert(routine, at: 0)
        routinesCreated += 1
        recordActivity()
        evaluateAchievements()
        FeedbackService.confirmSave()
    }

    func markRoutineCompleted(_ routine: Routine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[index].isCompletedToday = true
        routines[index].completedOn = Date()
        workoutsCompleted += 1
        let estimated = max(5, routines[index].exercises.count * 3)
        totalMinutes += estimated
        if estimated > longestSession {
            longestSession = estimated
        }
        let session = WorkoutSession(
            title: routines[index].title,
            exerciseType: "Routine",
            durationMinutes: estimated,
            calories: estimated * 7
        )
        sessions.insert(session, at: 0)
        recordActivity()
        evaluateAchievements()
        FeedbackService.confirmSave()
    }

    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
        HapticsService.light()
    }

    func addSession(_ session: WorkoutSession) {
        sessions.insert(session, at: 0)
        workoutsCompleted += 1
        totalMinutes += session.durationMinutes
        if session.durationMinutes > longestSession {
            longestSession = session.durationMinutes
        }
        recordActivity()
        evaluateAchievements()
        FeedbackService.confirmSave()
    }

    func deleteSession(_ session: WorkoutSession) {
        sessions.removeAll { $0.id == session.id }
        HapticsService.light()
    }

    func completeIntervalSession(rounds: Int, totalSeconds: Int) {
        let minutes = max(1, Int(ceil(Double(totalSeconds) / 60.0)))
        workoutsCompleted += 1
        roundsCompleted += rounds
        totalMinutes += minutes
        if minutes > longestSession {
            longestSession = minutes
        }
        let session = WorkoutSession(
            title: "Interval Session",
            exerciseType: "Intervals",
            durationMinutes: minutes,
            calories: minutes * 8
        )
        sessions.insert(session, at: 0)
        recordActivity()
        evaluateAchievements()
        FeedbackService.intervalComplete()
    }

    func evaluateAchievements() {
        var newlyUnlocked: [Achievement] = []

        for achievement in Achievement.all {
            guard !achievementsUnlocked.contains(achievement.id) else { continue }
            if isConditionMet(for: achievement) {
                achievementsUnlocked.insert(achievement.id)
                newlyUnlocked.append(achievement)
            }
        }

        if let first = newlyUnlocked.first {
            latestAchievementTitle = first.title
            FeedbackService.celebrateAchievement()
            NotificationCenter.default.post(name: .achievementUnlocked, object: first.title)
        }
    }

    func isUnlocked(_ achievement: Achievement) -> Bool {
        achievementsUnlocked.contains(achievement.id)
    }

    func resetAllData() {
        hasSeenOnboarding = false
        workDurationSec = 30
        restDurationSec = 10
        roundsCount = 5
        workoutsCompleted = 0
        totalMinutes = 0
        roundsCompleted = 0
        longestSession = 0
        streakDays = 0
        routinesCreated = 0
        achievementsUnlocked = []
        routines = []
        sessions = []
        latestAchievementTitle = nil
        hasLastIntervalConfig = false
        weeklyWorkoutGoal = 3
        weeklyMinuteGoal = 60
        seenCoachTip = false
        seenBuilderTip = false
        seenStatsTip = false
        startWithRest = false
        streakFreezeUsedThisWeek = false
        defaults.removeObject(forKey: Keys.lastActivityDate)
        defaults.removeObject(forKey: Keys.streakFreezeWeek)
        NotificationCenter.default.post(name: .dataReset, object: nil)
        HapticsService.medium()
    }

    func chartCounts(for range: StatsRange) -> [ChartBar] {
        chartBars(for: range) { $0.count }
    }

    func chartMinutes(for range: StatsRange) -> [ChartBar] {
        chartBars(for: range) { sessions in
            sessions.reduce(0) { $0 + $1.durationMinutes }
        }
    }

    func chartCalories(for range: StatsRange) -> [ChartBar] {
        chartBars(for: range) { sessions in
            sessions.reduce(0) { $0 + $1.calories }
        }
    }

    func sessions(in range: StatsRange) -> [WorkoutSession] {
        let calendar = Calendar.current
        let now = Date()
        let start: Date
        switch range {
        case .weekly:
            start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) ?? now
        case .monthly:
            start = calendar.date(byAdding: .day, value: -27, to: calendar.startOfDay(for: now)) ?? now
        case .yearly:
            start = calendar.date(byAdding: .month, value: -11, to: now) ?? now
        }
        return sessions.filter { $0.date >= start }
    }

    func filteredSessions(range: StatsRange, exerciseType: String?) -> [WorkoutSession] {
        let base = sessions(in: range)
        guard let exerciseType, exerciseType != "All" else { return base }
        return base.filter { $0.exerciseType == exerciseType }
    }

    func exerciseTypeOptions() -> [String] {
        let types = Set(sessions.map(\.exerciseType))
        return ["All"] + types.sorted()
    }

    func activityHeatmap(days: Int = 84) -> [HeatmapDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<days).map { offset in
            let date = calendar.date(byAdding: .day, value: -(days - 1 - offset), to: today) ?? today
            let count = sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
            return HeatmapDay(id: dayFormatter.string(from: date), date: date, count: count)
        }
    }

    private func markStreakFreezeUsed() {
        let key = currentWeekKey()
        defaults.set(key, forKey: Keys.streakFreezeWeek)
        streakFreezeUsedThisWeek = true
    }

    private func currentWeekKey() -> String {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return "\(comps.yearForWeekOfYear ?? 0)-\(comps.weekOfYear ?? 0)"
    }

    private func chartBars(for range: StatsRange, metric: ([WorkoutSession]) -> Int) -> [ChartBar] {
        let calendar = Calendar.current
        let now = Date()

        switch range {
        case .weekly:
            return (0..<7).map { offset in
                let day = calendar.date(byAdding: .day, value: -6 + offset, to: now) ?? now
                let daySessions = sessions.filter { calendar.isDate($0.date, inSameDayAs: day) }
                let label = dayFormatter.shortWeekday(from: day)
                return ChartBar(id: "c\(label)\(offset)", label: label, value: metric(daySessions))
            }
        case .monthly:
            return (0..<4).map { week in
                let start = calendar.date(byAdding: .day, value: -28 + (week * 7), to: now) ?? now
                let end = calendar.date(byAdding: .day, value: 6, to: start) ?? start
                let weekSessions = sessions.filter { $0.date >= start && $0.date <= end }
                return ChartBar(id: "W\(week + 1)", label: "W\(week + 1)", value: metric(weekSessions))
            }
        case .yearly:
            return (0..<12).map { monthOffset in
                guard let monthDate = calendar.date(byAdding: .month, value: -11 + monthOffset, to: now) else {
                    return ChartBar(id: "M\(monthOffset)", label: "M", value: 0)
                }
                let comps = calendar.dateComponents([.year, .month], from: monthDate)
                let monthSessions = sessions.filter {
                    let c = calendar.dateComponents([.year, .month], from: $0.date)
                    return c.year == comps.year && c.month == comps.month
                }
                let label = dayFormatter.shortMonth(from: monthDate)
                return ChartBar(id: "m\(label)\(monthOffset)", label: label, value: metric(monthSessions))
            }
        }
    }

    private func isConditionMet(for achievement: Achievement) -> Bool {
        switch achievement.id {
        case "first_step":
            return workoutsCompleted >= 1
        case "routine_builder":
            return routinesCreated >= 5 || routines.count >= 5
        case "time_tracker":
            return totalMinutes >= 100
        case "consistent_trainer":
            return streakDays >= 3
        case "hundred_sessions":
            return roundsCompleted >= 100
        case "longest_session":
            return longestSession > 60
        case "fitness_enthusiast":
            return streakDays == 29 && workoutsCompleted >= 8
        case "avid_exerciser":
            return streakDays >= 28
        default:
            return false
        }
    }

    private func refreshRoutineCompletionFlags() {
        let calendar = Calendar.current
        var changed = false
        for index in routines.indices {
            if let completedOn = routines[index].completedOn,
               !calendar.isDateInToday(completedOn),
               routines[index].isCompletedToday {
                routines[index].isCompletedToday = false
                changed = true
            }
        }
        if changed {
            save(routines, key: Keys.routines)
        }
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

enum StatsRange: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

    var id: String { rawValue }
}

struct ChartBar: Identifiable, Equatable {
    let id: String
    let label: String
    let value: Int
}

private extension DateFormatter {
    func shortWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EE"
        return String(formatter.string(from: date).prefix(2))
    }

    func shortMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}
