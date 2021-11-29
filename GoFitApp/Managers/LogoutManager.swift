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
    
    private var subscription = Set<AnyCancellable>()
    
    public var logoutCompleted = PassthroughSubject<Bool?, Never>()
    
    init(_ dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        self.userManager = dependencyContainer.userManager
        self.credentialsManager = dependencyContainer.credentialsManager
    }
    
    public func logout(_ fromInterceptor: Bool? = nil) {
        if credentialsManager.removeCredentials() {
            self.userManager.deleteUser()
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    ()
                } receiveValue: { _ in
                    self.logoutCompleted.send(fromInterceptor)
                }
                .store(in: &subscription)
        }
    }
}
