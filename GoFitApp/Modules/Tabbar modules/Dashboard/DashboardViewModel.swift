import Combine
import Foundation
import UIKit
import Alamofire

struct RecommendationArray {
    var recommendedActivity: ActivityRecommendation?
    var recommendedSport: Recommendation?
}

class DashboardViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case update
        case checkWorkouts
        case checkPermissions
        case checkRecommendations(withLoading: Bool)
        case showAlert(title: String, message: String)
        case presentRatingView(recommendation: Recommendation)
        case presentActivityRating(recommendation: ActivityRecommendation)
        case ratingReceived(rating: Int, recommendation: Recommendation)
        case activityRatingReceived(rating: Int, recommendation: ActivityRecommendation)
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
        case .checkRecommendations(let loading):
            if networkMonitor.isReachable {
                if loading {
                    self.state.send(.loading)
                }
                self.downloadNewSports()
                self.checkRecommendations()
            } else {
                self.tableLoading.send(false)
                self.recommendationsLock.send(())
            }
        case .ratingReceived(let rating, let rec):
            self.handleRating(rating: rating, recommendation: rec)
        case.activityRatingReceived(let rating, let rec):
            self.handleActivityRating(rating: rating, recommendation: rec)
        default:
            break
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
    var tableLoading = CurrentValueSubject<Bool, Never>(true)
    var steps = CurrentValueSubject<Double, Never>(0)
    var calories = CurrentValueSubject<Double, Never>(0)
    var presentDoneAlert = CurrentValueSubject<Bool, Never>(false)
    var presentActivityAlert = CurrentValueSubject<Bool, Never>(false)
    
    var recommendationsLock = PassthroughSubject<Void, Never>()
    var recommendations = CurrentValueSubject<[RecommendationArray], Never>([])
    var onlineRecommendations = CurrentValueSubject<[Recommendation], Never>([])
    
    var configuration: Configuration
    var subscription = Set<AnyCancellable>()
    
    fileprivate let healthKitManager: HealthKitManager
    fileprivate let userDefaultsManager: UserDefaultsManager
    fileprivate let permissionManager: PermissionManager
    fileprivate let activityManager: ActivityManager
    fileprivate let networkMonitor: NetworkMonitor
    fileprivate let networkManager: NetworkManager
    fileprivate let sportManager: SportManager
    fileprivate let userManager: UserManager
    fileprivate let recommendationsManager: RecommendationsManager
    
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
        self.userManager = dependencyContainer.userManager
        self.recommendationsManager = dependencyContainer.recommendationsManager
        
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
        
        recommendationsLock.zip(recommendationsManager.recommendationLock)
            .sink { _, _ in
                var finalRecommendations: [RecommendationArray] = []
                let onlineRecommendations = self.onlineRecommendations.value
                let activities = self.recommendationsManager.recommendation.value
                
                for activity in activities {
                    if activity.sport != nil {
                        finalRecommendations.append(RecommendationArray(recommendedActivity: activity, recommendedSport: nil))
                    }
                }
                
                for onlineRecommendation in onlineRecommendations {
                    finalRecommendations.append(RecommendationArray(recommendedActivity: nil, recommendedSport: onlineRecommendation))
                }
                                
                self.recommendationsManager.getAllUsynced()
                    .sink { _ in
                        ()
                    } receiveValue: { unsynced in
                        if unsynced.count > 0 {
                            self.syncLocalRecommendations(recommendations: unsynced)
                        }
                    }
                    .store(in: &self.subscription)
                
                self.recommendations.send(finalRecommendations)
                self.tableLoading.send((false))
                self.isLoading.send(false)
                self.presentDoneAlert.send(false)
            }
            .store(in: &subscription)
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    // MARK: Functions
    private(set) lazy var showAlert = Publishers.CombineLatest(isLoading, presentDoneAlert)
        .map { $0 == false && $1 == true }
        .eraseToAnyPublisher()
    
    
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
        self.tableLoading.send(true)
        
        let recommendationsPublisher: AnyPublisher<DataResponse<[RecommendationResource], NetworkError>, Never> = self.networkManager.request(
            Endpoint.recommendation.url,
            method: .get
        )
        
        recommendationsPublisher
            .sink { dataResponse in
                if let _ = dataResponse.error {
                    self.recommendationsLock.send(())
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
            
            if recSport?.name != "HealthKit" {
                let finalRecommendation: Recommendation = Recommendation(id: r.id, type: r.type, created_at: r.created_at, start_time: r.start_time, end_time: r.end_time, sport_id: r.sport_id, rating: r.rating, activity_id: r.activity_id, accepted_at: r.accepted_at, sport: recSport)
                finalRecommendations.append(finalRecommendation)
            }
        }
        
        self.recommendationsManager.fetchCurrentRecommendations()
        self.onlineRecommendations.send(finalRecommendations)
        self.recommendationsLock.send(())
    }
    
    // MARK: Handle activity
    public func handleActivityRecommendation(recommendation: ActivityRecommendation, state: Bool) {
        if self.networkMonitor.isReachable, let uuid = recommendation.uuid?.uuidString {
            self.state.send(.loading)
            
            let acceptancePublisher: AnyPublisher<DataResponse<RecommendationResource, NetworkError>, Never> = self.networkManager.request(
                Endpoint.activityUpdate.url,
                method: .put,
                parameters: ["type": 2, "acceptance": state, "uuid": uuid]
            )
            
            acceptancePublisher
                .sink { dataResponse in
                    if dataResponse.error != nil {
                        if state {
                            self.action.send(.presentActivityRating(recommendation: recommendation))
                        } else {
                            self.updateActivityRecommendation(recommendation, rating: 0)
                        }
                    } else {
                        if state {
                            self.action.send(.presentActivityRating(recommendation: recommendation))
                        } else {
                            self.updateActivityRecommendation(recommendation, rating: 0, sent: true)
                        }
                    }
                }
                .store(in: &subscription)
        } else {
            if state {
                self.action.send(.presentActivityRating(recommendation: recommendation))
            } else {
                self.updateActivityRecommendation(recommendation, rating: 0)
            }
        }
    }
    // MARK: Handle recommendation
    public func handleRecommendation(recommendation: Recommendation, state: Bool) {
        if self.networkMonitor.isReachable {
            self.state.send(.loading)
            
            let acceptancePublisher: AnyPublisher<DataResponse<RecommendationResource, NetworkError>, Never> = self.networkManager.request(
                Endpoint.recommendationUpdate(id: recommendation.id).url,
                method: .put,
                parameters: ["type": 2, "acceptance": state]
            )
            
            acceptancePublisher
                .sink { dataResponse in
                    if let error = dataResponse.error {
                        self.state.send(.error(error))
                    } else {
                        if state {
                            self.updateSport(sportId: recommendation.sport_id)
                            self.action.send(.presentRatingView(recommendation: recommendation))
                        } else {
                            self.action.send(.checkRecommendations(withLoading: false))
                        }
                    }
                }
                .store(in: &subscription)
        } else {
            self.action.send(.showAlert(title: "No internet connection", message: "Please connect your device to the internet to continue!"))
        }
    }
    
    // MARK: Activity rating
    private func handleActivityRating(rating: Int, recommendation: ActivityRecommendation) {
        if self.networkMonitor.isReachable, let uuid = recommendation.uuid?.uuidString {
            self.state.send(.loading)
            let ratingPublisher: AnyPublisher<DataResponse<RecommendationResource, NetworkError>, Never> = self.networkManager.request(
                Endpoint.activityUpdate.url,
                method: .put,
                parameters: ["type": 1, "rating": rating, "uuid": uuid]
            )
            
            ratingPublisher
                .sink { dataResponse in
                    if dataResponse.error != nil {
                        self.updateActivityRecommendation(recommendation, rating: Double(rating), sent: false)
                    } else {
                        self.updateActivityRecommendation(recommendation, rating: Double(rating), sent: true, with: true)
                        self.presentActivityAlert.send(true)
                    }
                }
                .store(in: &subscription)
        } else {
            self.updateActivityRecommendation(recommendation, rating: Double(rating), sent: false)
        }
    }
    
    // MARK: Handle rating
    private func handleRating(rating: Int, recommendation: Recommendation) {
        if self.networkMonitor.isReachable {
            self.state.send(.loading)
            let ratingPublisher: AnyPublisher<DataResponse<RecommendationResource, NetworkError>, Never> = self.networkManager.request(
                Endpoint.recommendationUpdate(id: recommendation.id).url,
                method: .put,
                parameters: ["type": 1, "rating": rating]
            )
            
            ratingPublisher
                .sink { dataResponse in
                    if let error = dataResponse.error {
                        self.state.send(.error(error))
                    } else {
                        self.checkRecommendations()
                        self.presentDoneAlert.send(true)
                    }
                }
                .store(in: &subscription)
        } else {
            self.action.send(.showAlert(title: "No internet connection", message: "Please connect your device to the internet to continue!"))        }
    }
    
    // MARK: Update local sport
    private func updateSport(sportId: Int64?) {
        guard let sportId = sportId else {
            return
        }

        if let user = self.userManager.currentUser.value {
            let sports = self.sportManager.currentSports.value
            
            if let currentSport = sports.first(where: { $0.id == sportId }) {
                self.sportManager.appendSportToUser(user: user, sport: currentSport)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            self.state.send(.error(error))
                        }
                    } receiveValue: { _ in
                        self.sportManager.fetchCurrentSports()
                    }
                    .store(in: &subscription)
            }
        }
    }
    
    // MARK: ViewModels
    func createSportRecommendationCellViewModel(recommendation: Recommendation) -> SportRecommendationCellViewModel {
        SportRecommendationCellViewModel(type: recommendation.type, sport: recommendation.sport)
    }
    
    func createActivityRecommendationCellViewModel(recommendation: ActivityRecommendation) -> ActivityRecommendationViewModel {
        ActivityRecommendationViewModel(created_at: recommendation.created_at ?? Date(), start_time: recommendation.start_time ?? Date(), end_time: recommendation.end_time ?? Date(), sport: recommendation.sport)
    }
}

extension DashboardViewModel {
    private func syncLocalRecommendations(recommendations: [ActivityRecommendation]) {
        if networkMonitor.isReachable {
            let recommendationsPublisher: AnyPublisher<DataResponse<EmptySuccessResponse, NetworkError>, Never> = self.networkManager.request(
                Endpoint.recommendation.url,
                method: .post,
                parameters: Helpers.getJSON(arr: recommendations)
            )
            
            recommendationsPublisher
                .sink { dataResponse in
                    if dataResponse.error == nil {
                        if dataResponse.value != nil {
                            self.recommendationsManager.updateSyncRecommendations(rec: recommendations)
                        }
                    }
                }
                .store(in: &subscription)
        }
    }
    
    
    // MARK: Download new sports
    private func downloadNewSports() {
        let sportsPublisher: AnyPublisher<DataResponse<[SportResource], NetworkError>, Never> = self.networkManager.request(
            Endpoint.sports.url,
            method: .get
        )
        
        sportsPublisher
            .sink { dataResponse in
                if dataResponse.error == nil {
                    if let newSports = dataResponse.value {
                        self.saveNewSports(sports: newSports)
                    }
                }
            }
            .store(in: &subscription)
    }
    
    private func saveNewSports(sports: [SportResource]) {
        let currentSports = self.sportManager.currentSports.value
        
        for sport in sports {
            if let dbSport = currentSports.first(where: {$0.id == sport.id}) {
                if dbSport.name != sport.name || dbSport.met != sport.met || dbSport.type != sport.type || dbSport.healthKitType != sport.health_kit_type || dbSport.weather != sport.weather {
                    self.sportManager.updateOneSport(sportToUpdate: sport, currSport: dbSport)
                        .sink { _ in
                            ()
                        } receiveValue: { _ in
                            ()
                        }
                        .store(in: &subscription)
                }
            } else {
                self.sportManager.saveSports(newSports: [sport])
                    .sink { _ in
                        ()
                    } receiveValue: { _ in
                        ()
                    }
                    .store(in: &subscription)
            }
        }
        
        for sport in currentSports {
            let isIn = sports.contains(where: { $0.id == sport.id })
            if !isIn || sport.name == "HealthKit" {
                self.sportManager.hideSports(sport: sport)
                    .sink { _ in
                        ()
                    } receiveValue: { _ in
                        ()
                    }
                    .store(in: &subscription)
            }
        }
        
        self.sportManager.fetchCurrentSports()
    }

}

extension DashboardViewModel {
    private func updateActivityRecommendation(_ rec: ActivityRecommendation, rating: Double, sent: Bool = false, with: Bool = false) {
        self.recommendationsManager.updateRecommendation(rec: rec, rating: rating, sent: sent)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { _ in
                self.recommendationsManager.fetchCurrentRecommendations()
                if !with {
                    self.action.send(.checkRecommendations(withLoading: false))
                } else {
                    self.checkRecommendations()
                }
            }
            .store(in: &self.subscription)
    }
}
