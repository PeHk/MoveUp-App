//
//  AlertManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 25/11/2021.
//

import Foundation
import UIKit

final class AlertManager {
    typealias AlertAction = () -> ()
    
    static func showAlert(title: String? = "Error occured" , message: String? = "Hmm, something seems to have gone wrong. Please try again.", over viewController: UIViewController) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(.ok)
        
        viewController.present(ac, animated: true)
    }
    
    static func showAlertWithConfirmation(title: String, message: String?, onConfirm: @escaping AlertAction, over viewController: UIViewController) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            onConfirm()
        }))

        viewController.present(ac, animated: true)
    }
}

extension UIAlertAction {
    static var ok: UIAlertAction {
        return UIAlertAction(title: "OK", style: .default, handler: nil)
    }
    
    static var cancel: UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    }
}
