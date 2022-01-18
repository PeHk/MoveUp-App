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
    private var lastLocation: CLLocation!
    private var lastAltitude: Double!
    private var route: [CLLocation]
    
    public var traveledDistance = CurrentValueSubject<Double, Never>(0.0)
    public var currentAltitude = CurrentValueSubject<Double, Never>(0.0)
    public var elevationGained = CurrentValueSubject<Double, Never>(0.0)
    
    // MARK: Init
    init(_ dependencyContainer: DependencyContainer) {
        self.locationManager = CLLocationManager()
        self.lastLocation = locationManager.location
        self.lastAltitude = locationManager.location?.altitude ?? 0.0
        self.route = []
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.activityType = .fitness
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    // MARK: Start
    public func start() {
        self.lastLocation = locationManager.location
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: Stop
    public func stop() {
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: Delegate function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            location.horizontalAccuracy <= 50.0
        }
        
        guard !filteredLocations.isEmpty else { return }
        
        self.getDistance(latestLocation: filteredLocations.last)
        
        if let last = filteredLocations.last {
            self.route.append(last)
            self.currentAltitude.send(last.altitude)
            self.getElevationGained(latestLocation: last)
        }
    }
    
    private func getDistance(latestLocation: CLLocation?) {
        if let latestLocation = latestLocation {
            var traveledDistance = self.traveledDistance.value
            
            traveledDistance += latestLocation.distance(from: self.lastLocation)
            
            self.traveledDistance.send(traveledDistance)
            
            self.lastLocation = latestLocation
        }
    }
    
    private func getElevationGained(latestLocation: CLLocation) {
        guard lastAltitude < latestLocation.altitude else { return }
        
        let elevationCalculated = latestLocation.altitude - lastAltitude
        let elevationGained = self.elevationGained.value + elevationCalculated
        self.elevationGained.send(elevationGained)
        
        lastAltitude = latestLocation.altitude
    }
    
    public func getRouteCoordinates() -> [[Double]] {
        var coordinates: [[Double]] = []
        
        guard route.count > 0 else { return [] }
        
        for location in route {
            coordinates.append([location.coordinate.latitude, location.coordinate.longitude])
        }
        
        return coordinates
    }
    
}
