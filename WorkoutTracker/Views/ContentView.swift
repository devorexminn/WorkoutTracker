//
//  ContentView.swift
//  WorkoutTracker
//
//  Created by Devorex Minn on 10/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // ✅ Add this line — allows other views to change the selected tab
    @AppStorage("selectedTab") private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {   // ✅ Add selection binding
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
    }
}

#Preview {
    ContentView()
}
