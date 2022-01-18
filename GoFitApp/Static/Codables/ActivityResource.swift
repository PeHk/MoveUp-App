//
//  ActivityResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 09/01/2022.
//

import Foundation
import CoreLocation

struct ActivityResource: Codable {
    let start_date: String
    let end_date: String
    let calories: Double
    let name: String
    let traveled_distance: Double
    var locations: [[Double]]?
    
    var duration: TimeInterval? {
        Helpers.getDateFromString(from: end_date).timeIntervalSince(Helpers.getDateFromString(from: start_date))
    }
    
    var pace: TimeInterval? {
        if let duration = duration {
            let pace = 1 / (((traveled_distance * 1000) / duration) / 1000)
            return pace
        }
       
        return nil
    }

    public func getJSON() -> [String: Any] {
        [
            "start_date": start_date as Any,
            "end_date": end_date as Any,
            "calories": calories as Any,
            "name": name as Any,
            "traveled_distance": traveled_distance as Any,
            "locations": locations as Any
        ]
    }
}
