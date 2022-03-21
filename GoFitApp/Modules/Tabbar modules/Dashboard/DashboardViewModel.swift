import Combine
import Foundation
import UIKit
import Alamofire

class DashboardViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case update
        case checkWorkouts
        case checkPermissions
        case checkRecommendations
    }
    
    enum Step {
        
    }
    
    enum State {
        case initial
        case loading
        case error(_ error: NetworkError)
    }
    
    // MARK: Actions and States
    func processAction(_ action: Action) {
        switch action {
        case .update:
            self.refreshValues()
        case .checkPermissions:
            self.showAdditionalPermissions()
        case .checkWorkouts:
            self.checkWorkouts()
        case .checkRecommendations:
            if networkMonitor.isReachable {
                self.checkRecommendations()
            }
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
    var stepsGoal: Int
    var caloriesGoal: Int
    var state = CurrentValueSubject<State, Never>(.initial)
    var action = PassthroughSubject<Action, Never>()
    var stepper = PassthroughSubject<Step, Never>()
    var errorState = PassthroughSubject<NetworkError, Never>()
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    var steps = CurrentValueSubject<Double, Never>(0)
    var calories = CurrentValueSubject<Double, Never>(0)
    var recommendations = CurrentValueSubject<[Recommendation], Never>([])
    
    var configuration: Configuration
    var subscription = Set<AnyCancellable>()
    
    fileprivate let healthKitManager: HealthKitManager
    fileprivate let userDefaultsManager: UserDefaultsManager
    fileprivate let permissionManager: PermissionManager
    fileprivate let activityManager: ActivityManager
    fileprivate let networkMonitor: NetworkMonitor
    fileprivate let networkManager: NetworkManager
    fileprivate let sportManager: SportManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.configuration = Configuration(.recommendations)
        self.healthKitManager = dependencyContainer.healthKitManager
        self.userDefaultsManager = dependencyContainer.userDefaultsManager
        self.permissionManager = dependencyContainer.permissionManager
        self.activityManager = dependencyContainer.activityManager
        self.networkMonitor = dependencyContainer.networkMonitor
        self.networkManager = dependencyContainer.networkManager
        self.sportManager = dependencyContainer.sportManager
        
        self.stepsGoal = self.userDefaultsManager.get(forKey: Constants.stepsGoal) as? Int ?? 10000
        self.caloriesGoal = self.userDefaultsManager.get(forKey: Constants.caloriesGoal) as? Int ?? 800
        
        action.sink(receiveValue: { [weak self] action in
            self?.processAction(action)
        })
            .store(in: &subscription)
        
        state.sink(receiveValue: { [weak self] state in
            self?.processState(state)
        })
            .store(in: &subscription)
        
        self.healthKitManager.steps
            .sink { steps in
                self.steps.send(steps)
                self.stepsGoal = self.userDefaultsManager.get(forKey: Constants.stepsGoal) as? Int ?? 10000
            }
            .store(in: &subscription)
        
        self.healthKitManager.calories
            .sink { calories in
                self.calories.send(calories)
                self.caloriesGoal = self.userDefaultsManager.get(forKey: Constants.caloriesGoal) as? Int ?? 800
            }
            .store(in: &subscription)
        
        self.action.send(.checkPermissions)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification, object: nil)
            .sink { _ in
                self.refreshValues()
            }
            .store(in: &subscription)
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    // MARK: Functions
    private func refreshValues() {
        self.healthKitManager.refreshValues()
    }
    
    private func checkWorkouts() {
        self.healthKitManager.getWorkouts()
            .sink { _ in
                
            } receiveValue: { workouts in
                self.activityManager.saveHealtKitWorkouts(workouts: workouts)
            }
            .store(in: &subscription)
    }
    
    private func showAdditionalPermissions() {
        let permissions = userDefaultsManager.get(forKey: Constants.permissions) as? Bool
        if permissions == nil || permissions == false {
            self.permissionManager.authorizeHealthKit { success in
                self.refreshValues()
                self.userDefaultsManager.set(value: true, forKey: Constants.permissions)
            }
        }
    }
    
    private func checkRecommendations() {
        let recommendationsPublisher: AnyPublisher<DataResponse<[RecommendationResource], NetworkError>, Never> = self.networkManager.request(
            Endpoint.recommendation.url,
            method: .get
        )
        
        recommendationsPublisher
            .sink { dataResponse in
                if let error = dataResponse.error {
                    print("Recommendations error:", error)
                } else {
                    self.processRecommendations(recommendations: dataResponse.value!)
                }
            }
            .store(in: &subscription)
    }
    
    // MARK: Process recommendations
    private func processRecommendations(recommendations: [RecommendationResource]) {
        let sports = sportManager.currentSports.value
        var finalRecommendations: [Recommendation] = []
        
        for r in recommendations {
            let recSport = sports.first(where: {$0.id == r.sport_id })
            
            let finalRecommendation: Recommendation = Recommendation(id: r.id, type: r.type, created_at: r.created_at, start_time: r.start_time, end_time: r.end_time, sport_id: r.sport_id, rating: r.rating, activity_id: r.activity_id, accepted_at: r.accepted_at, sport: recSport)
            finalRecommendations.append(finalRecommendation)
        }
        
        self.recommendations.send(finalRecommendations)
    }
    
    // MARK: ViewModels
    func createSportRecommendationCellViewModel(recommendation: Recommendation) -> SportRecommendationCellViewModel {
        SportRecommendationCellViewModel(type: recommendation.type, sport: recommendation.sport)
    }
}
