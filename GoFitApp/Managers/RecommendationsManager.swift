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
import CombineExt

struct HourWeight {
    var timestamp: Date
    var weights: Weights
    var finalWeight: Float
    var type: WorkoutType
}

struct Weights {
    var weather: Float
    var calendar: Float
    var history: Float
}

struct HistoryWeights {
    var hour: String
    var count: Float
}

class RecommendationsManager {
    
    // MARK: Variables
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter
    }

    private var subscription = Set<AnyCancellable>()
    private var workouts: [HKWorkout] = []
    private var activeTimes = PassthroughSubject<[HistoryWeights], Never>()
    private var events = PassthroughSubject<[EKEvent], Never>()
    private var weatherLock = PassthroughSubject<Bool, Never>()
    private var allDayHours = CurrentValueSubject<[HourWeight], Never>([])
    
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

        Publishers.Zip3(activeTimes, events, weatherLock)
            .sink { [weak self] times, events, weatherLock in
                self?.evaluateEvents(events: events)
                self?.evaluateHistory(history: times)
                self?.calculateProbability()
                self?.helperFunction()
            }
            .store(in: &subscription)
    }
    
    // MARK: Final probability
    private func calculateProbability() {
        var arr = allDayHours.value
        
        for (index, hour) in arr.enumerated() {
            let coef = hour.weights.history * hour.weights.weather * hour.weights.calendar
            arr[index].finalWeight = coef
        }
        
        allDayHours.send(arr)
    }
    
    // MARK: Extract times
    private func extractTimes(workouts: [HKWorkout]) {
        var tmpTimes: [HistoryWeights] = []
        let countedSet = NSCountedSet()

        for workout in workouts {
            countedSet.add(formatter.string(from: workout.startDate))
        }
        
        for time in countedSet {
            let tmp = HistoryWeights(hour: time as? String ?? "", count: Float(countedSet.count(for: time)))
            tmpTimes.append(tmp)
        }
        
        tmpTimes = tmpTimes.sorted(by: { $0.count > $1.count })

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
            var arr = self.allDayHours.value
            let weatherPublisher: AnyPublisher<DataResponse<WeatherResource, NetworkError>, Never> = self.networkManager.request(Endpoint.weatherAPI(lat: coordinates.latitude, long: coordinates.longitude).weatherURL, method: .get, withInterceptor: false)

            weatherPublisher
                .sink { [weak self] dataResponse in
                    if dataResponse.error == nil {
                        if let weather = dataResponse.value {
                            for hour in weather.hourly {
                                let timeStamp = Date(timeIntervalSince1970: hour.dt)
                                let arrIndex = arr.firstIndex(where: { $0.timestamp == timeStamp})

                                if arrIndex != nil, let weatherHour = hour.weather.first {
                                    arr[arrIndex!].weights.weather = Helpers.getWeatherCoef(weatherID: weatherHour.id).0
                                    arr[arrIndex!].type = Helpers.getWeatherCoef(weatherID: weatherHour.id).1
                                }
                            }
                            self?.allDayHours.send(arr)
                            self?.weatherLock.send(true)
                        } else { self?.weatherLock.send(false) }
                    } else { self?.weatherLock.send(false) }
                }
                .store(in: &subscription)
        }
    }
}

extension RecommendationsManager {
    // MARK: Initialization
    private func initializeHourArray() {
        var arr: [HourWeight] = []
        let timestamp = Date().nearestHour()
        for hour in 0...23 {
            arr.append(
                HourWeight(
                    timestamp: timestamp.addingTimeInterval(.hour() * Double(hour)),
                    weights: Weights(weather: 1, calendar: 1, history: 1),
                    finalWeight: 1,
                    type: .both
                )
            )
        }
        allDayHours.send(arr)
    }
    
    // MARK: Request Access
    private func requestAccess() {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    self.loadEvents()
                }
            }
        }
    }
    
    // MARK: Events evaluation
    private func evaluateEvents(events: [EKEvent]) {
        var arr = self.allDayHours.value
        for event in events {
            if let start = event.startDate, let end = event.endDate {
                for (index, hour) in arr.enumerated() {
                    if start <= hour.timestamp && end >= hour.timestamp {
                        arr[index].weights.calendar = 0.8
                    }
                }
            }
        }
        allDayHours.send(arr)
    }
    
    // MARK: History evaluation
    private func evaluateHistory(history: [HistoryWeights]) {
        let maximum = history.max(by: { (a, b) -> Bool in
            a.count < b.count
        })
        let minimum = history.min(by: { (a, b) -> Bool in
            a.count < b.count
        })

        guard let maximum = maximum, let minimum = minimum else {
            return
        }

        var arr = allDayHours.value
        
        arr.enumerated().forEach { (index, value) in
            if let historyObj = history.first(where: { $0.hour == formatter.string(from: value.timestamp) }) {
                arr[index].weights.history = historyObj.count.converting(from: minimum.count...maximum.count, to: 1...2)
            }
        }

        allDayHours.send(arr)
    }
    
    private func helperFunction() {
        for item in allDayHours.value {
            print(item.timestamp.formatted())
            print(item.weights)
            print(item.finalWeight)
        }
    }
}
