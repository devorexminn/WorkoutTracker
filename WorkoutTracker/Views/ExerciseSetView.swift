//
//  ExerciseSetView.swift
//  WorkoutTracker
//
//  Created by Devorex Minn on 10/22/25.
//

import SwiftUI

struct ExerciseSetView: View {
    let exercise: ExerciseLog
    let bindingForSet: (UUID, UUID, WorkoutDetailView.FieldType) -> Binding<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Exercise Name
            Text(exercise.name)
                .font(.headline)
                .foregroundColor(.primary)

            // Sets
            ForEach(exercise.sets.sorted(by: { $0.setNumber < $1.setNumber })) { set in
                HStack(spacing: 16) {
                    Text("Set \(set.setNumber)")
                        .font(.subheadline)
                        .frame(width: 60, alignment: .leading)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reps")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("0", value: bindingForSet(exercise.id, set.id, .reps), format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 70)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weight (lb)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("0", value: bindingForSet(exercise.id, set.id, .weight), format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 90)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 2)
    }
}
