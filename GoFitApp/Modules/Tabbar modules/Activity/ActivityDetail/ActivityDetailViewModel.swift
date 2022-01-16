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
    
    var currentUser = CurrentValueSubject<User?, Never>(nil)
    
    @Published var timeString = "00:00:00"
    @Published var caloriesString = "0 cal"
    @Published var distanceString = "0,00 km"
    
    var subscription = Set<AnyCancellable>()
    
    fileprivate let timerManager: TimerManager
    fileprivate let userManager: UserManager
    fileprivate let feedbackManager: FeedbackManager
    fileprivate let healthKitManager: HealthKitManager
    fileprivate let activityManager: ActivityManager
    fileprivate let locationManager: LocationManager
    fileprivate let networkManager: NetworkManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer, sport: Sport) {
        self.sport = sport
        self.start = Date()
        self.timerManager = TimerManager()
        self.locationManager = LocationManager(dependencyContainer)
        self.userManager = dependencyContainer.userManager
        self.feedbackManager = dependencyContainer.feedbackManager
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
                let tmpDistance = distance.rounded() / 1000
                if self.currentDistance < tmpDistance {
                    self.currentDistance = tmpDistance
                    self.distanceString = String(format: "%.2f", self.currentDistance) + " km"
                }
            }
            .store(in: &subscription)
        
        timerManager.isPaused = false
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
    
    private func startTimer() {
        timerManager.startTimer()
        locationManager.start()
    }
    
    private func stopTimer() {
        self.state.send(.loading)
        timerManager.stopTimer()
        locationManager.stop()
        self.feedbackManager.sendFeedbackNotification(.success)
        
        let workout = ActivityResource(
            start_date: Helpers.formatDate(from: start),
            end_date: Helpers.formatDate(from: Date()),
            calories: totalCalories,
            name: sport.name ?? "",
            traveled_distance: currentDistance,
            route: locationManager.getRouteCoordinates())

        if workout.duration ?? 0 > 60 {
            self.saveHealthKitWorkout(workout: workout)
        } else {
            self.isLoading.send(false)
            self.stepper.send(.endActivity)
        }
    }
    
    private func saveBackendWorkout(workout: ActivityResource) {
        let activityPublisher: AnyPublisher<DataResponse<ActivityResource, NetworkError>, Never> = self.networkManager.request(
            Endpoint.activity.url,
            method: .post,
            parameters: workout.getJSON()
        )
    
        activityPublisher
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    self.activityManager.fetchCurrentActivities()
                    self.isLoading.send(false)
                    self.stepper.send(.endActivity)
                }
            }
            .store(in: &subscription)

        
    }
    
    private func saveHealthKitWorkout(workout: ActivityResource) {
        self.healthKitManager.saveWorkout(workout: workout, sport: sport)
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
    
    private func saveCoreDataWorkout(workout: ActivityResource) {
        self.activityManager.saveActivity(newActivity: workout, sport: sport)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { _ in
                self.saveBackendWorkout(workout: workout)
            }
            .store(in: &subscription)
    }
    
    private func pauseTimer() {
        self.feedbackManager.sendImpactFeedback(.rigid)
        timerManager.isPaused = true
        timerManager.pauseTimer()
        locationManager.stop()
    }
    
    private func resumeTimer() {
        self.feedbackManager.sendImpactFeedback(.rigid)
        timerManager.isPaused = false
        timerManager.startTimer()
        locationManager.start()
    }
}
