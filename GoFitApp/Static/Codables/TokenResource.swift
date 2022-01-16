//
//  TokenResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 16/01/2022.
//

import Foundation

struct TokenResource: Codable {
    let uuid: String
    
    public func tokenJSON() -> [String: Any] {
        [
            "uuid": uuid as Any
        ]
    }
    
}
