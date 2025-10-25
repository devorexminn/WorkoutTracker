//
//  WorkoutDetailView.swift
//  WorkoutTracker
//
//  Created by Devorex Minn on 10/4/25.
//

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var context
    @State private var workout: WorkoutSession
    @State private var completedSets: [UUID: [SetLog]] = [:]
    
    init(workout: WorkoutSession) {
        _workout = State(initialValue: workout)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                Divider()
                
                // MARK: Exercise / Superset Rendering
                ForEach(sortedSupersetIDs, id: \.self) { supersetID in
                    if let supersetID = supersetID {
                        // ✅ Superset Group
                        let group = groupedExercises[supersetID] ?? []
                        SupersetGroupView(
                            group: group,
                            supersetID: supersetID,
                            bindingForSet: binding,
                            supersetLabel: supersetLabel(for:)
                        )
                    } else {
                        // ✅ Regular Exercises
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
        .navigationTitle("Active Workout")
        .navigationBarTitleDisplayMode(.inline)
        // ✅ Initialize blank logs when the screen appears
        .onAppear {
            initializeEmptyLogs()
        }
    }
    
    // MARK: - Header Section
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
    
    // MARK: - Finish Button
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
    
    // MARK: - Grouping Helpers
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
        let allIDs = Array(
            Set(workout.exercises.compactMap { $0.supersetID })
        ).sorted(by: { $0.uuidString < $1.uuidString })
        
        if let index = allIDs.firstIndex(of: id) {
            let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            return String(letters[index % letters.count])
        }
        return "?"
    }
    
    // MARK: - Binding Logic
    enum FieldType { case reps, weight }
    
    func binding(for exerciseID: UUID, setID: UUID, type: FieldType) -> Binding<Double> {
        Binding {
            // ✅ Only use logged values from completedSets (starts at 0)
            if let updated = completedSets[exerciseID]?.first(where: { $0.id == setID }) {
                return type == .reps ? Double(updated.reps) : updated.weight
            } else {
                return 0
            }
        } set: { newValue in
            var sets = completedSets[exerciseID] ?? []
            if let index = sets.firstIndex(where: { $0.id == setID }) {
                if type == .reps {
                    sets[index].reps = Int(newValue)
                } else {
                    sets[index].weight = newValue
                }
            }
            completedSets[exerciseID] = sets
        }
    }
    
    // MARK: - Initialize Blank Logs
    private func initializeEmptyLogs() {
        for exercise in workout.exercises {
            let emptySets = exercise.sets.map { original in
                // ✅ Always start at 0 reps & 0 weight (blank log)
                SetLog(setNumber: original.setNumber, reps: 0, weight: 0)
            }
            completedSets[exercise.id] = emptySets
        }
    }
    
    // MARK: - Save Workout
    private func saveWorkoutProgress() {
        workout.date = Date()
        workout.isCompleted = true
        
        // ✅ Replace exercise sets with completed logs
        for (exerciseID, logs) in completedSets {
            if let index = workout.exercises.firstIndex(where: { $0.id == exerciseID }) {
                workout.exercises[index].sets = logs
            }
        }

        context.insert(workout)
        try? context.save()
    }
}
