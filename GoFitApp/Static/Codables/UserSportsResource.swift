//
//  UserSportsResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 28/11/2021.
//

import Foundation

struct UserSportsResource: Codable {
    let id: Int64
    let name: String
    let email: String
    let favourite_sports: [SportResource]
}
