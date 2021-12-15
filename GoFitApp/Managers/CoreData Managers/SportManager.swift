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
    
    func getSports() -> AnyPublisher<CoreDataFetchResultsPublisher<Sport>.Output, NetworkError> {
        let request = NSFetchRequest<Sport>(entityName: Sport.entityName)
        
        return coreDataStore
            .publicher(fetch: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    func saveSport(newSport: SportResource) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let action: Action = {
            let sport: Sport = self.coreDataStore.createEntity()
            sport.name = newSport.name
            sport.id = newSport.id
            sport.met = newSport.met
        }

        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    func deleteSports() -> AnyPublisher<CoreDataDeleteModelPublisher.Output, NetworkError> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Sport.entityName)
        request.predicate = NSPredicate(format: "id != nil")
        
        return coreDataStore
            .publicher(delete: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    func saveSportToUser(user: User, sports: [Sport]) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
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
}
