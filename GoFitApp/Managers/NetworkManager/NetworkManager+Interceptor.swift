//
//  NetworkManager+Interceptor.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation
import Alamofire
import Combine

extension NetworkManager: RequestInterceptor {
    
    // MARK: Adapt
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let request = urlRequest
        
        setupCookies()
        
        completion(.success(request))
    }
    
    // MARK: Retry
    func retry(_ request: Request, for session: Session, dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {

        if request.retryCount < retryLimit {
            self.refreshToken()
                .sink { dataResponse in
                    if let _ = dataResponse.error {
                        completion(.doNotRetry)
                    } else {
                        self.saveTokenFromCookies(cookies: HTTPCookieStorage.shared.cookies)
                        completion(.retry)
                    }
                }
                .store(in: &self.subscription)
        } else {
            if !withCredentials {
                self.refreshWithCredentials()
                    .sink { result in
                        if case .failure(_) = result {
                            self.withCredentials = true
                            self.logoutManager.logout(true)
                            completion(.doNotRetry)
                        }
                    } receiveValue: { _ in
                        self.withCredentials = true
                        self.retryLimit = self.retryLimit + 1
                        completion(.retry)
                    }
                    .store(in: &subscription)
            } else {
                completion(.doNotRetry)
            }
        }
    }
    
    // MARK: Refresh token with credentials
    private func refreshWithCredentials() -> Future<UserResource, NetworkError> {
        let (email, password) = self.credentialsManager.getEncodedCredentials() ?? ("", "")
        let form = UserResource(email: email, password: password)
        
        let loginPublisher: AnyPublisher<DataResponse<UserResource, NetworkError>, Never> = self.request(
            Endpoint.login.url,
            method: .post,
            parameters: form.loginJSON(),
            withInterceptor: false
        )
        
        return Future { promise in
            loginPublisher
                .sink { dataResponse in
                    if let error = dataResponse.error {
                        promise(.failure(error))
                    } else {
                        self.saveTokenFromCookies(cookies: HTTPCookieStorage.shared.cookies)
                        promise(.success(dataResponse.value!))
                    }
                }
                .store(in: &self.subscription)
        }
    }

    // MARK: Refresh token
    private func refreshToken() -> AnyPublisher<DataResponse<UserResource, NetworkError>, Never> {
        let refreshRequest: AnyPublisher<DataResponse<UserResource, NetworkError>, Never> = self.request(
            Endpoint.refresh.url,
            method: .post,
            parameters: [:]
        )
        
        return refreshRequest
                .eraseToAnyPublisher()
    }
}
