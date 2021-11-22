//
//  ServerError.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation

struct ServerError: Error {
    var message: String
    var code: ServerErrorCodes
    let args: [String]?
}

enum ServerErrorCodes: Int {
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case conflict = 409
    case internalServerError = 500
    case unknown
    case emptyResponse
    case unserialized
    case userInput
    case coreData
}
