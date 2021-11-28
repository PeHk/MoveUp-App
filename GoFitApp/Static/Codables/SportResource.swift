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
    let calories_per_hour: Int64
    let created_at: String
}
