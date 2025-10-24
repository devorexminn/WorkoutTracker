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
                        // ✅ Regular single exercises
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
    }
    
    // MARK: - Sections
    
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
        let allIDs = Array(Set(workout.exercises.compactMap { $0.supersetID })).sorted(by: { $0.uuidString < $1.uuidString })
        if let index = allIDs.firstIndex(of: id) {
            let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            return String(letters[index % letters.count])
        }
        return "?"
    }
    
    enum FieldType { case reps, weight }
    
    func binding(for exerciseID: UUID, setID: UUID, type: FieldType) -> Binding<Double> {
        Binding {
            if let updated = completedSets[exerciseID]?.first(where: { $0.id == setID }) {
                return type == .reps ? Double(updated.reps) : updated.weight
            } else if let original = workout.exercises.first(where: { $0.id == exerciseID })?.sets.first(where: { $0.id == setID }) {
                return type == .reps ? Double(original.reps) : original.weight
            } else {
                return 0
            }
        } set: { newValue in
            let sets = completedSets[exerciseID] ?? workout.exercises.first(where: { $0.id == exerciseID })?.sets ?? []
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
    
    private func saveWorkoutProgress() {
        // Mark the workout as completed
        workout.date = Date()
        workout.isCompleted = true   // ✅ requires model update below
        
        // Save only when finished
        context.insert(workout)
        try? context.save()
    }
}
