import SwiftUI
import SwiftData


struct ActiveWorkoutView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutSession.date, order: .reverse)
    private var savedWorkouts: [WorkoutSession]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                // MARK: Custom Header
                Text("Your Workouts")
                    .headerStyle()
                    .padding(.horizontal)

                if savedWorkouts.isEmpty {
                    VStack(spacing: 12) {
                        Text("No workouts yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Create one in the Planner tab.")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .padding(.top, 100)
                } else {
                    List {
                        ForEach(savedWorkouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.title)
                                        .font(.headline)
                                    Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteWorkout)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationBarHidden(true) // hide system title
        }
    }
    
    // MARK: - Delete Workout
    private func deleteWorkout(at offsets: IndexSet) {
        for index in offsets {
            let workoutToDelete = savedWorkouts[index]
            context.delete(workoutToDelete)
        }
        
        do {
            try context.save()
        } catch {
            print("❌ Failed to delete workout: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ActiveWorkoutView()
}
