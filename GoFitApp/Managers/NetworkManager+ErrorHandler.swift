//
//  NetworkManager+ErrorHandler.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation
import Alamofire

struct ErrorMessage: Error, Decodable {
    let message: String
}

extension NetworkManager {
    func createError(response: HTTPURLResponse?, AFerror: AFError?, data: Data?) -> ServerError {

        guard let serverResponse = response else {
            return .init(message: "Unknown error", code: .unknown, args: [AFerror?.localizedDescription ?? ""])
        }
        
        guard let serverData = data else {
            return .init(message: "Empty response", code: .emptyResponse, args: [AFerror?.localizedDescription ?? ""])
        }
        
        let responseCode: ServerErrorCodes
        
        if let code = ServerErrorCodes(rawValue: serverResponse.statusCode) {
            responseCode = code
        } else {
            responseCode = .unknown
        }
        
        do {
            let serverMessage = try JSONDecoder().decode(ErrorMessage.self, from: serverData)
            
            return .init(message: serverMessage.message, code: responseCode, args: [])
            
        } catch (let error) {
            return .init(message: "Body not serializable", code: .unserialized, args: [String(data: serverData, encoding: .utf8) ?? "", error.localizedDescription])
        }
    }
}
