import SwiftUI

struct WorkoutBuilderView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showAdd = false

    var body: some View {
        VStack(spacing: 0) {
            Image("img_banner")
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .clipped()
                .overlay(alignment: .bottomLeading) {
                    Text("Workout Builder")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .shadow(color: Color.black.opacity(0.45), radius: 6, y: 2)
                        .padding(16)
                }
                .padding(.bottom, 8)

            if !store.seenBuilderTip {
                TipBanner(text: "Use a template below or build your own. Swipe right to complete, long-press to duplicate.") {
                    store.seenBuilderTip = true
                }
                .padding(.bottom, 8)
            }

            templatesRow
                .padding(.bottom, 8)

            if store.routines.isEmpty {
                ScrollView {
                    EmptyStateView(
                        symbolName: "dumbbell.fill",
                        message: "Start crafting your perfect routine!",
                        secondary: "Add exercises from the library and build your plan.",
                        imageName: "img_workout"
                    )
                }
            } else {
                List {
                    ForEach(store.routines) { routine in
                        routineRow(routine)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    store.markRoutineCompleted(routine)
                                } label: {
                                    Label("Complete", systemImage: "checkmark.circle.fill")
                                }
                                .tint(Color.brandPrimary)
                            }
                            .swipeActions(edge: .leading) {
                                Button(role: .destructive) {
                                    store.deleteRoutine(routine)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .contextMenu {
                                Button {
                                    store.duplicateRoutine(routine)
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                Button(role: .destructive) {
                                    store.deleteRoutine(routine)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }

            GradientButton(title: "Add New Routine", systemImage: "plus") {
                showAdd = true
            }
            .padding(16)
        }
        .appScreenBackground()
        .sheet(isPresented: $showAdd) {
            AddRoutineSheet()
                .environmentObject(store)
        }
    }

    private var templatesRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Templates")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(RoutineTemplates.all) { template in
                        Button {
                            store.addRoutineFromTemplate(template)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.title)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text(template.detail)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color("AppSurface").opacity(0.9))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Color.brandAccent.opacity(0.35), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func routineRow(_ routine: Routine) -> some View {
        SurfaceCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(Color("AppTextSecondary").opacity(0.25), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: routine.isCompletedToday ? 1 : 0.15)
                        .stroke(Color.brandPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Image(systemName: routine.isCompletedToday ? "checkmark" : "dumbbell.fill")
                        .foregroundStyle(Color.brandAccent)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 6) {
                    Text(routine.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(routine.exercises.map(\.name).joined(separator: " · "))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                    Text("\(routine.exercises.count) exercises · \(routine.totalMoves) moves")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.brandAccent)
                }

                Spacer()

                if routine.isCompletedToday {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.brandPrimary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddRoutineSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @FocusState private var titleFocused: Bool

    @State private var title = ""
    @State private var selected: Set<String> = []
    @State private var shakeTrigger = 0
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Routine") {
                    TextField("Routine title", text: $title)
                        .focused($titleFocused)
                        .shake(trigger: shakeTrigger)
                }

                Section("Exercises") {
                    ForEach(ExerciseLibrary.names, id: \.self) { name in
                        Button {
                            titleFocused = false
                            HapticsService.light()
                            if selected.contains(name) {
                                selected.remove(name)
                            } else {
                                selected.insert(name)
                            }
                        } label: {
                            HStack {
                                Text(name)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Spacer()
                                Image(systemName: selected.contains(name) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selected.contains(name) ? Color.brandPrimary : Color("AppTextSecondary"))
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.borderless)
                    }
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
            .navigationTitle("Add Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        titleFocused = false
                        HapticsService.light()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .fontWeight(.bold)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        titleFocused = false
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
        guard !trimmed.isEmpty, !selected.isEmpty else {
            errorText = "Add a title and at least one exercise."
            shakeTrigger += 1
            HapticsService.warning()
            return
        }

        let exercises = selected.sorted().map { RoutineExercise(name: $0) }
        store.addRoutine(Routine(title: trimmed, exercises: exercises))
        dismiss()
    }
}
