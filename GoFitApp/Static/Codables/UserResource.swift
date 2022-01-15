//
//  User.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 25/11/2021.
//

import Foundation
import SwiftyBase64

struct UserResource: Codable {
    var id: Int64?
    var email: String?
    var password: String?
    var name: String?
    var admin: Bool?
    var registered_at: String?
    var date_of_birth: String?
    var gender: String?
    var bio_data: [BioDataResource]?
    var favourite_sports: [SportResource]?
    var sports: [SportResource]?
    var activities: [ActivityResource]?
    
    init(name: String, email: String, password: String) {
        self.email = email
        self.name = name
        self.password = SwiftyBase64.EncodeString([UInt8](password.utf8))
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = SwiftyBase64.EncodeString([UInt8](password.utf8))
    }
    
    init(name: String) {
        self.name = name
    }
    
    public func registrationJSON() -> [String: Any] {
        [
            "email": email as Any,
            "name": name as Any,
            "password": password as Any
        ]
    }
    
    public func loginJSON() -> [String: Any] {
        [
            "email": email as Any,
            "password": password as Any
        ]
    }
    
    public func nameJSON() -> [String: Any] {
        [
            "name": name as Any
        ]
    }
    
    public func getDecodedPassword() -> String? {
        self.password?.base64Decoded
    }
}
