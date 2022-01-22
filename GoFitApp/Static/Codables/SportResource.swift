//
//  SportResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 28/11/2021.
//

import Foundation

struct SportResource: Codable {
    let id: Int64
    let name: String
    let met: Float
    let created_at: String
    let health_kit_type: String
    let type: String
}

struct SportUpdateResource: Codable {
    let date: Date
    
    public func getDateJSON() -> [String: Any] {
        [
            "last_update": Helpers.formatDate(from: self.date)
        ]
    }
}
