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
    
    public func saveActivity(newActivity: ActivityResource) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let action: Action = {
            let activity: Activity = self.coreDataStore.createEntity()
            activity.name = newActivity.name
            activity.end_date = newActivity.end_date
            activity.start_date = newActivity.start_date
            activity.calories = newActivity.calories
            activity.duration = newActivity.duration
        }

        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
}
