//
//  WorkoutDetailView.swift
//  WorkoutTracker
//

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var context
    @State private var workout: WorkoutSession

    // ✅ Flat store keyed by SetLog.id so bindings always hit the same entry
    //    Key = setID, Value = (reps, weight)
    @State private var logged: [UUID: (reps: Double, weight: Double)] = [:]

    init(workout: WorkoutSession) {
        _workout = State(initialValue: workout)
    }

    var body: some View {
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
                            bindingForSet: binding,            // ← uses setID now
                            supersetLabel: supersetLabel(for:)
                        )
                    } else {
                        let normalExercises = groupedExercises[nil] ?? []
                        ForEach(normalExercises) { exercise in
                            RegularExerciseView(
                                exercise: exercise,
                                bindingForSet: binding           // ← uses setID now
                            )
                        }
                    }
                }

                finishButton
            }
            .padding(.horizontal)
        }
        .navigationTitle("Active Workout")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { seedLoggedStoreIfNeeded() }   // ✅ ensure stable entries for all setIDs
    }

    // MARK: - Header

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

    // MARK: - Finish

    private var finishButton: some View {
        Button {
            saveWorkoutProgress()
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

    // MARK: - Grouping

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

    // MARK: - Bindings (keyed by setID)

    enum FieldType { case reps, weight }

    /// Binding that reads/writes by the SetLog's id (setID).
    /// This avoids any array reordering or ID-mismatch issues.
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

    // MARK: - Seed logged store

    /// Pre-create zeroed entries for every setID so the binding always finds a stable value.
    private func seedLoggedStoreIfNeeded() {
        for exercise in workout.exercises {
            for set in exercise.sets {
                if logged[set.id] == nil {
                    logged[set.id] = (reps: 0, weight: 0)
                }
            }
        }
    }

    // MARK: - Save

    private func saveWorkoutProgress() {
        workout.date = Date()
        workout.isCompleted = true

        // Write logged values back into the model by matching set.id
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
