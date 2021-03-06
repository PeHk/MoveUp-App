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
    
    var weatherURL: String {
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/" + path
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
    
    static var registration: Self {
        Endpoint(path: "api/register")
    }
    
    static var genders: Self {
        Endpoint(path: "api/genders")
    }
    
    static var userDetails: Self {
        Endpoint(path: "api/user_details")
    }
    
    static var sports: Self {
        Endpoint(path: "api/sports")
    }
    
    static var apn: Self {
        Endpoint(path: "api/apn")
    }
    
    static var activity: Self {
        Endpoint(path: "api/activity")
    }
    
    static var activityStatus: Self {
        Endpoint(path: "api/last_activity")
    }
    
    static var recommendation: Self {
        Endpoint(path: "api/recommendations")
    }
    
    static func recommendationUpdate(id: Int64) -> Self {
        Endpoint(path: "api/recommendation/\(id)")
    }
    
    static var activityUpdate: Self {
        Endpoint(path: "api/recommendation")
    }
    
    static func weatherAPI(lat: Double, long: Double) -> Self {
        Endpoint(path: "data/2.5/onecall", queryItems: [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(long)),
            URLQueryItem(name: "appid", value: Constants.weatherKey),
            URLQueryItem(name: "exclude", value: "minutely,current,daily,alerts"),
            URLQueryItem(name: "units", value: "metric")
        ])
    }
}
