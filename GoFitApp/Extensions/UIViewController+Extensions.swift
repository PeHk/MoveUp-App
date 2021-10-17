//
//  UIViewController+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import UIKit

extension UIViewController {
    
    static func instantiate<T>() -> T {
        let storyboard = UIStoryboard(name: "\(T.self)", bundle: .main)
        let controller = storyboard.instantiateViewController(identifier: "\(T.self)") as! T
        return controller
    }
}
