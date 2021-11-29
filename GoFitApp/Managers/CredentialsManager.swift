//
//  CredentialsManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation
import Alamofire
import GoodCache

class CredentialsManager {
    
    let dependencyContainer: DependencyContainer
    
    init(_ dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
   
    let keychain = KeychainWrapper(serviceName: Constants.serviceName)
    
    func saveCredentials(email: String, password: String) {
        keychain.set(email, forKey: Constants.usernameKey)
        keychain.set(password, forKey: Constants.passwordKey)
        dependencyContainer.userDefaultsManager.setLoggedIn()
    }
    
    func getCredentials() -> Credentials? {
        if let username = keychain.string(forKey: Constants.usernameKey), let password = keychain.string(forKey: Constants.passwordKey) {
            return Credentials(email: username, password: password)
        } else {
            return nil
        }
    }
    
    func getEncodedCredentials() -> (email: String, password: String)? {
        if let username = keychain.string(forKey: Constants.usernameKey), let password = keychain.string(forKey: Constants.passwordKey) {
            return (username, password)
        } else {
            return nil
        }
    }
    
    func removeCredentials() -> Bool {
        dependencyContainer.userDefaultsManager.setLoggedOut()
        return keychain.removeAllKeys()
    }
}
