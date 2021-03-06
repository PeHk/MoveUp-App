//
//  PrimaryButton.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import Foundation
import UIKit

@IBDesignable class PrimaryButton: UIButton {
    
//    @IBInspectable var cornerRadius: CGFloat = 25
    @IBInspectable var backgroundColorDisabled: UIColor = UIColor.lightGray
    @IBInspectable var backgroundColorEnabled: UIColor = Asset.primary.color
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }

    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = true
        
        if isEnabled {
            setEnabled()
        } else {
            setDisabled()
        }
    }
    
    func setUpView() {
        
        self.backgroundColor = backgroundColorEnabled
        self.setTitleColor(Asset.text.color, for: .normal)
        self.titleLabel?.font = UIFont(font: FontFamily.Roboto.bold, size: 17)
        
        if isEnabled {
            setEnabled()
        } else {
            setDisabled()
        }
    }
    
    func setEnabled() {
        backgroundColor = backgroundColorEnabled
        isEnabled = true
    }
    
    func setDisabled() {
        backgroundColor = backgroundColorDisabled
        isEnabled = false
    }
}

