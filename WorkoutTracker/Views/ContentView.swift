import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("selectedTab") private var selectedTab = 0

    var body: some View {
        ZStack {
            NavigationStack {
                TabView(selection: $selectedTab) {
                    WorkoutPlannerView()
                        .tabItem {
                            Label("Planner", systemImage: "plus.circle")
                        }
                        .tag(0)

                    ActiveWorkoutView()
                        .tabItem {
                            Label("Workout", systemImage: "bolt.heart")
                        }
                        .tag(1)

                    WorkoutHistoryView()
                        .tabItem {
                            Label("History", systemImage: "clock.fill")
                        }
                        .tag(2)
                }
                .environment(\.horizontalSizeClass, .compact)
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.stack)
        }
    }
}
