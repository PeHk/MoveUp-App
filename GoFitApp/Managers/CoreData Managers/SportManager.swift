//
//  SportManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 14/12/2021.
//

import Foundation
import Combine
import CoreData

class SportManager {
    // MARK: Variables
    fileprivate let coreDataStore: CoreDataStore
    fileprivate var subscription = Set<AnyCancellable>()
    
    public var currentSports = CurrentValueSubject<[Sport], Never>([])
    
    // MARK: Init
    init(_ dependencyContainer: DependencyContainer) {
        self.coreDataStore = dependencyContainer.coreDataStore
        self.fetchCurrentSports()
    }
    
    ///Function will notify all the controllers about new sports
    /// - Warning: Sports is optional value
    public func fetchCurrentSports() {
        self.getSports()
            .sink { completion in
                return
            } receiveValue: { sports in
                self.currentSports.send(sports)
            }
            .store(in: &subscription)
    }
    
    // MARK: Get sports
    private func getSports() -> AnyPublisher<CoreDataFetchResultsPublisher<Sport>.Output, NetworkError> {
        let request = NSFetchRequest<Sport>(entityName: Sport.entityName)
        
        return coreDataStore
            .publicher(fetch: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Save sports
    /// Function will save all elements of [SportResource] to the CoreData
    public func saveSports(newSports: [SportResource]) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let action: Action = {
            for newSport in newSports {
                let sport: Sport = self.coreDataStore.createEntity()
                sport.name = newSport.name
                sport.id = newSport.id
                sport.met = newSport.met
                sport.healthKitType = newSport.health_kit_type
                sport.type = newSport.type
                sport.weather = newSport.weather
            }
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Update one sport
    public func updateOneSport(sportToUpdate: SportResource, currSport: Sport) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let action: Action = {
            currSport.name = sportToUpdate.name
            currSport.healthKitType = sportToUpdate.health_kit_type
            currSport.met = sportToUpdate.met
            currSport.type = sportToUpdate.type
            currSport.weather = sportToUpdate.weather
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    public func updateSports(sportsToUpdate: [SportResource]) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let sports = currentSports.value
        var action: Action = {}
        
        for sportToUpdate in sportsToUpdate {
            if let i = sports.firstIndex(where: { $0.id == sportToUpdate.id }) {

                action = {
                    sports[i].name = sportToUpdate.name
                    sports[i].met = sportToUpdate.met
                    sports[i].healthKitType = sportToUpdate.health_kit_type
                    sports[i].type = sportToUpdate.type
                    sports[i].weather = sportToUpdate.weather
                }
            } else {
                action = {
                    let sport: Sport = self.coreDataStore.createEntity()
                    sport.name = sportToUpdate.name
                    sport.id = sportToUpdate.id
                    sport.met = sportToUpdate.met
                    sport.healthKitType = sportToUpdate.health_kit_type
                    sport.type = sportToUpdate.type
                    sport.weather = sportToUpdate.weather
                }
            }
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Delete sports
    public func deleteSports() -> AnyPublisher<CoreDataDeleteModelPublisher.Output, NetworkError> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Sport.entityName)
        request.predicate = NSPredicate(format: "id != nil")
        
        self.currentSports.send([])
        
        return coreDataStore
            .publicher(delete: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Save favourite sports
    public func saveSportToUser(user: User, sports: [Sport]) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let action: Action = {
            user.favourite_sports = NSSet(array: sports)
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Save favourite sport to existing ones
    public func appendSportToUser(user: User, sport: Sport) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        
        let sports = user.favourite_sports?.adding(sport)
                
        let action: Action = {
            user.favourite_sports = sports as NSSet?
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
}
