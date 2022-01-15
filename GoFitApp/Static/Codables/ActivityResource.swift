//
//  ActivityResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 09/01/2022.
//

import Foundation
import CoreLocation

struct ActivityResource: Codable {
    let start_date: Date
    let end_date: Date
    let calories: Double
    let name: String
    let traveledDistance: Double
    let route: [Coordinates]
    
    var duration: TimeInterval {
        end_date.timeIntervalSince(start_date)
    }
}

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}
