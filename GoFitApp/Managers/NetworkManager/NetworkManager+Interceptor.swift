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
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let request = urlRequest
        
        setupCookies()
        
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {

        if request.retryCount < retryLimit {
            self.refreshToken()
                .sink { dataResponse in
                    if let _ = dataResponse.error {
                        completion(.doNotRetry)
                    } else {
                        print("Token refreshed!")
                        self.saveTokenFromCookies(cookies: HTTPCookieStorage.shared.cookies)
                        completion(.retry)
                    }
                }
                .store(in: &self.subscription)
        } else {
            if !withCredentials {
//                self.refreshWithCredentials()
//                    .sink { result in
//                        if case .failure(_) = result {
//                            self.withCredentials = true
//                            self.logoutManager.logout(true)
//                            completion(.doNotRetry)
//                        }
//                    } receiveValue: { _ in
//                        self.withCredentials = true
//                        self.retryLimit = self.retryLimit + 1
//                        completion(.retry)
//                    }
//                    .store(in: &subscription)
            } else {
                completion(.doNotRetry)
            }
        }
    }
    
//    private func refreshWithCredentials() -> Future<UserResource, NetworkError> {
//        if let (email, password) = self.credentialsManager.getEncodedCredentials() {
//            let userResource = UserResource(email: email, password: password)
//            return self.loginManager.login(withForm: userResource)
//        } else {
//            return Future { promise in
//                promise(.failure(.init(initialError: nil, backendError: nil, nil)))
//            }
//        }
//    }

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
