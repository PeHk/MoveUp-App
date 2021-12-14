//
//  BioData.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 27/11/2021.
//

import Foundation

struct BioDataResource: Codable {
    let weight: Float?
    let height: Float?
    let date_of_birth: String?
    let gender: String?
    let activity_minutes: Int64?
    let bmi: Float?
    
    init(weight: Float?, height: Float?, activity_minutes: Int64?, bmi: Float?) {
        self.weight = weight
        self.height = height
        self.activity_minutes = activity_minutes
        self.bmi = bmi
        self.gender = nil
        self.date_of_birth = nil
    }
    
    init(weight: Float?, height: Float?, activity_minutes: Int64?, bmi: Float?, date_of_birth: String?, gender: String?) {
        self.weight = weight
        self.height = height
        self.activity_minutes = activity_minutes
        self.bmi = bmi
        self.gender = gender
        self.date_of_birth = date_of_birth
    }
}
