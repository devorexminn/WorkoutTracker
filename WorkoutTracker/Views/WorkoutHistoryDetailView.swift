//  WorkoutHistoryDetailView.swift
//  WorkoutTracker
//
//  Chronological layout that mirrors Active Workout set structure.

import SwiftUI
import SwiftData

struct WorkoutHistoryDetailView: View {
    let workout: WorkoutSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                Divider()

                // ✅ Mimic the Active Workout layout
                ForEach(sortedSupersetIDs, id: \.self) { supersetID in
                    if let supersetID = supersetID {
                        let group = groupedExercises[supersetID] ?? []
                        if !group.isEmpty {
                            // ✅ Styled Superset Card Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Superset \(supersetLabel(for: supersetID))")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                    .padding(.horizontal, 8)

                                // Determine the number of sets by the max count
                                let maxSets = group.map { $0.sets.count }.max() ?? 0

                                // 🔁 Loop through sets in parallel order (like Active Workout)
                                ForEach(1...maxSets, id: \.self) { setNumber in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Set \(setNumber)")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)

                                        VStack(spacing: 8) {
                                            ForEach(group) { exercise in
                                                if let matchingSet = exercise.sets.first(where: { $0.setNumber == setNumber }) {
                                                    HStack {
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(exercise.name)
                                                                .font(.subheadline.weight(.medium))
                                                                .foregroundColor(.primary)
                                                            HStack(spacing: 8) {
                                                                Text("\(matchingSet.reps) reps")
                                                                Circle()
                                                                    .fill(Color.purple.opacity(0.3))
                                                                    .frame(width: 4, height: 4)
                                                                Text("\(Int(matchingSet.weight)) lb")
                                                            }
                                                            .font(.footnote)
                                                            .foregroundColor(.secondary)
                                                        }
                                                        Spacer()
                                                    }
                                                    .padding(.vertical, 10)
                                                    .padding(.horizontal, 14)
                                                    .background(Color(.systemBackground))
                                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                                    .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                        }
                    } else {
                        // Singles
                        let normalExercises = groupedExercises[nil] ?? []
                        ForEach(normalExercises) { exercise in
                            HistoryExerciseView(exercise: exercise)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Workout Summary")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
    }

    // MARK: Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(workout.title)
                .font(.title2.bold())
                .foregroundColor(.purple)
            Text(workout.date.formatted(date: .long, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }

    // MARK: Helpers
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
}

// MARK: - Read-only Set Row (mirrors ActiveWorkout structure)
private struct HistorySetRow: View {
    let exerciseName: String
    let set: SetLog

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exerciseName)
                .font(.subheadline.weight(.medium))
            HStack {
                Text("\(set.reps) reps")
                Spacer()
                Text("\(Int(set.weight)) lb")
            }
            .font(.footnote)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 6)
    }
}

// MARK: - For single exercises
private struct HistoryExerciseView: View {
    let exercise: ExerciseLog

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
                .font(.headline)
                .padding(.bottom, 2)

            VStack(spacing: 8) {
                ForEach(exercise.sets.sorted(by: { $0.setNumber < $1.setNumber })) { set in
                    HStack {
                        Text("Set \(set.setNumber)")
                            .frame(width: 60, alignment: .leading)
                            .foregroundColor(.gray)

                        Spacer()

                        Text("\(set.reps) reps")
                            .font(.subheadline)
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 4, height: 4)
                        Text("\(Int(set.weight)) lb")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}
