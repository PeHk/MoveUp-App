//
//  Double+Extension.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 26/03/2022.
//

import Foundation

extension Double {
    func toInt() -> Int? {
        if self >= Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}

