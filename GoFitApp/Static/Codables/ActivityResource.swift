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
    let sport_id: Int64
    var traveled_distance: Double?
    var elevation_gain: Double?
    var locations: [[Double]]?
    var external: Bool?
    
    var duration: TimeInterval? {
        Helpers.getDateFromString(from: end_date).timeIntervalSince(Helpers.getDateFromString(from: start_date))
    }
    
    var pace: TimeInterval? {
        if let duration = duration, let traveled_distance = traveled_distance {
            let pace = 1 / (((traveled_distance * 1000) / duration) / 1000)
            return pace
        }
       
        return nil
    }

    public func getJSON() -> [String: Any] {
        var dict = [
            "start_date": start_date as Any,
            "end_date": end_date as Any,
            "calories": calories as Any,
            "name": name as Any,
            "sport_id": sport_id as Any
        ]
        
        if locations != nil {
            dict["locations"] = Helpers.reduceLocations(locations: locations!) as Any
        }

        if traveled_distance != nil {
            dict["traveled_distance"] = traveled_distance! as Any
        }

        if elevation_gain != nil {
            dict["elevation_gain"] = elevation_gain! as Any
        }

        return dict
    }
}

struct LastUpdatedActivityResource: Codable {
    let last_activity_update: String
}
