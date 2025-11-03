//  WorkoutHistoryDetailView.swift
//  WorkoutTracker
//
//  Read-only summary screen that mirrors WorkoutDetailView’s grouping/order.

import SwiftUI
import SwiftData

struct WorkoutHistoryDetailView: View {
    let workout: WorkoutSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                Divider()

                // 👇 Use the SAME grouping + ordering approach as WorkoutDetailView
                ForEach(sortedSupersetIDs, id: \.self) { supersetID in
                    if let supersetID = supersetID {
                        let group = groupedExercises[supersetID] ?? []
                        HistorySupersetGroupView(
                            group: group,
                            supersetID: supersetID,
                            supersetLabel: supersetLabel(for:)
                        )
                        .padding(.horizontal)
                    } else {
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

    // MARK: Header (read-only)
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

    // MARK: Grouping / Ordering (copied to match WorkoutDetailView behavior)
    private var groupedExercises: [UUID?: [ExerciseLog]] {
        // Dictionary(grouping:) preserves the *input order* within each grouped array.
        Dictionary(grouping: workout.exercises) { $0.supersetID }
    }

    private var sortedSupersetIDs: [UUID?] {
        // Matches your guide file exactly (nil first).
        groupedExercises.keys.sorted {
            if $0 == nil { return true }
            if $1 == nil { return false }
            return $0!.uuidString < $1!.uuidString
        }
    }

    // Same label scheme as your active view (A, B, C…)
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

// MARK: - Read-only subviews

// MARK: - Read-only subviews (PRETTIER VERSION)

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

                        Text("\(Int(set.reps)) reps")
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 4, height: 4)

                        Text("\(Int(set.weight)) lb")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
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

private struct HistorySupersetGroupView: View {
    let group: [ExerciseLog]
    let supersetID: UUID
    let supersetLabel: (UUID) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("Superset \(supersetLabel(supersetID))")
                    .font(.headline)
                    .foregroundColor(.purple)
                Spacer()
            }
            .padding(.horizontal, 6)

            VStack(spacing: 14) {
                ForEach(group) { exercise in
                    HistoryExerciseView(exercise: exercise)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemGroupedBackground))
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 2)
        )
    }
}
