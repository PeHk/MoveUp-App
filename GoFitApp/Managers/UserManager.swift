//
//  UserManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 27/11/2021.
//

import Foundation
import Combine
import CoreData

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
                user.registered_at =  self.coreDataStore.dateFormatter.date(from: newUser.registered_at)
            }
            return coreDataStore
                .publicher(save: action)
                .eraseToAnyPublisher()
    }
    
    func getUser() -> AnyPublisher<CoreDataFetchResultsPublisher<User>.Output, NSError> {
        let request = NSFetchRequest<User>(entityName: User.entityName)
        
        return coreDataStore
            .publicher(fetch: request)
            .eraseToAnyPublisher()
    }
    
    func deleteUser() -> AnyPublisher<CoreDataDeleteModelPublisher.Output, NSError> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: User.entityName)
        request.predicate = NSPredicate(format: "email != nil")
        
        return coreDataStore
            .publicher(delete: request)
            .eraseToAnyPublisher()
    }
    
    func saveBioData(data: BioDataResource)-> AnyPublisher<CoreDataSaveModelPublisher.Output, NSError> {
        let action: Action = {
            let bioData: BioData = self.coreDataStore.createEntity()
            bioData.activity_minutes = data.activity_minutes ?? 0
            bioData.weight = data.weight ?? 0
            bioData.height = data.height ?? 0
            bioData.bmi = data.bmi ?? 0
        }
        return coreDataStore
            .publicher(save: action)
            .eraseToAnyPublisher()
    }
    
}
