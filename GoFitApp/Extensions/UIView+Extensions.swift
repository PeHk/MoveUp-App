//
//  UIView+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 20/10/2021.
//

import Foundation
import UIKit

extension UIView {
    func addBottomBorder(color: UIColor = UIColor.red, margins: CGFloat = 0, borderLineSize: CGFloat = 1) {
            let border = UIView()
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(border)
            border.addConstraint(NSLayoutConstraint(item: border,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .height,
                                                    multiplier: 1, constant: borderLineSize))
            self.addConstraint(NSLayoutConstraint(item: border,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .bottom,
                                                  multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: border,
                                                  attribute: .leading,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .leading,
                                                  multiplier: 1, constant: margins))
            self.addConstraint(NSLayoutConstraint(item: border,
                                                  attribute: .trailing,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .trailing,
                                                  multiplier: 1, constant: margins))
        }
    
    func showLoadingView() {
        let blurLoader = LoadingView(frame: frame)
        self.addSubview(blurLoader)
    }
    
    func removeLoadingView() {
        for view in subviews {
            if view is LoadingView {
                view.removeFromSuperview()
            }
        }
    }
}
