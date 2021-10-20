//
//  UINavigationController+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 19/10/2021.
//

import Foundation
import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    @objc func goBack(sender: Any?) {
        self.popViewController(animated: true)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
