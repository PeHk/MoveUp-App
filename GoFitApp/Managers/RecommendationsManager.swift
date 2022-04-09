//
//  RecommendationsManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 02/04/2022.
//

import Foundation
import EventKit
import Combine
import HealthKit
import Alamofire

class RecommendationsManager {
    
    // MARK: Variables
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter
    }
    
    private var currentHourIndex: Int {
        allDayHours.firstIndex(where: { $0.hour == formatter.string(from: Date())}) ?? 0
    }
    
    private var subscription = Set<AnyCancellable>()
    private var workouts: [HKWorkout] = []
    private var activeTimes = PassthroughSubject<[(String, Int)], Never>()
    private var events = PassthroughSubject<[EKEvent], Never>()
    private var allDayHours: [(hour: String, weights: [Float])] = []
    
    fileprivate let eventStore: EKEventStore
    fileprivate let activityManager: ActivityManager
    fileprivate let healthkitManager: HealthKitManager
    fileprivate let networkManager: NetworkManager
    fileprivate let locationManager: LocationManager
    fileprivate let networkMonitor: NetworkMonitor
    
    // MARK: Init
    init(_ dependencyContainer: DependencyContainer) {
        self.activityManager = dependencyContainer.activityManager
        self.healthkitManager = dependencyContainer.healthKitManager
        self.networkManager = dependencyContainer.networkManager
        self.networkMonitor = dependencyContainer.networkMonitor
        self.eventStore = EKEventStore()
        self.locationManager = LocationManager(dependencyContainer)
        
        initializeHourArray()
        
        requestAccess()
        setupWorkouts()
        fetchWeather()
        
        Publishers.Zip(activeTimes, events)
            .sink { [weak self] times, events in
                print(times, events)
            }
            .store(in: &subscription)
        
        print(allDayHours)
    }
    
    private func initializeHourArray() {
        for hour in 0...23 {
            hour < 10 ?
            allDayHours.append((hour: "0" + String(hour), weights: [1, 1])) :
            allDayHours.append((hour: String(hour), weights: [1, 1]))
        }
    }
    
    // MARK: Extract times
    private func extractTimes(workouts: [HKWorkout]) {
        var tmpTimes: [(String, Int)] = []
        let countedSet = NSCountedSet()

        for workout in workouts {
            countedSet.add(formatter.string(from: workout.startDate))
        }
        
        for time in countedSet {
            let tmp = ((time as? String) ?? "", countedSet.count(for: time))
            tmpTimes.append(tmp)
        }
        
        tmpTimes = tmpTimes.sorted(by: { $0.1 > $1.1 })

        self.activeTimes.send(tmpTimes)
    }
    
    // MARK: Setup
    private func setupWorkouts() {
        self.healthkitManager.getWorkoutsByTimeInterval()
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Activity time error:", error)
                }
            } receiveValue: { workouts in
                self.workouts = workouts
                self.extractTimes(workouts: workouts)
            }
            .store(in: &subscription)
    }
    
    private func requestAccess() {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    self.loadEvents()
                }
            }
        }
    }
    
    // MARK: Load events
    private func loadEvents() {
        let dayFromNow = Date().advanced(by: TimeInterval.day() )
        let predicate = eventStore.predicateForEvents(withStart: Date(), end: dayFromNow, calendars: nil)
        
        let events = eventStore.events(matching: predicate)
        
        self.events.send(events)
    }
    
    // MARK: Fetch weather
    private func fetchWeather() {
        if let coordinates = self.locationManager.lastLocation?.coordinate, self.networkMonitor.isReachable {
            let weatherPublisher: AnyPublisher<DataResponse<WeatherResource, NetworkError>, Never> = self.networkManager.request(Endpoint.weatherAPI(lat: coordinates.latitude, long: coordinates.longitude).weatherURL, method: .get, withInterceptor: false)
            
            weatherPublisher
                .sink { dataResponse in
                    if dataResponse.error == nil {
                        if let weather = dataResponse.value {
                            for hour in weather.hourly {
                                let timeStamp = Date(timeIntervalSince1970: hour.dt + weather.timezone_offset)
                                let arrIndex = self.allDayHours.firstIndex(where: { $0.hour == self.formatter.string(from: timeStamp)})
                                
                                if arrIndex != nil, let weatherHour = hour.weather.first {
                                    self.allDayHours[arrIndex!].weights[0] = Helpers.getWeatherCoef(weatherID: weatherHour.id).0
                                }
                            }
                            print(self.allDayHours)
                        }
                    } else {
                        print("Error", dataResponse.error)
                    }
                }
                .store(in: &subscription)
            
        }
        
        
    }
}
