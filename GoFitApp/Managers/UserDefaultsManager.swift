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
    
    fileprivate let dependencyContainer: DependencyContainer
    fileprivate let defaults = UserDefaults.standard
    
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
    
    func resetDefaults() {
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    public func setNewBackupDate() {
        self.set(value: Date(), forKey: Constants.backupDate)
    }
    
    public func setNewSportBackupDate() {
        self.set(value: Date(), forKey: Constants.sportBackupDate)
    }
}
