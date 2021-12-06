//
//  NetworkManager+Requests.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation
import Alamofire
import Combine

extension NetworkManager: NetworkProtocol {
    
    public func request<T: Decodable>(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        headers: HTTPHeaders? = nil,
        interceptor: RequestInterceptor? = nil,
        withInterceptor: Bool = true
    ) -> AnyPublisher<DataResponse<T, NetworkError>, Never> {
        AF.request(
            url,
            method: method,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers,
            interceptor: withInterceptor ? self : nil)
            .validate()
            .publishDecodable(type: T.self)
            .map { response in
                response.mapError { error in
                    let backendError = response.data.flatMap { try? JSONDecoder().decode(BackendError.self, from: $0)}
                    return NetworkError(initialError: error, backendError: backendError)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
