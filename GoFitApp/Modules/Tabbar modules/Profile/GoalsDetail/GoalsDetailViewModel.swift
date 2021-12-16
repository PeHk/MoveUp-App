import Combine
import Foundation

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
    var state = CurrentValueSubject<State, Never>(.initial)
    var action = PassthroughSubject<Action, Never>()
    var stepper = PassthroughSubject<Step, Never>()
    var errorState = PassthroughSubject<NetworkError, Never>()
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    var reloadTableView = CurrentValueSubject<Bool, Never>(true)
    
    var subscription = Set<AnyCancellable>()
    
    let userDefaultsManager: UserDefaultsManager
    let healthKitManager: HealthKitManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.userDefaultsManager = dependencyContainer.userDefaultsManager
        self.healthKitManager = dependencyContainer.healthKitManager
        
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
    
    private func changeCalories(calories: Int) {
        self.state.send(.loading)
        self.calories = calories
        self.userDefaultsManager.set(value: calories, forKey: Constants.caloriesGoal)
        self.healthKitManager.refreshValues()
        self.isLoading.send(false)
        self.reloadTableView.send(true)
    }
    
    private func changeMinutes(minutes: Int) {
        
    }
}
