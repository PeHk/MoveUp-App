//
//  UserManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 27/11/2021.
//

import Foundation
import Combine

class UserManager {
    
    fileprivate let coreDataStore: CoreDataStore
    fileprivate var subscription = Set<AnyCancellable>()
    
    init(_ dependencyContainer: DependencyContainer) {
        self.coreDataStore = dependencyContainer.coreDataStore
    }
    
    func saveUser(newUser: UserResource) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NSError> {
            let action: Action = {
                let user: User = self.coreDataStore.createEntity()
                user.email = newUser.email
                user.admin = newUser.admin
                user.name = newUser.name
//                user.registered_at = newUser.registered_at
                
                
            }
            return coreDataStore
                .publicher(save: action)
                .eraseToAnyPublisher()
        }
        
        
}
