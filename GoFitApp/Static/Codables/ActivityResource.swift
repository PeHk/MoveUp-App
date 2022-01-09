//
//  ActivityResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 09/01/2022.
//

import Foundation

struct ActivityResource: Codable {
    let start_date: Date
    let end_date: Date
    let calories: Double
    let name: String
    
    var duration: TimeInterval {
        end_date.timeIntervalSince(start_date)
    }
    
    
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
