//
//  UserDataResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 29/11/2021.
//

import Foundation

struct UserDataResource: Codable {
    let id: Int64
    let email: String
    let name: String
    let admin: Bool
    let registered_at: String
    let date_of_birth: String
    let gender: String
    let bio_data: [BioDataResource]
}
