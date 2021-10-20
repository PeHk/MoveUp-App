//
//  UINavigationController+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 19/10/2021.
//

import Foundation
import UIKit

extension UINavigationController {
    @objc func goBack(sender: Any?) {
        self.popViewController(animated: true)
    }
}
