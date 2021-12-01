//
//  FirstBioDataResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 01/12/2021.
//

import Foundation

struct FirstBioDataResource: Codable {
    let date_of_birth: String
    let gender: String
    let bio_data: [BioDataResource]
}
