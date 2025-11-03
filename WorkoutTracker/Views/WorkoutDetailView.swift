//
//  WorkoutDetailView.swift
//  WorkoutTracker
//

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss   // ✅ add this line

    @State private var workout: WorkoutSession
    @State private var logged: [UUID: (reps: Double, weight: Double)] = [:]
    @State private var showSavedPopup = false

    init(workout: WorkoutSession) {
        _workout = State(initialValue: workout)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    Divider()

                    // Render supersets first (grouped), then singles
                    ForEach(sortedSupersetIDs, id: \.self) { supersetID in
                        if let supersetID = supersetID {
                            let group = groupedExercises[supersetID] ?? []
                            SupersetGroupView(
                                group: group,
                                supersetID: supersetID,
                                bindingForSet: binding,
                                supersetLabel: supersetLabel(for:)
                            )
                        } else {
                            let normalExercises = groupedExercises[nil] ?? []
                            ForEach(normalExercises) { exercise in
                                RegularExerciseView(
                                    exercise: exercise,
                                    bindingForSet: binding
                                )
                            }
                        }
                    }

                    finishButton
                }
                .padding(.horizontal)
            }

            if showSavedPopup {
                SavedPopupView(
                    message: "Workout Saved!",
                    detail: "Returning to your workouts...",
                    color: .green
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.3), value: showSavedPopup)
            }
        }
        .navigationTitle("Active Workout")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { seedLoggedStoreIfNeeded() }
    }

    // MARK: Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(workout.title)
                .font(.largeTitle.bold())
            Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top)
    }

    // MARK: Finish Button
    private var finishButton: some View {
        Button {
            saveWorkoutProgress()
            showSavedPopup = true

            // ✅ Keep popup up longer, then dismiss this screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                showSavedPopup = false
                dismiss() // ✅ Go back to ActiveWorkoutView cleanly
            }
        } label: {
            Text("Finish Workout")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(10)
        }
        .padding(.top)
    }

    // MARK: Grouping + Binding + Save (unchanged)
    private var groupedExercises: [UUID?: [ExerciseLog]] {
        Dictionary(grouping: workout.exercises) { $0.supersetID }
    }

    private var sortedSupersetIDs: [UUID?] {
        groupedExercises.keys.sorted {
            if $0 == nil { return true }
            if $1 == nil { return false }
            return $0!.uuidString < $1!.uuidString
        }
    }

    private func supersetLabel(for id: UUID) -> String {
        let allIDs = Array(Set(workout.exercises.compactMap { $0.supersetID }))
            .sorted { $0.uuidString < $1.uuidString }
        if let index = allIDs.firstIndex(of: id) {
            let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            return String(letters[index % letters.count])
        }
        return "?"
    }

    enum FieldType { case reps, weight }

    func binding(for exerciseID: UUID, setID: UUID, type: FieldType) -> Binding<Double> {
        Binding {
            let entry = logged[setID] ?? (reps: 0, weight: 0)
            return (type == .reps) ? entry.reps : entry.weight
        } set: { newValue in
            var entry = logged[setID] ?? (reps: 0, weight: 0)
            if type == .reps {
                entry.reps = newValue
            } else {
                entry.weight = newValue
            }
            logged[setID] = entry
        }
    }

    private func seedLoggedStoreIfNeeded() {
        for exercise in workout.exercises {
            for set in exercise.sets {
                if logged[set.id] == nil {
                    logged[set.id] = (reps: 0, weight: 0)
                }
            }
        }
    }

    private func saveWorkoutProgress() {
        workout.date = Date()
        workout.isCompleted = true

        for eIndex in workout.exercises.indices {
            for sIndex in workout.exercises[eIndex].sets.indices {
                let setID = workout.exercises[eIndex].sets[sIndex].id
                if let entry = logged[setID] {
                    workout.exercises[eIndex].sets[sIndex].reps = Int(entry.reps)
                    workout.exercises[eIndex].sets[sIndex].weight = entry.weight
                }
            }
        }

        context.insert(workout)
        try? context.save()
    }
}
