//  CustomExercise.swift
//  WorkoutTracker

import SwiftData
import Foundation

@Model
class CustomExercise {
    var id: UUID
    var name: String
    var bodyPart: String
    var target: String
    var equipment: String?
    var notes: String?
    var dateAdded: Date

    init(name: String, bodyPart: String, target: String, equipment: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.bodyPart = bodyPart
        self.target = target
        self.equipment = equipment
        self.notes = notes
        self.dateAdded = Date()
    }
}
