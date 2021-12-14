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
    
    init(id: Int64, email: String, name: String, admin: Bool, registered_at: String, date_of_birth: String, gender: String, bio_data: [BioDataResource]) {
        self.id = id
        self.email = email
        self.name = name
        self.admin = admin
        self.registered_at = registered_at
        self.date_of_birth = date_of_birth
        self.gender = gender
        self.bio_data = bio_data
    }
}
