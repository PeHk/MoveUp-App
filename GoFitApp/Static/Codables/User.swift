//
//  User.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 25/11/2021.
//

import Foundation

struct User: Codable {
    let email: String
    let admin: Bool
    let id: Int64
    let name: String
    let registered_at: String
}
