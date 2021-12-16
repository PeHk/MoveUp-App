//
//  UIAlertViewController+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 16/12/2021.
//

import Foundation
import UIKit

extension UIAlertController {

    func isValidInput(_ name: String) -> Bool {
        return Int(name) ?? 101 > 100 && name.count >= 3  && !(name.isEmpty) && name.allSatisfy { $0.isNumber }
    }

    @objc func textDidChangeInAlert() {
        if let name = textFields?[0].text,
            let action = actions.last {
            action.isEnabled = isValidInput(name)
        }
    }
}
