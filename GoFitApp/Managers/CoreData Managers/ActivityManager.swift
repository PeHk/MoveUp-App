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
    
    // MARK: Fetch current activities
    public func fetchCurrentActivities() {
        self.getActivities()
            .sink { completion in
                return
            } receiveValue: { activities in
                self.currentActivities.send(activities)
            }
            .store(in: &subscription)
    }
    
    // MARK: Get activities
    private func getActivities() -> AnyPublisher<CoreDataFetchResultsPublisher<Activity>.Output, NetworkError> {
        let request = NSFetchRequest<Activity>(entityName: Activity.entityName)
        
        return coreDataStore
            .publicher(fetch: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Save activity
    public func saveActivities(newActivities: [ActivityResource]) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let action: Action = {
            for newActivity in newActivities {
                let _ = self.getActivityObject(data: newActivity)
            }
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Delete activities
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

// MARK: Helper functions
extension ActivityManager {
    private func getActivityObject(data: ActivityResource) -> Activity {
        let activity: Activity = self.coreDataStore.createEntity()
        activity.name = data.name
        activity.end_date = Helpers.getDateFromString(from: data.end_date)
        activity.start_date = Helpers.getDateFromString(from: data.start_date)
        activity.calories = data.calories
        activity.duration = data.duration ?? 0.0
        activity.traveledDistance = data.traveled_distance
        activity.locations = Helpers.getDataFromArray(array: data.locations ?? [])
        
        return activity
    }
}
