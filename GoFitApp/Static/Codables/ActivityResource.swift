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
    var route: [Coordinates]?
    
    var duration: TimeInterval? {
        Helpers.getDateFromString(from: end_date).timeIntervalSince(Helpers.getDateFromString(from: start_date))
    }

    public func getJSON() -> [String: Any] {
        [
            "start_date": start_date as Any,
            "end_date": end_date as Any,
            "calories": calories as Any,
            "name": name as Any,
            "traveled_distance": traveled_distance as Any,
            "locations": getList() as Any
        ]
    }
    
    private func getList() -> [[Double]] {
        var list: [[Double]] = []
        
        if let route = route {
            for coordinates in route {
                list.append(coordinates.getList())
            }
        }
        
        return list
    }
}

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
    
    public func getList() -> [Double] {
        return [latitude, longitude]
    }
}
