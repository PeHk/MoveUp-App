//
//  Endpoint.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation

struct Endpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
}

extension Endpoint {
    var url: String {
        var components = URLComponents()
        
// MARK: DEVELOPMENT CONFIG
        components.scheme = "https"
        components.host = "pehk.rocks"
        components.path = "/backend_develop/" + path
        
// MARK: PRODUCTION CONFIG
//        components.scheme = "https"
//        components.host = "pehk.rocks"
//        components.path = "/backend_production/" + path

// MARK: LOCAL CONFIG
//        components.scheme = "http"
//        components.host = "192.168.0.104"
//        components.port = 5000
//        components.path = "/" + path
//
        components.queryItems = queryItems

        guard let url = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }

        return url.absoluteString
    }
}

extension Endpoint {
    static var login: Self {
        Endpoint(path: "api/login")
    }
    
    static var logout: Self {
        Endpoint(path: "api/logout")
    }
    
    static var refresh: Self {
        Endpoint(path: "auth/refresh")
    }
    
    static var test: Self {
        Endpoint(path: "api/test")
    }
    
    static var registration: Self {
        Endpoint(path: "api/register")
    }
}
