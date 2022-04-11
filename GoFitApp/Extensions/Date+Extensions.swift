//
//  Date+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 09/04/2022.
//

import Foundation

extension Date {
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

        return localDate
    }
    
    func nearestHour() -> Date {
        return Date(timeIntervalSinceReferenceDate:
                        (timeIntervalSinceReferenceDate / 3600.0).rounded(.toNearestOrEven) * 3600.0)
    }
}
