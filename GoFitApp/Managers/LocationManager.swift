//
//  LocationManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 14/01/2022.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager
    private let healthKitManager: HealthKitManager
    private  var initialLocation: CLLocation?
    
    public var latestDistance = CurrentValueSubject<Double, Never>(0.0)
    
    init(_ dependencyContainer: DependencyContainer) {
        self.locationManager = CLLocationManager()
        self.healthKitManager = dependencyContainer.healthKitManager
        self.initialLocation = locationManager.location
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.activityType = .fitness
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    public func start() {
        self.initialLocation = locationManager.location
        self.locationManager.startUpdatingLocation()
    }
    
    public func stop() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            location.horizontalAccuracy <= 50.0
        }
        
        guard !filteredLocations.isEmpty else { return }
        
        self.getDistance(latestLocation: filteredLocations.last)
        healthKitManager.addRouteToBuilder(location: filteredLocations)
    }
    
    private func getDistance(latestLocation: CLLocation?) {
        if let initial = self.initialLocation, let latest = latestLocation {
            self.latestDistance.send(latest.distance(from: initial))
        } else {
            self.latestDistance.send(0.0)
        }
    }
    
}
