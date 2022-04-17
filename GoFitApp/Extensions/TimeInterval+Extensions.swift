//
//  TimeInterval+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 02/04/2022.
//

import Foundation

extension TimeInterval {
    static func day() -> Double {
        86400
    }
    
    static func year() -> Double {
        31536000
    }
    
    static func hour() -> Double {
        3600
    }
    
    static func threeHours() -> Double {
        3600 * 3
    }
}
