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
    fileprivate let workoutConfiguration = HKWorkoutConfiguration()
    fileprivate var subscription = Set<AnyCancellable>()
    
    fileprivate var routeBuilder: HKWorkoutRouteBuilder
    
    public var steps = CurrentValueSubject<Double, Never>(0)
    public var calories = CurrentValueSubject<Double, Never>(0)
    
    init(_ dependencyContainer: DependencyContainer) {
        self.routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
        self.refreshValues()
    }
    
    public func refreshValues() {
        self.getTodaysSteps()
        self.getTodaysCalories()
    }
    
    // MARK: Save workout
    func saveWorkout(workout: ActivityResource, sport: Sport) -> Future<Void, Error> {
        Future { promise in
            self.workoutConfiguration.activityType = sport.healthKitType?.hkWorkoutActivityType ?? .other
            
            let builder = HKWorkoutBuilder(
                healthStore: self.healthStore,
                configuration: self.workoutConfiguration,
                device: .local())
            
            builder.beginCollection(withStart: workout.start_date) { success, error in
                guard success else {
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    else {
                        return
                    }
                }
                
                guard let quantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
                    promise(.failure(NSError(domain: "healthKit", code: 400, userInfo: nil)))
                    return
                }
                    
                let unit = HKUnit.kilocalorie()
                let totalEnergyBurned = workout.calories
                let quantity = HKQuantity(unit: unit, doubleValue: Double(totalEnergyBurned))
                
                let sample = HKCumulativeQuantitySample(type: quantityType,
                                                              quantity: quantity,
                                                              start: workout.start_date,
                                                              end: workout.end_date)
                
                builder.add([sample]) { (success, error) in
                    guard success else {
                        if let error = error {
                            promise(.failure(error))
                            return
                        }
                        else {
                            return
                        }
                    }
                    
                    builder.endCollection(withEnd: workout.end_date) { (success, error) in
                        guard success else {
                            if let error = error {
                                promise(.failure(error))
                                return
                            } else {
                                return
                            }
                        }

                        builder.finishWorkout { (workout, error) in
                            if let error = error {
                                promise(.failure(error))
                            } else {
                                if let workout = workout {
                                    self.routeBuilder.finishRoute(with: workout, metadata: nil) { (newRoute, error) in
                                        guard newRoute != nil else {
                                            promise(.failure(error ?? NSError()))
                                            return
                                        }
                                                                                
                                        promise(.success(()))
                                    }
                                } else {
                                    promise(.failure(error ?? NSError()))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func addRouteToBuilder(location: [CLLocation]) {
        routeBuilder.insertRouteData(location) { (success, error) in
            //
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
}
