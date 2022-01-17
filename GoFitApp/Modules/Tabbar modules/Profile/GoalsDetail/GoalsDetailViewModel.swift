import Combine
import Foundation
import Alamofire

class GoalsDetailViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case showMinutes
        case showCalories
        case showSteps
        case saveSteps(_ steps: Int)
        case saveCalories(_ calories: Int)
        case saveMinutes(_ minutes: Int)
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
        case .saveCalories(let calories):
            self.changeCalories(calories: calories)
        case .saveMinutes(let minutes):
            self.changeMinutes(minutes: minutes)
        case .saveSteps(let steps):
            self.changeSteps(steps: steps)
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
    var steps: Int
    var calories: Int
    var minutes : Int = 0
    var state = CurrentValueSubject<State, Never>(.initial)
    var action = PassthroughSubject<Action, Never>()
    var stepper = PassthroughSubject<Step, Never>()
    var errorState = PassthroughSubject<NetworkError, Never>()
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    var reloadTableView = CurrentValueSubject<Bool, Never>(true)
    
    var subscription = Set<AnyCancellable>()
    var currentUser = CurrentValueSubject<User?, Never>(nil)

    fileprivate let userDefaultsManager: UserDefaultsManager
    fileprivate let healthKitManager: HealthKitManager
    fileprivate let networkManager: NetworkManager
    fileprivate let userManager: UserManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.userDefaultsManager = dependencyContainer.userDefaultsManager
        self.healthKitManager = dependencyContainer.healthKitManager
        self.networkManager = dependencyContainer.networkManager
        self.userManager = dependencyContainer.userManager
        
        self.steps = self.userDefaultsManager.get(forKey: Constants.stepsGoal) as? Int ?? 10000
        self.calories = self.userDefaultsManager.get(forKey: Constants.caloriesGoal) as? Int ?? 800
        
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
                self.getLastActiveMinutes()
            }
            .store(in: &subscription)
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    // MARK: Actions
    private func changeSteps(steps: Int) {
        self.state.send(.loading)
        self.steps = steps
        self.userDefaultsManager.set(value: steps, forKey: Constants.stepsGoal)
        self.healthKitManager.refreshValues()
        self.isLoading.send(false)
        self.reloadTableView.send(true)
    }
    
    // MARK: Change calories
    private func changeCalories(calories: Int) {
        self.state.send(.loading)
        self.calories = calories
        self.userDefaultsManager.set(value: calories, forKey: Constants.caloriesGoal)
        self.healthKitManager.refreshValues()
        self.isLoading.send(false)
        self.reloadTableView.send(true)
    }
    
    // MARK: Change minutes
    private func changeMinutes(minutes: Int) {
        self.state.send(.loading)
        
        let model = BioDataResource(activity_minutes: Int64(minutes))
        
        let request: AnyPublisher<DataResponse<BioDataResource, NetworkError>, Never> = self.networkManager.request(
            Endpoint.userDetails.url,
            method: .post,
            parameters: model.getActivityMinutesUpdateJSON()
        )
        
        request
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    self.updateUser(details: dataResponse.value!)
                }
            }
            .store(in: &subscription)
    }
    
    // MARK: Update user
    private func updateUser(details: BioDataResource) {
        self.userManager.saveBioData(data: details)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { _ in
                self.userManager.fetchCurrentUser()
                self.isLoading.send(false)
                self.reloadTableView.send(true)
            }
            .store(in: &subscription)
    }
    
    private func getLastActiveMinutes() {
        if let user = self.currentUser.value {
            var bioData: [BioData]? = user.bio_data?.toArray()
            
            if bioData != nil {
                bioData!.sort {
                    $0.id < $1.id
                }
            }
            
            self.minutes = Int(bioData?.last?.activity_minutes ?? 200)
            print(minutes)
        }
    }
}
