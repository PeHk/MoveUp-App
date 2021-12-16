//
//  HealthKitManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 16/12/2021.
//

import Foundation
import Combine
import HealthKit

class HealthKitManager {
    
    fileprivate let healthStore = HKHealthStore()
    fileprivate var subscription = Set<AnyCancellable>()
    
    public var steps = CurrentValueSubject<Double, Never>(0)
    public var calories = CurrentValueSubject<Double, Never>(0)
    
    init(_ dependencyContainer: DependencyContainer) {
        self.refreshValues()
    }
    
    public func refreshValues() {
        self.getTodaysSteps()
        self.getTodaysCalories()
    }
    
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
