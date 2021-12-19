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
    
    // MARK: Variables
    fileprivate let coreDataStore: CoreDataStore
    fileprivate var subscription = Set<AnyCancellable>()
    
    public var currentUser = CurrentValueSubject<User?, Never>(nil)
    
    // MARK: Init
    init(_ dependencyContainer: DependencyContainer) {
        self.coreDataStore = dependencyContainer.coreDataStore
        self.fetchCurrentUser()
    }
    
    ///Function will notify all the controllers about new user
    /// - Warning: Current user is optional value
    public func fetchCurrentUser() {
        self.getUser()
            .sink { completion in
                return
            } receiveValue: { users in
                self.currentUser.send(users.first)
            }
            .store(in: &subscription)
    }
    
    // MARK: Save new user
    func saveUser(newUser: UserResource) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
            let action: Action = {
                let user: User = self.coreDataStore.createEntity()
                user.id = newUser.id ?? 0
                user.email = newUser.email
                user.admin = newUser.admin ?? false
                user.name = newUser.name
                user.registered_at =  self.coreDataStore.dateFormatter.date(from: newUser.registered_at ?? "")
            }
            return coreDataStore
                .publicher(save: action)
                .mapError({ error in
                .init(initialError: nil, backendError: nil, error)
                })
                .eraseToAnyPublisher()
    }
    
    // MARK: Get user
    public func getUser() -> AnyPublisher<CoreDataFetchResultsPublisher<User>.Output, NetworkError> {
        let request = NSFetchRequest<User>(entityName: User.entityName)
        
        return coreDataStore
            .publicher(fetch: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Delete user
    public func deleteUser() -> AnyPublisher<CoreDataDeleteModelPublisher.Output, NetworkError> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: User.entityName)
        request.predicate = NSPredicate(format: "email != nil")
        
        return coreDataStore
            .publicher(delete: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Save bio data after registration
    public func saveBioDataAfterRegistration(data: UserResource, user: User) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        
        let bioDataArray = data.bio_data?.first
        
        let bioData: BioData = self.coreDataStore.createEntity()
        bioData.activity_minutes = bioDataArray?.activity_minutes ?? 0
        bioData.weight = bioDataArray?.weight ?? 0
        bioData.height = bioDataArray?.height ?? 0
        bioData.bmi = bioDataArray?.bmi ?? 0
        
        let action: Action = {
            user.bio_data = user.bio_data?.adding(bioData) as NSSet?
            user.gender = data.gender
            user.date_of_birth = self.coreDataStore.dateFormatter.date(from: data.date_of_birth ?? "")
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Save bio data
    public func saveBioData(data: BioDataResource, user: User) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        
        let bioData: BioData = self.coreDataStore.createEntity()
        bioData.activity_minutes = data.activity_minutes ?? 0
        bioData.weight = data.weight ?? 0
        bioData.height = data.height ?? 0
        bioData.bmi = data.bmi ?? 0
        
        let action: Action = {
            user.bio_data = user.bio_data?.adding(bioData) as NSSet?
        }
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Save user with data
    public func saveUserWithData(newUser: UserResource) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        
        var bioDataArray: [BioData] = []
        
        if let bio_data = newUser.bio_data {
            for data in bio_data {
                let bioData: BioData = self.coreDataStore.createEntity()
                bioData.activity_minutes = data.activity_minutes ?? 0
                bioData.weight = data.weight ?? 0
                bioData.height = data.height ?? 0
                bioData.bmi = data.bmi ?? 0
                
                bioDataArray.append(bioData)
            }
        }

        let action: Action = {
            let user: User = self.coreDataStore.createEntity()
            user.id = newUser.id ?? 0
            user.email = newUser.email
            user.admin = newUser.admin ?? false
            user.name = newUser.name
            user.gender = newUser.gender
            user.date_of_birth = self.coreDataStore.dateFormatter.date(from: newUser.date_of_birth ?? "")
            user.registered_at = self.coreDataStore.dateFormatter.date(from: newUser.registered_at ?? "")
            
            user.bio_data = NSSet(array: bioDataArray)
        }
    
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
}
