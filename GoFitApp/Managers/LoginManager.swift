//
//  LoginManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 29/11/2021.
//

import Foundation
import Combine
import Alamofire
import SwiftyBase64

class LoginManager {
    
    fileprivate let networkManager: NetworkManager
    fileprivate let credentialsManager: CredentialsManager
    
    fileprivate var subscription = Set<AnyCancellable>()
    
    init(_ dependencyContainer: DependencyContainer) {
        self.networkManager = dependencyContainer.networkManager
        self.credentialsManager = dependencyContainer.credentialsManager
    }
    
    public func login(email: String, password: String) -> Future<UserDataResource, NetworkError> {
        let loginPublisher: AnyPublisher<DataResponse<UserDataResource, NetworkError>, Never> = self.networkManager.request(
            Endpoint.login.url,
            method: .post,
            parameters: ["email": email, "password": SwiftyBase64.EncodeString([UInt8](password.utf8))],
            withInterceptor: false
        )
        
        return Future { promise in
            loginPublisher
                .sink { dataResponse in
                    if let error = dataResponse.error {
                        promise(.failure(error))
                    } else {
                        self.networkManager.saveTokenFromCookies(cookies: HTTPCookieStorage.shared.cookies)
                        self.credentialsManager.saveCredentials(email: email, password: password)
                        promise(.success(dataResponse.value!))
                    }
                }
                .store(in: &self.subscription)
        }
    }
    
}
