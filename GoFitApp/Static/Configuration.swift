//
//  Configuration.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 11/12/2021.
//

import Foundation
import UIKit

enum ControllerType {
    case activities
    case recommendations
    case noInternet
}

struct Configuration {
    
    var controllerType: ControllerType
    
    init(_ type: ControllerType) {
        self.controllerType = type
    }
    
    var titleString: NSAttributedString? {
        var text: String?
        var font: UIFont?
        var textColor: UIColor?
        
        switch controllerType {
        case .activities:
            text = "No activities yet"
            font = UIFont(font: FontFamily.Roboto.bold, size: 17)
            textColor = UIColor.label
        case .recommendations:
            text = "No recommendations for today"
            font = UIFont(font: FontFamily.Roboto.bold, size: 17)
            textColor = UIColor.label
        case .noInternet:
            text = "No internet connection"
            font = UIFont(font: FontFamily.Roboto.bold, size: 17)
            textColor = UIColor.label
        }
        
        if text == nil {
            return nil
        }
        var attributes: [NSAttributedString.Key: Any] = [:]
        if font != nil {
            attributes[NSAttributedString.Key.font] = font!
        }
        if textColor != nil {
            attributes[NSAttributedString.Key.foregroundColor] = textColor
        }
        return NSAttributedString.init(string: text!, attributes: attributes)
    }
    
    var detailString: NSAttributedString? {
        var text: String?
        var font: UIFont?
        var textColor: UIColor?
        
        switch controllerType {
        case .activities:
            text = "Your history will be visible here"
            font = UIFont(font: FontFamily.Roboto.regular, size: 15)
            textColor = UIColor.label
        case .recommendations:
            text = "Recommendations are generated automatically"
            font = UIFont(font: FontFamily.Roboto.regular, size: 15)
            textColor = UIColor.label
        case .noInternet:
            text = "Start with connecting your device to internet"
            font = UIFont(font: FontFamily.Roboto.regular, size: 15)
            textColor = UIColor.label
        }
        if text == nil {
            return nil
        }
        var attributes: [NSAttributedString.Key: Any] = [:]
        if font != nil {
            attributes[NSAttributedString.Key.font] = font!
        }
        if textColor != nil {
            attributes[NSAttributedString.Key.foregroundColor] = textColor
        }
        return NSAttributedString.init(string: text!, attributes: attributes)
    }
}
