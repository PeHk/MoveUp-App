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
        completion(.doNotRetry)
        
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
                
            } else {
                completion(.doNotRetry)
            }
        }
    }
    
//    private func refreshWithCredentials() -> AnyPublisher<DataResponse<UserResource, NetworkError>, Never> {
//
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
