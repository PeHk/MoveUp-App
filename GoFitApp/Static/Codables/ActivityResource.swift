//
//  ActivityResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 09/01/2022.
//

import Foundation

struct ActivityResource: Codable {
    let startDate: Date
    let endDate: Date
    let calories: Float
    
}

struct LocalWorkout {
    var start: Date
    var end: Date
    var calories: Double
    
    init(start: Date, end: Date, calories: Double) {
        self.start = start
        self.end = end
        self.calories = calories
    }
    
    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }
}
