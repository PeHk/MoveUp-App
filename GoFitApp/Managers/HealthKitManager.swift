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
    fileprivate let userDefaultsManager: UserDefaultsManager
    
    public var steps = CurrentValueSubject<Double, Never>(0)
    public var calories = CurrentValueSubject<Double, Never>(0)

    
    init(_ dependencyContainer: DependencyContainer) {
        self.routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: .local())
        self.userDefaultsManager = dependencyContainer.userDefaultsManager
        self.refreshValues()
    }
    
    deinit {
        print("HealthKit deinit")
    }
    
    public func refreshValues() {
        self.getTodaysSteps()
        self.getTodaysCalories()
    }
    
    public func reinit() {
        self.routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: .local())
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
            
            let caloriesSample = HKQuantitySample(type: HKQuantityType(.activeEnergyBurned), quantity: totalEnergyBurned, start: workout.startDate, end: workout.endDate)
            
            
            self.healthStore.save(workout) { (success, error) in
                guard success else {
                    promise(.failure(error ?? NSError()))
                    return
                }
                
                self.healthStore.add([caloriesSample], to: workout) { (success, error) in
                    guard success else {
                        promise(.failure(error ?? NSError()))
                        return
                    }
                }
                
                if WorkoutType(rawValue: sport.type ?? "") == .outdoor {
                    self.routeBuilder.finishRoute(with: workout, metadata: nil) { (newRoute, error) in
                        guard newRoute != nil else {
                            promise(.failure(error ?? NSError()))
                            return
                        }
                        
                        promise(.success(()))
                    }
                } else {
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
        func createPredicate() -> NSPredicate? {
            let calendar = Calendar.autoupdatingCurrent
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
            dateComponents.calendar = calendar
            let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
            return predicate
        }
        
        let queryPredicate = createPredicate()
            let query = HKActivitySummaryQuery(predicate: queryPredicate) { (query, summaries, error) -> Void in
                guard let summaries = summaries, summaries.count > 0
                else {
                    self.calories.send(0)
                    return
                }

                for summary in summaries {
                    self.calories.send(summary.activeEnergyBurned.doubleValue(for: HKUnit.kilocalorie()))
                }
            }

        self.healthStore.execute(query)
    }
    
    public func getWorkouts() -> Future<[HKWorkout], Error> {
        return Future { promise in
            
            guard let latestDate = self.userDefaultsManager.get(forKey: Constants.workoutsUpdated) as? Date else {
                print("[saving_health_kit_date: \(Date())]")
                self.userDefaultsManager.set(value: Date(), forKey: Constants.workoutsUpdated)
                promise(.success([]))
                return
            }
            
            print("[last_update_health_kit: \(latestDate)]")
            
            
            let workoutPredicate = HKQuery.predicateForWorkouts(with: .greaterThan, totalEnergyBurned: HKQuantity.init(unit: .smallCalorie(), doubleValue: 0))
            let timePredicate = HKQuery.predicateForSamples(withStart: latestDate, end: Date(), options: [])
            
            let combined = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, workoutPredicate])
            
            let query = HKSampleQuery(sampleType: .workoutType(), predicate: combined, limit: 0, sortDescriptors: nil) { (query, samples, error) in
                DispatchQueue.main.async {
                    guard let samples = samples as? [HKWorkout], error == nil else {
                        promise(.failure(error ?? NSError()))
                        return
                    }
                    self.userDefaultsManager.set(value: Date(), forKey: Constants.workoutsUpdated)
                    promise(.success(samples))
                }
            }
            
            self.healthStore.execute(query)
        }
    }
    
    // MARK: Route builder delegate
    public func addRouteToBuilder(location: [CLLocation]) {
        routeBuilder.insertRouteData(location) { (success, error) in
            //
        }
    }
}
