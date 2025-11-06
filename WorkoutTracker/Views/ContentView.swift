import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("selectedTab") private var selectedTab = 0

    var body: some View {
        // ✅ Use NavigationStack instead of NavigationView
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
            //.navigationTitle(tabTitle(for: selectedTab))
            .navigationBarTitleDisplayMode(.inline)
        }
        // ✅ This line ensures identical layout on iPhone + iPad
        .navigationViewStyle(.stack)
    }

//    private func tabTitle(for index: Int) -> String {
//        switch index {
//        case 0: return "Planner"
//        case 1: return "Workout"
//        case 2: return "History"
//        default: return ""
//        }
//    }
}
