//
//  NetworkManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation
import Alamofire
import Combine

class NetworkManager {
    
    let dependencyContainer: DependencyContainer
    let credentialsManager: CredentialsManager
    let userDefaultsManager: UserDefaultsManager
    let logoutManager: LogoutManager
    let networkMonitor: NetworkMonitor
    
    var request: Alamofire.Request?
    var retryLimit = 3
    var withCredentials = false
    var subscription = Set<AnyCancellable>()
    let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, options: .removePreviousFile)
    
    
    init(_ dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        self.credentialsManager = dependencyContainer.credentialsManager
        self.userDefaultsManager = dependencyContainer.userDefaultsManager
        self.logoutManager = dependencyContainer.logoutManager
        self.networkMonitor = dependencyContainer.networkMonitor
    }
}
