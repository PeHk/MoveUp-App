//
//  ActivityManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 09/01/2022.
//

import Foundation
import Combine
import CoreData
import Alamofire
import HealthKit

class ActivityManager {
    // MARK: Variables
    fileprivate let coreDataStore: CoreDataStore
    fileprivate let sportManager: SportManager
    fileprivate var subscription = Set<AnyCancellable>()
    
    public var currentActivities = CurrentValueSubject<[Activity], Never>([])
    
    // MARK: Init
    init(_ dependencyContainer: DependencyContainer) {
        self.coreDataStore = dependencyContainer.coreDataStore
        self.sportManager = dependencyContainer.sportManager
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
    
    // MARK: Get recent sports
    /// Function will return a unique set of three latest sports
    public func getRecentSports() -> [Sport] {
        var activities = currentActivities.value
        var recentSports: Set<Sport> = []
        
        guard activities.count > 0 else { return [] }
        
        activities = activities.sorted(by: { Helpers.getTimeFromDate(from: $0.end_date ?? Date()) > Helpers.getTimeFromDate(from: $1.end_date ?? Date())
        })
        
        if activities.count < 3 {
            for activity in activities {
                if let sport = activity.sport {
                    recentSports.insert(sport)
                }
            }
        } else {
            for (index, activity) in activities.enumerated() {
                if index > 3 { break }
                
                if let sport = activity.sport {
                    recentSports.insert(sport)
                }
            }
        }
        
        return recentSports.array
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
    public func deleteActivities() -> AnyPublisher<CoreDataDeleteModelPublisher.Output, NetworkError> {
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
    
    public func fetchMissingActivities(serverDate: Date) -> [ActivityResource] {
        var activities: [ActivityResource] = []
        let currentActivities = self.currentActivities.value.sorted(by: {
            $0.end_date ?? Date() > $1.end_date ?? Date()})
        
        guard currentActivities.count > 0 else { return []}
        
        if let latestActivity = currentActivities.first {
            if let latestEndDate = latestActivity.end_date {
                if latestEndDate > serverDate {
                    activities = getActivitiesByDate(date: serverDate, currentActivities: currentActivities)
                }
            }
        }
        
        return activities
    }
    
    private func getActivitiesByDate(date: Date, currentActivities: [Activity]) -> [ActivityResource] {
        var activities: [ActivityResource] = []
        
        for activity in currentActivities {
            if let endDate = activity.end_date {
                if endDate > date {
                    activities.append(self.getActivityResourceObject(data: activity))
                }
            }
        }
        
        return activities
    }
    
    public func saveHealtKitWorkouts(workouts: [HKWorkout]) {
        var activities: [ActivityResource] = []
        var activitiesToSave: [ActivityResource] = []
        let currentActivities = self.currentActivities.value.sorted(by: {
            $0.end_date ?? Date() > $1.end_date ?? Date()})
        
        for workout in workouts {
            activities.append(self.getActivityFromHKWourkout(data: workout))
        }
        
        if currentActivities.count > 0 {
            for activity in activities {
                let activityStartDate = Helpers.getDateFromString(from: activity.start_date)
                
                if activityStartDate > currentActivities.first?.end_date ?? Date() {
                    activitiesToSave.append(activity)
                }
            }
            
        } else {
            activitiesToSave = activities
        }
        
        self.saveActivities(newActivities: activitiesToSave)
            .sink { _ in
                ()
            } receiveValue: { _ in
                self.fetchCurrentActivities()
            }
            .store(in: &subscription)

        
    }
}

// MARK: Helper functions
extension ActivityManager {
    private func getActivityFromHKWourkout(data: HKWorkout) -> ActivityResource {
        let sports = self.sportManager.currentSports.value
        let sport = sports.first(where: { $0.healthKitType?.hkWorkoutActivityType == data.workoutActivityType})
        let healthKitSport = sports.first(where: { $0.name == Constants.healthKitSportName })
        
        return ActivityResource(
            start_date: Helpers.formatDate(from: data.startDate),
            end_date: Helpers.formatDate(from: data.endDate),
            calories: data.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0,
            name: data.workoutActivityType.name,
            sport_id: sport != nil ? sport!.id : (healthKitSport?.id ?? 0),
            traveled_distance: data.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)) ?? nil,
            elevation_gain: nil,
            locations: nil,
            external: true
        )
    }
    
    private func getActivityObject(data: ActivityResource) -> Activity {
        let activity: Activity = self.coreDataStore.createEntity()
        activity.name = data.name
        activity.end_date = Helpers.getDateFromString(from: data.end_date)
        activity.start_date = Helpers.getDateFromString(from: data.start_date)
        activity.calories = data.calories
        activity.duration = data.duration ?? 0.0
        activity.pace = data.pace ?? 0.0
        activity.externalType = data.external ?? false
        
        (data.locations != nil) ? (activity.locations = Helpers.getDataFromArray(array: data.locations ?? [])) : ()
        (data.traveled_distance != nil) ? (activity.traveledDistance = data.traveled_distance ?? 0.0): ()
        (data.elevation_gain != nil) ? (activity.elevation_gain = data.elevation_gain ?? 0.0) : ()
        
        if let sport = self.sportManager.currentSports.value.first(where: { $0.id == data.sport_id }) {
            activity.sport = sport
        }
        
        return activity
    }
    
    private func getActivityResourceObject(data: Activity) -> ActivityResource {
        var locations: [[Double]] = []
        
        if let dataLocations = data.locations {
            if let arr = Helpers.getArrayFromData(data: dataLocations) {
                locations = arr
            }
        }
        
        return ActivityResource(
            start_date: Helpers.formatDate(from: data.start_date ?? Date()),
            end_date: Helpers.formatDate(from: data.end_date ?? Date()),
            calories: data.calories,
            name: data.name ?? "",
            sport_id: data.sport?.id ?? 0,
            traveled_distance: data.traveledDistance > 0 ? data.traveledDistance : nil,
            elevation_gain: data.elevation_gain > 0 ? data.elevation_gain : nil,
            locations: locations.count > 0 ? locations : nil,
            external: data.externalType
        )
    }
}
