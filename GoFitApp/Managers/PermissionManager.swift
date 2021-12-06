//
//  PermissionManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 06/12/2021.
//

import Foundation
import SPPermissions
import Combine
import HealthKit

class PermissionManager {
    
    fileprivate var subscription = Set<AnyCancellable>()
    fileprivate let healthStore = HKHealthStore()
    
    init(_ dependencyContainer: DependencyContainer) {
        
    }
    
    private var isAuthorized: Bool? = false

    func authorizeHealthKit(completion: ((_ success: Bool) -> Void)!) {
        let allTypes: Set<HKSampleType> = Set([
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
            HKObjectType.quantityType(forIdentifier: .distanceDownhillSnowSports)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ])
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        // Request Authorization
        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
            
            if success {
                completion(true)
                self.isAuthorized = true
            } else {
                completion(false)
                self.isAuthorized = false
            }
        }
    }  
}
