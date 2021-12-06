//
//  NetworkProtocol.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 06/12/2021.
//

import Combine
import Alamofire

protocol NetworkProtocol {
    func request<T: Decodable>(
        _ url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        decoder: JSONDecoder,
        headers: HTTPHeaders?,
        interceptor: RequestInterceptor?,
        withInterceptor: Bool
    ) -> AnyPublisher<DataResponse<T, NetworkError>, Never>
}
