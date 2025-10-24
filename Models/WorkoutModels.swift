//
//  WorkoutModels.swift
//  WorkoutTracker
//
//  Created by Devorex Minn on 10/20/25.
//

import SwiftData
import Foundation

@Model
class WorkoutSession {
    var id: UUID
    var date: Date
    var title: String
    var exercises: [ExerciseLog]
    
    // ✅ Add this new property
     var isCompleted: Bool = false

    init(id: UUID = UUID(), date: Date = Date(), title: String, exercises: [ExerciseLog] = []) {
        self.id = id
        self.date = date
        self.title = title
        self.exercises = exercises
    }
}

@Model
class ExerciseLog {
    var id: UUID
    var name: String
    var sets: [SetLog]
    var supersetID: UUID? // NEW: for grouping exercises

    init(id: UUID = UUID(), name: String, sets: [SetLog] = [], supersetID: UUID? = nil) {
        self.id = id
        self.name = name
        self.sets = sets
        self.supersetID = supersetID
    }
}


@Model
class SetLog {
    var id: UUID
    var setNumber: Int
    var reps: Int
    var weight: Double

    init(id: UUID = UUID(), setNumber: Int, reps: Int = 0, weight: Double = 0.0) {
        self.id = id
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
    }
}
