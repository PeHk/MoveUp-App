//
//  ServerError.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation
import Alamofire

struct NetworkError: Error {
    let initialError: AFError?
    let backendError: BackendError?
    let coreDataError: NSError?
    
    init(initialError: AFError?, backendError: BackendError?, _ coreDataError: NSError? = nil) {
        self.initialError = initialError
        self.backendError = backendError
        self.coreDataError = coreDataError
    }
}

struct BackendError: Codable, Error {
    var message: String
}
