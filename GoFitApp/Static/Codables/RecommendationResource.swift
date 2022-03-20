//
//  RecommendationResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 20/03/2022.
//

import Foundation

struct RecommendationResource: Codable {
    var id: Int64
    var type: String
    var created_at: String
    var start_time: String?
    var end_time: String?
    var sport_id: Int64?
    var rating: Int64?
    var activity_id: Int64?
    var accepted_at: String?
    
    public func acceptedJSON() -> [String: Any] {
        [
            "id": id as Any,
            "rating": rating as Any
        ]
    }
}
