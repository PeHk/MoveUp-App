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
    fileprivate let sportManager: SportManager
    fileprivate var subscription = Set<AnyCancellable>()
    
    public var currentUser = CurrentValueSubject<User?, Never>(nil)
    
    // MARK: Init
    init(_ dependencyContainer: DependencyContainer) {
        self.coreDataStore = dependencyContainer.coreDataStore
        self.sportManager = dependencyContainer.sportManager
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
    private func getUser() -> AnyPublisher<CoreDataFetchResultsPublisher<User>.Output, NetworkError> {
        let request = NSFetchRequest<User>(entityName: User.entityName)
        
        return coreDataStore
            .publicher(fetch: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Save bio data after registration
    ///Function will save BioDataResource with additional information (gender, date of birth)
    ///as BioData record to
    ///the current logged user
    public func saveBioDataAfterRegistration(data: UserResource) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let user = self.currentUser.value
        var action: Action = {}
        if let bioData = data.bio_data?.first {
            action = {
                user?.bio_data = user?.bio_data?.adding(self.getBioDataObject(data: bioData)) as NSSet?
                user?.gender = data.gender
                user?.date_of_birth = self.coreDataStore.dateFormatter.date(from: data.date_of_birth ?? "")
            }
        }

        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Save bio data
    ///Function will save BioDataResource as BioData record to
    ///the current logged user
    public func saveBioData(data: BioDataResource) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let user = self.currentUser.value
        
        let action: Action = {
            user?.bio_data = user?.bio_data?.adding(self.getBioDataObject(data: data)) as NSSet?
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Save user with BioData
    ///Function will save UserResource with nested BioDataResource
    ///as User with BioData records
    public func saveUserWithBioData(newUser: UserResource) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        
        let action: Action = {
            let user: User = self.getUserObject(data: newUser)
            user.bio_data = NSSet(array: self.getBioDataArray(bioData: newUser.bio_data ?? []))
        }
    
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Update favourite sports
    ///Function will save [SportResource] to the favourite sports of current logged user
    ///- Warning: Function will create new Sport entity if there is no Sport available
    public func updateUserFavouriteSports(sports: [SportResource]) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let action: Action = {
            var favouriteSportsArray: [Sport] = []
            let actualSports = self.sportManager.currentSports.value
            
            for data in sports {
                if let actualSport = actualSports.first(where: { $0.id == data.id }) {
                    favouriteSportsArray.append(actualSport)
                } else {
                    let sport: Sport = self.coreDataStore.createEntity()
                    sport.id = data.id
                    sport.name = data.name
                    sport.met = data.met
                    
                    favouriteSportsArray.append(sport)
                }
            }
            
            let user = self.currentUser.value
            user?.favourite_sports = NSSet(array: favouriteSportsArray)
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Update user name
    public func updateUserName(name: String) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError>  {
        let user = self.currentUser.value
        let action: Action = {
            user?.name = name
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Delete user
    public func deleteUser() -> AnyPublisher<CoreDataDeleteModelPublisher.Output, NetworkError> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: User.entityName)
        request.predicate = NSPredicate(format: "email != nil")
        
        self.currentUser.send(nil)
        
        return coreDataStore
            .publicher(delete: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
}

// MARK: Helping functions
extension UserManager {
    private func getBioDataArray(bioData: [BioDataResource]) -> [BioData] {
        guard bioData.count > 0 else { return [] }
        var array: [BioData] = []
        
        for data in bioData {
            let bioData: BioData = self.coreDataStore.createEntity()
            bioData.activity_minutes = data.activity_minutes ?? 0
            bioData.weight = data.weight ?? 0
            bioData.height = data.height ?? 0
            bioData.bmi = data.bmi ?? 0
            bioData.id = data.id ?? 0
            bioData.created_at = self.coreDataStore.dateFormatter.date(from: data.created_at ?? "")
            
            array.append(bioData)
        }
        
        return array
    }
    
    private func getBioDataObject(data: BioDataResource) -> BioData {
        let bioData: BioData = self.coreDataStore.createEntity()
        bioData.activity_minutes = data.activity_minutes ?? 0
        bioData.weight = data.weight ?? 0
        bioData.height = data.height ?? 0
        bioData.bmi = data.bmi ?? 0
        bioData.id = data.id ?? 0
        bioData.created_at = self.coreDataStore.dateFormatter.date(from: data.created_at ?? "")
        
        return bioData
    }
    
    private func getUserObject(data: UserResource) -> User {
        let user: User = self.coreDataStore.createEntity()
        user.id = data.id ?? 0
        user.email = data.email
        user.admin = data.admin ?? false
        user.name = data.name
        user.gender = data.gender
        user.date_of_birth = self.coreDataStore.dateFormatter.date(from: data.date_of_birth ?? "")
        user.registered_at = self.coreDataStore.dateFormatter.date(from: data.registered_at ?? "")
        
        return user
    }
}
