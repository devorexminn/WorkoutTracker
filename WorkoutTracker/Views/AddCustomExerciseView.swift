//  AddCustomExerciseView.swift
//  WorkoutTracker

import SwiftUI
import SwiftData

struct AddCustomExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    // Pass the exercise back to the WorkoutPlannerView
    var onAdd: (ExerciseItem) -> Void

    @State private var name = ""
//    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Custom Exercise") {
                    TextField("Exercise Name", text: $name)
//                    TextField("Notes (optional)", text: $notes)
                }
            }
            .navigationTitle("Add Custom Exercise")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // 1️⃣ Save to SwiftData
                        let customExercise = CustomExercise(
                            name: name,
                            bodyPart: "",     // not needed
                            target: "",       // not needed
                            equipment: nil,
//                            notes: notes.isEmpty ? nil : notes
                        )
                        context.insert(customExercise)
                        try? context.save()
                        
                        // 2️⃣ Add directly to workout planner
                        let exerciseItem = ExerciseItem(
                            name: name.capitalized,
                            sets: 3,
                            targetReps: 12,
                            restPeriod: "60s",
                            isSuperset: false
                        )
                        onAdd(exerciseItem)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
