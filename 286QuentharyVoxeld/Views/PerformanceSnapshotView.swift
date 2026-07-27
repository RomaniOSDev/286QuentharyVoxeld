import SwiftUI

struct PerformanceSnapshotView: View {
    @EnvironmentObject private var store: AppStore
    @State private var range: StatsRange = .weekly
    @State private var exerciseFilter = "All"
    @State private var showAdd = false
    @State private var expandedID: UUID?

    private var filtered: [WorkoutSession] {
        store.filteredSessions(range: range, exerciseType: exerciseFilter)
    }

    private var rangeMinutes: Int {
        filtered.reduce(0) { $0 + $1.durationMinutes }
    }

    private var rangeCalories: Int {
        filtered.reduce(0) { $0 + $1.calories }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Range", selection: $range) {
                ForEach(StatsRange.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .onChange(of: range) { _ in
                HapticsService.light()
            }

            ScrollView {
                VStack(spacing: 16) {
                    if !store.seenStatsTip {
                        TipBanner(text: "Track weekly goals, browse the activity heatmap, and filter sessions by exercise type.") {
                            store.seenStatsTip = true
                        }
                    }

                    weeklyGoalsCard

                    MetricStrip(items: [
                        MetricItem(title: "Sessions", value: "\(filtered.count)", symbol: "figure.run"),
                        MetricItem(title: "Minutes", value: "\(rangeMinutes)", symbol: "clock.fill"),
                        MetricItem(title: "Calories", value: "\(rangeCalories)", symbol: "flame.fill")
                    ])

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Activity Calendar")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Last 12 weeks")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color("AppTextSecondary"))
                            ActivityHeatmapView(days: store.activityHeatmap())
                        }
                    }
                    .padding(.horizontal, 16)

                    chartCard(
                        title: "Sessions",
                        subtitle: "Workouts logged",
                        bars: store.chartCounts(for: range),
                        unit: "sessions"
                    )

                    chartCard(
                        title: "Training Time",
                        subtitle: "Minutes per period",
                        bars: store.chartMinutes(for: range),
                        unit: "min"
                    )

                    chartCard(
                        title: "Calories",
                        subtitle: "Estimated burn",
                        bars: store.chartCalories(for: range),
                        unit: "cal"
                    )

                    if store.sessions.isEmpty {
                        EmptyStateView(
                            symbolName: "chart.bar.xaxis",
                            message: "No stats yet",
                            secondary: "Log a workout or finish an interval session to fill the charts."
                        )
                    } else {
                        filterRow

                        Text("Recent Sessions")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 4)

                        LazyVStack(spacing: 12) {
                            ForEach(filtered) { session in
                                sessionCard(session)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .padding(.bottom, 88)
            }

            GradientButton(title: "Add Workout", systemImage: "plus.circle.fill") {
                showAdd = true
            }
            .padding(16)
        }
        .appScreenBackground()
        .sheet(isPresented: $showAdd) {
            AddWorkoutSheet()
                .environmentObject(store)
        }
    }

    private var weeklyGoalsCard: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Weekly Goals")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Text(store.streakFreezeAvailable ? "Freeze ready" : "Freeze used")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(store.streakFreezeAvailable ? Color.brandAccent : Color("AppTextSecondary"))
                }

                goalRow(
                    title: "Workouts",
                    value: "\(store.weeklySessionsCount)/\(store.weeklyWorkoutGoal)",
                    progress: store.workoutGoalProgress
                )
                goalRow(
                    title: "Minutes",
                    value: "\(store.weeklyMinutesCount)/\(store.weeklyMinuteGoal)",
                    progress: store.minuteGoalProgress
                )
            }
        }
        .padding(.horizontal, 16)
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.exerciseTypeOptions(), id: \.self) { type in
                    Button {
                        HapticsService.light()
                        exerciseFilter = type
                    } label: {
                        Text(type)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(exerciseFilter == type ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(exerciseFilter == type ? Color.brandPrimary.opacity(0.35) : Color("AppSurface"))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func goalRow(title: String, value: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color("AppTextSecondary"))
                Spacer()
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("AppTextSecondary").opacity(0.2))
                    Capsule()
                        .fill(LinearGradient(colors: [Color.brandPrimary, Color.brandAccent], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(8, geo.size.width * progress))
                }
            }
            .frame(height: 10)
        }
    }

    private func chartCard(title: String, subtitle: String, bars: [ChartBar], unit: String) -> some View {
        let total = bars.reduce(0) { $0 + $1.value }
        let peak = bars.map(\.value).max() ?? 0

        return SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(total)")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.brandPrimary)
                        Text("total \(unit)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }

                BarChartView(bars: bars)

                HStack {
                    Text("Peak: \(peak) \(unit)")
                    Spacer()
                    Text(range.rawValue)
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 16)
    }

    private func sessionCard(_ session: WorkoutSession) -> some View {
        let isExpanded = expandedID == session.id
        return Button {
            HapticsService.light()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                expandedID = isExpanded ? nil : session.id
            }
        } label: {
            SurfaceCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text(session.exerciseType)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.brandAccent)
                        }
                        Spacer()
                        Text("\(session.durationMinutes) min")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                    }

                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color("AppTextSecondary"))

                    if isExpanded {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 16) {
                                Label("\(session.calories) cal", systemImage: "flame.fill")
                                if let rpe = session.rpe {
                                    Label("RPE \(rpe)", systemImage: "bolt.fill")
                                }
                            }
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("AppTextSecondary"))

                            if let note = session.note, !note.isEmpty {
                                Text(note)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                store.deleteSession(session)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddWorkoutSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    @State private var title = ""
    @State private var exerciseType = ExerciseLibrary.names[0]
    @State private var duration = 30
    @State private var note = ""
    @State private var rpe = 5
    @State private var shakeTrigger = 0
    @State private var errorText: String?

    private enum Field {
        case title
        case note
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Workout title", text: $title)
                        .focused($focusedField, equals: .title)
                        .shake(trigger: shakeTrigger)
                    Picker("Exercise", selection: $exerciseType) {
                        ForEach(ExerciseLibrary.names, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(.menu)
                    Stepper("Duration: \(duration) min", value: $duration, in: 5...180, step: 5)
                }

                Section("How it felt") {
                    Stepper("RPE: \(rpe)/10", value: $rpe, in: 1...10)
                    TextField("Notes (optional)", text: $note, axis: .vertical)
                        .focused($focusedField, equals: .note)
                        .lineLimit(3...5)
                }

                if let errorText {
                    Section {
                        Text(errorText)
                            .foregroundStyle(Color.red)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .background(Color("AppBackground").ignoresSafeArea())
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        focusedField = nil
                        HapticsService.light()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.bold)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                    .fontWeight(.semibold)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorText = "Enter a workout title."
            shakeTrigger += 1
            HapticsService.warning()
            return
        }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        store.addSession(
            WorkoutSession(
                title: trimmed,
                exerciseType: exerciseType,
                durationMinutes: duration,
                calories: duration * 7,
                note: trimmedNote.isEmpty ? nil : trimmedNote,
                rpe: rpe
            )
        )
        dismiss()
    }
}
