//
//  SecondaryButton.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import Foundation
import UIKit

@IBDesignable class SecondaryButton: UIButton {
    
//    @IBInspectable var cornerRadius: CGFloat = 25
    @IBInspectable var backgroundColorDisabled: UIColor = UIColor.lightGray
    @IBInspectable var backgroundColorEnabled: UIColor = .clear
    
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
        self.setTitleColor(Asset.primary.color, for: .normal)
        self.titleLabel?.font = UIFont(font: FontFamily.Roboto.bold, size: 17)
        
        self.layer.borderWidth = 4
        self.layer.borderColor = Asset.primary.color.cgColor
        
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
