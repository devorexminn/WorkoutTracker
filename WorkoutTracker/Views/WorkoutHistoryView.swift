import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @AppStorage("historySortOrder") private var historySortOrder = "newest"
    
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted == true && $0.isTemplate == false },
           sort: \WorkoutSession.date,
           order: .reverse)
    private var pastWorkouts: [WorkoutSession]

    
    // Computed list that reorders based on user preference
    var sortedWorkouts: [WorkoutSession] {
        if historySortOrder == "newest" {
            return pastWorkouts.sorted(by: { $0.date > $1.date })
        } else {
            return pastWorkouts.sorted(by: { $0.date < $1.date })
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: Custom Header
                Text("Past Workouts")
                    .headerStyle()
                    .padding(.horizontal)
                
                // MARK: Sort Order Toggle
                Picker("Sort Order", selection: $historySortOrder) {
                    Text("Newest First").tag("newest")
                    Text("Oldest First").tag("oldest")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // MARK: Workout List
                if sortedWorkouts.isEmpty {
                    Spacer()
                    Text("No past workouts yet")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    List(sortedWorkouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(workout.title)
                                    .font(.headline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    WorkoutHistoryView()
}
