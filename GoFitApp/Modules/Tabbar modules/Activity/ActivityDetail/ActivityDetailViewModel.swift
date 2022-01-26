import Combine
import Foundation
import UIKit
import Alamofire

class ActivityDetailViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case start
        case stop
        case pause
        case resume
        case warning
    }
    
    enum Step {
        case endActivity
    }
    
    enum State {
        case initial
        case loading
        case error(_ error: NetworkError)
    }
    
    // MARK: Actions and States
    func processAction(_ action: Action) {
        switch action {
        case .start:
            self.startTimer()
        case .stop:
            self.stopTimer()
        case .pause:
            self.pauseTimer()
        case .resume:
            self.resumeTimer()
        default:
            return
        }
    }
    
    func processState(_ state: State) {
        switch state {
        case .initial:
            initializeView()
        case .error(let error):
            isLoading.send(false)
            errorState.send(error)
        case .loading:
            isLoading.send(true)
        }
    }
    
    // MARK: - Variables
    var state = CurrentValueSubject<State, Never>(.initial)
    var action = PassthroughSubject<Action, Never>()
    var stepper = PassthroughSubject<Step, Never>()
    var errorState = PassthroughSubject<NetworkError, Never>()
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    var sport: Sport
    
    private var weight: Float = 0
    private var start: Date
    private var totalCalories: Double = 0
    private var currentDistance: Double = 0
    
    public var hideMapSection: Bool = false
    
    var currentUser = CurrentValueSubject<User?, Never>(nil)
    
    @Published var timeString = "00:00:00"
    @Published var caloriesString = "0 cal"
    @Published var distanceString = "0,00 km"
    @Published var altitudeString = "0 m"
    @Published var elevationGainedString = "0 m"
    @Published var paceString = "00\'00\"/km"
    
    var subscription = Set<AnyCancellable>()
    
    fileprivate let timerManager: TimerManager
    fileprivate let userManager: UserManager
    fileprivate let healthKitManager: HealthKitManager
    fileprivate let activityManager: ActivityManager
    fileprivate let locationManager: LocationManager
    fileprivate let networkManager: NetworkManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer, sport: Sport) {
        self.sport = sport
        
        if WorkoutType(rawValue: sport.type ?? "") == .indoor { self.hideMapSection = true }
 
        self.start = Date()
        self.timerManager = TimerManager()
        self.timerManager.isPaused = false
        self.locationManager = LocationManager(dependencyContainer)
        self.userManager = dependencyContainer.userManager
        self.healthKitManager = dependencyContainer.healthKitManager
        self.activityManager = dependencyContainer.activityManager
        self.networkManager = dependencyContainer.networkManager
        
        action.sink(receiveValue: { [weak self] action in
            self?.processAction(action)
        })
            .store(in: &subscription)
        
        state.sink(receiveValue: { [weak self] state in
            self?.processState(state)
        })
            .store(in: &subscription)
        
        self.userManager.currentUser
            .sink { user in
                self.currentUser.send(user)
                self.setWeight()
            }
            .store(in: &subscription)
        
        timerManager.$timeString.sink { time in
            self.timeString = time
            self.calculateCalories()
        }
        .store(in: &subscription)
        
        self.locationManager.traveledDistance
            .sink { distance in
                self.calculatePace(distance: distance)
                let tmpDistance = distance.rounded() / 1000
                if self.currentDistance < tmpDistance {
                    self.currentDistance = tmpDistance
                    self.distanceString = String(format: "%.2f", self.currentDistance) + " km"
                }
            }
            .store(in: &subscription)
        
        self.locationManager.currentAltitude
            .sink { altitude in
                self.altitudeString = String(format: "%.2f", altitude) + " m"
            }
            .store(in: &subscription)

        self.locationManager.elevationGained
            .sink { elevationGained in
                self.elevationGainedString = String(format: "%.f", elevationGained) + " m"
            }
            .store(in: &subscription)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification, object: nil)
            .sink { _ in
                self.isLoading.send(true)
            }
            .store(in: &subscription)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification, object: nil)
            .sink { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.isLoading.send(false)
                })
                
            }
            .store(in: &subscription)
    }
    
    private var caloriesConstant: Double {
        var calories = sport.met * 3.5 * weight / 200
        calories = calories / 60
        return Double(calories)
    }
    
    private func calculateCalories() {
        if Float(timerManager.time) > 0 {
            totalCalories = caloriesConstant * timerManager.time
            caloriesString = "\(String(format: "%.2f", totalCalories)) cal"
        }
    }
    
    private func calculatePace(distance: Double) {
        if timerManager.time > 0 && distance > 0 {
            let pace = 1 / ((distance / timerManager.time) / 1000)
            self.paceString = Helpers.getTimeFromSeconds(from: pace) + "/km"
        }
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    // MARK: Actions
    private func setWeight() {
        if let user = currentUser.value {
            let bioDataArr: [BioData]? = user.bio_data?.toArray()
            
            weight = bioDataArr?.first?.weight ?? 0
        }
    }
    
    // MARK: Start timer
    private func startTimer() {
        timerManager.startTimer()
        hideMapSection ? () : locationManager.start()
    }
    
    // MARK: Pause timer
    private func pauseTimer() {
        FeedbackManager.sendImpactFeedback(.rigid)
        timerManager.isPaused = true
        timerManager.pauseTimer()
        hideMapSection ? () : locationManager.stop()
    }
    
    // MARK: Resume timer
    private func resumeTimer() {
        FeedbackManager.sendImpactFeedback(.rigid)
        timerManager.isPaused = false
        timerManager.startTimer()
        hideMapSection ? () : locationManager.start()
    }
    
    // MARK: Stop timer
    private func stopTimer() {
        if abs(start.timeIntervalSinceNow) < 60 {
            self.action.send(.warning)
            FeedbackManager.sendFeedbackNotification(.warning)
        } else {
            self.state.send(.loading)
            timerManager.stopTimer()
            hideMapSection ? () : locationManager.stop()
            
            FeedbackManager.sendFeedbackNotification(.success)
            
            let elevation = locationManager.elevationGained.value
            
            var workout = ActivityResource(
                start_date: Helpers.formatDate(from: start),
                end_date: Helpers.formatDate(from: Date()),
                calories: totalCalories,
                name: sport.name ?? "",
                sport_id: sport.id,
                traveled_distance: currentDistance > 0 ? currentDistance : nil,
                elevation_gain: elevation.rounded() > 0 ? elevation.rounded() : nil,
                locations: locationManager.getRouteCoordinates().count > 0 ? locationManager.getRouteCoordinates() : nil)
            
            if hideMapSection {
                workout.elevation_gain = nil
                workout.traveled_distance = nil
                workout.locations = nil
            }

            if workout.duration ?? 0 > 60 {
                self.saveHealthKitWorkout(workout: workout)
            } else {
                self.isLoading.send(false)
                self.stepper.send(.endActivity)
            }
        }
    }
    
    // MARK: Save workout to healthkit
    private func saveHealthKitWorkout(workout: ActivityResource) {
        self.healthKitManager.saveWorkout(activity: workout, sport: sport)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(.init(initialError: nil, backendError: nil, error as NSError)))
                }
            } receiveValue: { _ in
                self.saveCoreDataWorkout(workout: workout)
            }
            .store(in: &subscription)
    }
    
    // MARK: Save workout to coreData
    private func saveCoreDataWorkout(workout: ActivityResource) {
        self.activityManager.saveActivities(newActivities: [workout])
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { _ in
                self.activityManager.fetchCurrentActivities()
                self.isLoading.send(false)
                self.stepper.send(.endActivity)
            }
            .store(in: &subscription)
    }
}
