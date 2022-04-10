//
//  Helpers.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 25/11/2021.
//

import Foundation
import CoreLocation

struct Validators {
    static func textFieldValidatorEmail(_ string: String) -> Bool {
        if string.count > 100 {
            return false
        }
        let emailFormat = "^[a-z0-9]+[\\._-]?[a-z0-9]+[@]\\w+[.]\\w{2,3}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }
}

enum WorkoutType: String {
    case outdoor = "Outdoor"
    case indoor = "Indoor"
    case both = "Both"
}

class Helpers {
    static func getDateFromStringWithout(from string: String) -> Date {
        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            return dateFormatter
        }()
        
        return dateFormatter.date(from: string) ?? Date()
    }
    
    static func getDateFromString(from string: String) -> Date {
        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return dateFormatter
        }()
        
        return dateFormatter.date(from: string) ?? Date()
    }
    
    static func formatDate(from date: Date) -> String  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
    
    static func printDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        
        return dateFormatter.string(from: date)
    }
    
    static func formatTimeInterval(time: TimeInterval) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: time)
    }
    
    static func getTimeFromDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
    
    static func getTimeFromSeconds(from interval: Double) -> String {

        let minutes = Int(interval / 60)
        let seconds = Int(interval) - (Int(interval / 60) * 60)

        return String(format: "%02d\'%02d\"", minutes, seconds)
    }
    
    static func getTimeAndDateFormatted(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, dd/MM/YYYY"
        
        return dateFormatter.string(from: date)
    }
    
    static func getCoreLocationObjects(from activity: Activity) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        if let locations = activity.locations {
            if let array = getArrayFromData(data: locations) {
                for location in array {
                    if location.count == 2 {
                        let coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
                        coordinates.append(coordinate)
                    }
                    
                }
            }
        }
        
        return coordinates
    }
    
    static func getArrayFromData(data: Data) -> [[Double]]? {
        do {
            let array = try PropertyListDecoder.init().decode([[Double]].self, from: data)
            return array
        } catch let error as NSError{
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    static func getDataFromArray(array: [[Double]]) -> Data? {
        do {
            let data = try PropertyListEncoder.init().encode(array)
            return data
        } catch let error as NSError{
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func getJSONFromActivityResourceArray(array: [ActivityResource]) -> [String: Any] {
        var jsonArray: [[String: Any]] = []
        
        for activity in array {
            jsonArray.append(activity.getJSON())
        }
        
        return [ "activities": jsonArray as Any]
    }
    
    static func reduceLocations(locations: [[Double]]) -> [[Double]] {
        let maximumCount: Int = 150
        
        guard locations.count > maximumCount else { return locations }
        
        let coeficient: Int = locations.count / maximumCount
        
        return locations.enumerated().compactMap { index, element in index % coeficient != 0 ? nil : element }
    }
    
    public static func getWeatherCoef(weatherID: Int) -> (Float, WorkoutType) {
        switch weatherID {
        case 800: // Clear
            return (1.1, .outdoor)
        case 801...899: // Cloudy
            return (1.05, .both)
        case 700...799: // Atmosphere
            return (1.05, .both)
        case 600...699: // Snow codes
            return (0.97, .indoor)
        case 500...599: // Rain codes
            return (0.96, .indoor)
        case 300...399: // Drizzle codes
            return (0.97, .indoor)
        case 200...299: // Storm codes
            return (0.95, .indoor)
        default:
            return (1, .both)
        }
    }
}
