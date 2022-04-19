//
//  LogoutManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 29/11/2021.
//

import Foundation
import Combine

class LogoutManager {
    
    fileprivate let dependencyContainer: DependencyContainer
    fileprivate let userManager: UserManager
    fileprivate let credentialsManager: CredentialsManager
    fileprivate let sportManager: SportManager
    fileprivate let activityManager: ActivityManager
    fileprivate let userDefaultsManager: UserDefaultsManager
    fileprivate let recommendationsManager: RecommendationsManager
    
    private var subscription = Set<AnyCancellable>()
    
    public var logoutCompleted = PassthroughSubject<Bool?, Never>()
    
    init(_ dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        self.userManager = dependencyContainer.userManager
        self.credentialsManager = dependencyContainer.credentialsManager
        self.sportManager = dependencyContainer.sportManager
        self.activityManager = dependencyContainer.activityManager
        self.userDefaultsManager = dependencyContainer.userDefaultsManager
        self.recommendationsManager = dependencyContainer.recommendationsManager
    }
    
    public func logout(_ fromInterceptor: Bool? = nil) {
        if credentialsManager.removeCredentials() {
            self.userManager.deleteUser()
                .zip(self.sportManager.deleteSports())
                .zip(self.activityManager.deleteActivities())
                .zip(self.recommendationsManager.deleteRecommendations())
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    ()
                } receiveValue: { _ in
                    self.userDefaultsManager.resetDefaults()
                    FeedbackManager.sendFeedbackNotification(.success)
                    self.logoutCompleted.send(fromInterceptor)
                }
                .store(in: &subscription)
        }
    }
}
