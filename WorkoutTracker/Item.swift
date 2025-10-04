//
//  Item.swift
//  WorkoutTracker
//
//  Created by Devorex Minn on 10/4/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
