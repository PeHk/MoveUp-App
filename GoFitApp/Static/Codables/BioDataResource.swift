//
//  BioData.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 27/11/2021.
//

import Foundation

struct BioDataResource: Codable {
    var weight: Float?
    var height: Float?
    var date_of_birth: String?
    var gender: String?
    var activity_minutes: Int64?
    var bmi: Float?
    
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
    
    init(activity_minutes: Int64) {
        self.activity_minutes = activity_minutes
    }
    
    public func getActivityMinutesUpdateJSON()-> [String: Any] {
        [
            "type": 3 as Any,
            "activity_minutes": activity_minutes as Any
        ]
    }
}
