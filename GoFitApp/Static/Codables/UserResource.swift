//
//  User.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 25/11/2021.
//

import Foundation

struct UserResource: Codable {
    let id: Int64
    let email: String
    let name: String
    let admin: Bool
    let registered_at: String
}
