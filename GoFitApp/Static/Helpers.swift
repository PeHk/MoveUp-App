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

class Helpers {
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
    
    static func getCoreLocationObjects(from activity: Activity) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        if let locations = activity.locations {
            if let array = getArrayFromData(data: locations) {
                for location in array {
                    let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    coordinates.append(coordinate)
                }
            }
        }
        
        return coordinates
    }
    
    static func getArrayFromData(data: Data) -> [Coordinates]? {
        do {
            let array = try PropertyListDecoder.init().decode([Coordinates].self, from: data)
            return array
        } catch let error as NSError{
            print(error.localizedDescription)
        }
        
        return nil
    }
}
