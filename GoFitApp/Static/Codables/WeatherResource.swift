//
//  WeatherResource.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 02/04/2022.
//

import Foundation

struct WeatherResource: Codable {
    let lat: Float
    let lon: Float
    let timezone: String
    let timezone_offset: TimeInterval
    let hourly: [HourlyResource]
}

struct HourlyWeatherResource: Codable {
    let id: Int
    let main: String
}

struct HourlyResource: Codable {
    let dt: TimeInterval
    let temp: Float?
    let feels_like: Float?
    let visibility: Float?
    let wind_speed: Float?
    let weather: [HourlyWeatherResource]
}
