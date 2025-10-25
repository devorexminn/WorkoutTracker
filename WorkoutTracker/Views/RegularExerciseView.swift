//
//  RegularExerciseView.swift
//  WorkoutTracker
//
//  Created by Devorex Minn on 10/22/25.
//

import SwiftUI

struct RegularExerciseView: View {
    let exercise: ExerciseLog
    let bindingForSet: (UUID, UUID, WorkoutDetailView.FieldType) -> Binding<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: Exercise Title + Planned Info
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                if let firstSet = exercise.sets.first {
                    Text("\(exercise.sets.count) sets × \(Int(firstSet.reps)) reps")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            // MARK: Logging Actual Sets
            ForEach(exercise.sets.sorted(by: { $0.setNumber < $1.setNumber })) { set in
                VStack(alignment: .leading, spacing: 6) {
                    Text("Set \(set.setNumber)")
                        .font(.subheadline.bold())

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reps")
                                .font(.caption)
                                .foregroundColor(.gray)
                            // 👇 Leave blank for logging
                            TextField("", value: bindingForSet(exercise.id, set.id, .reps), format: .number)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 60)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weight (lb)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            // 👇 Leave blank for logging
                            TextField("", value: bindingForSet(exercise.id, set.id, .weight), format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)

                    RestTimerView()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .gray.opacity(0.1), radius: 2)
    }
}
