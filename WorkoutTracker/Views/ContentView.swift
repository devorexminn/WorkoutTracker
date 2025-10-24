//
//  ContentView.swift
//  WorkoutTracker
//
//  Created by Devorex Minn on 10/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            WorkoutPlannerView()
                .tabItem {
                    Label("Planner", systemImage: "plus.circle")
                }
            ActiveWorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "bolt.heart")
                }
            WorkoutHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
