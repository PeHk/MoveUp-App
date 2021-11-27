//
//  BioData.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 27/11/2021.
//

import Foundation

struct BioData: Codable {
    let weight: Float?
    let height: Float?
    let date_of_birth: String?
    let gender: String?
    let type: Int?
    let activity_minutes: Int?
    let bmi: Float?
}
