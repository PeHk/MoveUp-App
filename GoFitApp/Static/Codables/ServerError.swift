//
//  ServerError.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation
import Alamofire

struct NetworkError: Error {
  let initialError: AFError
  let backendError: BackendError?
}

struct BackendError: Codable, Error {
    var message: String
}
