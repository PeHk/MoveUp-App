//
//  ActivityManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 09/01/2022.
//

import Foundation
import Combine
import CoreData

class ActivityManager {
    // MARK: Variables
    fileprivate let coreDataStore: CoreDataStore
    fileprivate var subscription = Set<AnyCancellable>()
    
    public var currentActivities = CurrentValueSubject<[Activity], Never>([])
    
    // MARK: Init
    init(_ dependencyContainer: DependencyContainer) {
        self.coreDataStore = dependencyContainer.coreDataStore
        self.fetchCurrentActivities()
    }
    
    public func fetchCurrentActivities() {
        self.getActivities()
            .sink { completion in
                return
            } receiveValue: { activities in
                self.currentActivities.send(activities)
            }
            .store(in: &subscription)
    }
    
    public func getActivities() -> AnyPublisher<CoreDataFetchResultsPublisher<Activity>.Output, NetworkError> {
        let request = NSFetchRequest<Activity>(entityName: Activity.entityName)
        
        return coreDataStore
            .publicher(fetch: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    public func saveActivity(newActivity: ActivityResource, sport: Sport) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let action: Action = {
            let activity: Activity = self.coreDataStore.createEntity()
            activity.name = newActivity.name
            activity.end_date = Helpers.getDateFromString(from: newActivity.end_date)
            activity.start_date = Helpers.getDateFromString(from: newActivity.start_date)
            activity.calories = newActivity.calories
            activity.duration = newActivity.duration ?? 0.0
            activity.traveledDistance = newActivity.traveled_distance
            activity.locations = self.getDataFromArray(array: newActivity.route ?? [])
            activity.sport = sport
        }

        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    
    func getDataFromArray(array: [Coordinates]) -> Data? {
        do {
            let data = try PropertyListEncoder.init().encode(array)
            return data
        } catch let error as NSError{
            print(error.localizedDescription)
        }
        return nil
    }
    
    func deleteActivities() -> AnyPublisher<CoreDataDeleteModelPublisher.Output, NetworkError> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Activity.entityName)
        request.predicate = NSPredicate(format: "name != nil")
        
        self.currentActivities.send([])
        
        return coreDataStore
            .publicher(delete: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
}
