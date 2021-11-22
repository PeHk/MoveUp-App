//
//  UserDefaultsManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation
import UIKit
import Combine

class UserDefaultsManager {
    
    let dependencyContainer: DependencyContainer
    let defaults = UserDefaults.standard
    let connectionPresetChanged = PassthroughSubject<Void, Never>()
    
    init(_ dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
    
    func isLoggedIn() -> Bool {
        defaults.bool(forKey: Constants.isLoggedIn)
    }
    
    func setLoggedIn() {
        defaults.setValue(true, forKey: Constants.isLoggedIn)
    }
    
    func setLoggedOut() {
        defaults.setValue(false, forKey: Constants.isLoggedIn)
    }
    
    func set(value: Any, forKey: String) {
        defaults.setValue(value, forKey: forKey)
    }
    
    func get(forKey: String) -> Any? {
        defaults.value(forKey: forKey)
    }
}
