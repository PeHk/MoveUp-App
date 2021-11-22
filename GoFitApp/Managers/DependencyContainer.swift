//
//  DependencyContainer.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import Foundation

final class DependencyContainer {
    lazy var userDefaultsManager = UserDefaultsManager(self)
    lazy var credentialsManager = CredentialsManager(self)
    lazy var networkManager: NetworkManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json; charset=utf-8"]
        let networkManager = NetworkManager(self)
        return networkManager
    }()
//    lazy var logoutInterceptor = LogoutInterceptor(self)
//    lazy var feedbackManager = FeedbackManager()
//    lazy var coreDataStore = CoreDataStore(name: "CiceroniLens", in: .persistent)
}
