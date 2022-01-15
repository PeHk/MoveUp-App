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
    private var lastLocation: CLLocation!
    private var route: [CLLocation]
    
    public var traveledDistance = CurrentValueSubject<Double, Never>(0.0)
    
    init(_ dependencyContainer: DependencyContainer) {
        self.locationManager = CLLocationManager()
        self.healthKitManager = dependencyContainer.healthKitManager
        self.lastLocation = locationManager.location
        self.route = []
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.activityType = .fitness
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    public func start() {
        self.lastLocation = locationManager.location
        self.locationManager.startUpdatingLocation()
    }
    
    public func stop() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            location.horizontalAccuracy <= 30.0
        }
        
        guard !filteredLocations.isEmpty else { return }
        
        self.getDistance(latestLocation: filteredLocations.last)
        
        if let last = filteredLocations.last {
            self.route.append(last)
        }
        
        healthKitManager.addRouteToBuilder(location: filteredLocations)
    }
    
    private func getDistance(latestLocation: CLLocation?) {
        if let latestLocation = latestLocation {
            var traveledDistance = self.traveledDistance.value
            
            traveledDistance += latestLocation.distance(from: self.lastLocation)
            
            self.traveledDistance.send(traveledDistance)
            
            self.lastLocation = latestLocation
        }
    }
    
    public func getRouteCoordinates() -> [Coordinates] {
        var coordinates: [Coordinates] = []
        
        for location in route {
            let coordinate = Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            coordinates.append(coordinate)
        }
        
        return coordinates
    }
    
}
