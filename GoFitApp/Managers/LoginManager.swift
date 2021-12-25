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
    
    public func login(withForm: UserResource) -> Future<UserResource, NetworkError> {
        
        let loginPublisher: AnyPublisher<DataResponse<UserResource, NetworkError>, Never> = self.networkManager.request(
            Endpoint.login.url,
            method: .post,
            parameters: withForm.loginJSON(),
            withInterceptor: false
        )
        
        return Future { promise in
            loginPublisher
                .sink { dataResponse in
                    if let error = dataResponse.error {
                        promise(.failure(error))
                    } else {
                        self.networkManager.saveTokenFromCookies(cookies: HTTPCookieStorage.shared.cookies)
                        self.credentialsManager.saveCredentials(email: withForm.email ?? "", password: withForm.getDecodedPassword() ?? "")
                        promise(.success(dataResponse.value!))
                    }
                }
                .store(in: &self.subscription)
        }
    }
    
}
