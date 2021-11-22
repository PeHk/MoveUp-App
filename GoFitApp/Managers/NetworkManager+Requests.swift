//
//  NetworkManager+Requests.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation
import Alamofire
import Combine

extension NetworkManager {
    
    func authorization<T: Decodable>(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        headers: HTTPHeaders? = nil,
        interceptor: RequestInterceptor? = nil,
        withInterceptor: Bool = false
    ) -> Future<T, ServerError> {
        return Future({ promise in
            AF.request(
                url,
                method: method,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers,
                interceptor: withInterceptor ? self : nil
            )
            .validate(statusCode: [200, 401])
            .responseDecodable(completionHandler: { (response: DataResponse<T, AFError>) in
//                print(response.debugDescription)
                switch response.result {
                case .success(let value):
//                    self.saveCookies(cookies: HTTPCookieStorage.shared.cookies)
                    promise(.success(value))
                case .failure(let error):
                    promise(.failure(self.createError(response: response.response, AFerror: error, data: response.data)))
                }
            })
        })
    }

    func request<T: Decodable>(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        headers: HTTPHeaders? = nil,
        interceptor: RequestInterceptor? = nil,
        withInterceptor: Bool = true
    ) -> Future<T, ServerError> {
        return Future({ promise in
            AF.request(
                url,
                method: method,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers,
                interceptor: withInterceptor ? self : nil
            )
            .validate(statusCode: [200, 201, 204, 400, 401])
            .responseDecodable(completionHandler: { (response: DataResponse<T, AFError>) in
                switch response.result {
                case .success(let value):
                    promise(.success(value))
                case .failure(let error):
                    promise(.failure(self.createError(response: response.response, AFerror: error, data: response.data)))
                }
            })
        })
    }
}
