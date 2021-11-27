//
//  RegistrationManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 25/11/2021.
//

import Foundation
import Combine
import Alamofire
import SwiftyBase64

class RegistrationManager {
    
    fileprivate let networkManager: NetworkManager
    fileprivate let credentialsManager: CredentialsManager
    
    fileprivate var subscription = Set<AnyCancellable>()
    
    init(_ dependencyContainer: DependencyContainer) {
        self.networkManager = dependencyContainer.networkManager
        self.credentialsManager = dependencyContainer.credentialsManager
    }
    
    func registration(email: String, username: String, password: String) -> Future<UserResource, NetworkError> {
        let registrationPublisher: AnyPublisher<DataResponse<UserResource, NetworkError>, Never> = self.networkManager.request(
            Endpoint.registration.url,
            method: .post,
            parameters: ["name": username, "password": SwiftyBase64.EncodeString([UInt8](password.utf8)), "email": email],
            withInterceptor: false
        )
        
        return Future { promise in
            registrationPublisher
                .sink { dataResponse in
                    if let error = dataResponse.error {
                        promise(.failure(error))
                    } else {
                        self.networkManager.saveTokenFromCookies(cookies: HTTPCookieStorage.shared.cookies)
                        promise(.success(dataResponse.value!))
                    }
                }
                .store(in: &self.subscription)
        }
    }
}
