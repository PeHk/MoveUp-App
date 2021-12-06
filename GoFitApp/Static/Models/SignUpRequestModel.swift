//
//  SignUpRequestModel.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 04/12/2021.
//

import Foundation
import SwiftyBase64

struct SignUpRequestModel {
    let email: String
    let name: String
    let password: String
    
    init(email: String, name: String, password: String) {
        self.email = email
        self.name = name
        self.password = SwiftyBase64.EncodeString([UInt8](password.utf8))
    }
    
    func getDecodedPassword() -> String? {
        self.password.base64Decoded
    }
    
    func toJSON() -> [String: Any] {
        [
            "email": email as Any,
            "name": name as Any,
            "password": password as Any
        ]
    }
}
