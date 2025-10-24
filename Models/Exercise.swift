//  Exercise.swift
//  WorkoutTracker

import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let bodyPart: String?
    let target: String?
    let equipment: String?
    let gifUrl: String?
}
