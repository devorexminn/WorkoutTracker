import SwiftUI

struct SupersetGroupView: View {
    let group: [ExerciseLog]
    let supersetID: UUID?
    let bindingForSet: (UUID, UUID, WorkoutDetailView.FieldType) -> Binding<Double>
    let supersetLabel: (UUID) -> String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Left vertical purple line
            if supersetID != nil {
                Rectangle()
                    .fill(Color.purple.opacity(0.5))
                    .frame(width: 3)
                    .cornerRadius(2)
                    .padding(.vertical, 8)
            }

            VStack(alignment: .leading, spacing: 16) {
                if let supersetID = supersetID {
                    Text("Superset \(supersetLabel(supersetID))")
                        .font(.headline)
                        .foregroundColor(.purple)
                }

                // Loop over sets
                ForEach(0..<maxSetCount(), id: \.self) { setIndex in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Set \(setIndex + 1)")
                            .font(.subheadline.bold())

                        // Each exercise in the superset
                        ForEach(group) { exercise in
                            if setIndex < exercise.sets.count {
                                let set = exercise.sets[setIndex]

                                VStack(alignment: .leading, spacing: 6) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(exercise.name)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)

                                        if let firstSet = exercise.sets.first {
                                            Text("\(exercise.sets.count) sets × \(Int(firstSet.reps)) reps")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }

                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Reps")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            TextField("", value: bindingForSet(exercise.id, set.id, .reps), format: .number)
                                                .keyboardType(.numberPad)
                                                .textFieldStyle(.roundedBorder)
                                                .frame(width: 60)
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Weight (lb)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
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
                                }
                            }
                        }

                        // Rest block after each round
                        RestTimerView(duration: 90)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }

    private func maxSetCount() -> Int {
        group.map { $0.sets.count }.max() ?? 0
    }
}
