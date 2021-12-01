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
    
    func saveUser(newUser: UserResource) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NSError> {
            let action: Action = {
                let user: User = self.coreDataStore.createEntity()
                user.id = newUser.id
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
    
    public func saveBioDataAfterRegistration(data: FirstBioDataResource, user: User) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NSError> {
        
        let bioDataArray = data.bio_data.first
        
        let bioData: BioData = self.coreDataStore.createEntity()
        bioData.activity_minutes = bioDataArray?.activity_minutes ?? 0
        bioData.weight = bioDataArray?.weight ?? 0
        bioData.height = bioDataArray?.height ?? 0
        bioData.bmi = bioDataArray?.bmi ?? 0
        
        let action: Action = {
            user.bio_data = user.bio_data?.adding(bioData) as NSSet?
            user.gender = data.gender
            user.date_of_birth = self.coreDataStore.dateFormatter.date(from: data.date_of_birth)
        }
        
        return coreDataStore
            .publicher(save: action)
            .eraseToAnyPublisher()
    }
    
    public func saveBioData(data: BioDataResource, user: User) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NSError> {
        
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
            .eraseToAnyPublisher()
    }
    
    public func saveUserWithData(newUser: UserDataResource) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NSError> {
        
        var bioDataArray: [BioData] = []
    
        for data in newUser.bio_data {
            let bioData: BioData = self.coreDataStore.createEntity()
            bioData.activity_minutes = data.activity_minutes ?? 0
            bioData.weight = data.weight ?? 0
            bioData.height = data.height ?? 0
            bioData.bmi = data.bmi ?? 0
            
            bioDataArray.append(bioData)
        }
        
        let action: Action = {
            let user: User = self.coreDataStore.createEntity()
            user.id = newUser.id
            user.email = newUser.email
            user.admin = newUser.admin
            user.name = newUser.name
            user.gender = newUser.gender
            user.date_of_birth = self.coreDataStore.dateFormatter.date(from: newUser.date_of_birth)
            user.registered_at = self.coreDataStore.dateFormatter.date(from: newUser.registered_at)
            
            user.bio_data = NSSet(array: bioDataArray)
        }
    
        return coreDataStore
            .publicher(save: action)
            .eraseToAnyPublisher()
    }
    
}
