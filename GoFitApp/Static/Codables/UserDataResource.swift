//
//  UserDataResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 29/11/2021.
//

import Foundation

struct UserDataResource: Codable {
    let email: String
    let name: String
    let bio_data: [BioDataResource]
}
