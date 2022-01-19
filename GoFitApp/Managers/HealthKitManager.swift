//
//  HealthKitManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 16/12/2021.
//

import Foundation
import Combine
import HealthKit
import CoreLocation

class HealthKitManager {
    
    fileprivate let healthStore = HKHealthStore()
    fileprivate var routeBuilder: HKWorkoutRouteBuilder
    fileprivate let workoutConfiguration = HKWorkoutConfiguration()
    fileprivate var subscription = Set<AnyCancellable>()
        
    public var steps = CurrentValueSubject<Double, Never>(0)
    public var calories = CurrentValueSubject<Double, Never>(0)
    
    init(_ dependencyContainer: DependencyContainer) {
        self.routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: .local())
        self.refreshValues()
    }
    
    public func refreshValues() {
        self.getTodaysSteps()
        self.getTodaysCalories()
    }
    
    // MARK: Save workout
    public func saveWorkout(activity: ActivityResource, sport: Sport) -> Future<Void, Error> {
        Future { promise in
            let totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: activity.calories)
            let distance = HKQuantity(unit: HKUnit.meter(), doubleValue: (activity.traveled_distance ?? 0) * 1000)
            let type = sport.healthKitType?.hkWorkoutActivityType ?? .other
            let start = Helpers.getDateFromString(from: activity.start_date)
            let end = Helpers.getDateFromString(from: activity.end_date)
            
            let workout = HKWorkout(
                activityType: type,
                start: start,
                end: end,
                duration: activity.duration ?? 0.0,
                totalEnergyBurned: totalEnergyBurned,
                totalDistance: distance,
                device: .local(),
                metadata: [:]
            )
            
            self.healthStore.save(workout) { (success, error) in
                guard success else {
                    promise(.failure(error ?? NSError()))
                    return
                }
                
                self.routeBuilder.finishRoute(with: workout, metadata: nil) { (newRoute, error) in
                    guard newRoute != nil else {
                        promise(.failure(error ?? NSError()))
                        return
                    }
                    
                    promise(.success(()))
                }
            }
        }
    }
    
    // MARK: Get steps
    private func getTodaysSteps() {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                self.steps.send(0)
                return
            }
            self.steps.send(sum.doubleValue(for: HKUnit.count()))
        }
        
        self.healthStore.execute(query)
    }
    
    // MARK: Get calories
    private func getTodaysCalories() {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                self.calories.send(0)
                return
            }
            self.calories.send(sum.doubleValue(for: HKUnit.kilocalorie()))
        }
        
        self.healthStore.execute(query)
    }
    
    // MARK: Route builder delegate
    public func addRouteToBuilder(location: [CLLocation]) {
        routeBuilder.insertRouteData(location) { (success, error) in
            //
        }
    }
}
