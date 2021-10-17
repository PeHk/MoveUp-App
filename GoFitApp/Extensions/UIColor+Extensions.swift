//
//  UIColor+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import Foundation
import UIKit

extension UIColor {
    class var primary: UIColor {
        return UIColor(named: "primary") ?? .black
    }
    
    class var secondary: UIColor {
        return UIColor(named: "secondary") ?? .orange
    }
    
    class var backgroundColor: UIColor {
        return UIColor(named: "backgroundColor") ?? .systemBackground
    }
}
