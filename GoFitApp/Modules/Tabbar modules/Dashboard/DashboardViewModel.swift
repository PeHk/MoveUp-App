import Combine
import Foundation

class DashboardViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case update
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
    var steps = CurrentValueSubject<Double, Never>(0)
    var calories = CurrentValueSubject<Double, Never>(0)
    
    var configuration: Configuration
    var subscription = Set<AnyCancellable>()
    
    let healthKitManager: HealthKitManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.configuration = Configuration(.recommendations)
        self.healthKitManager = dependencyContainer.healthKitManager
        
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
            }
            .store(in: &subscription)
        
        self.healthKitManager.calories
            .sink { calories in
                self.calories.send(calories)
            }
            .store(in: &subscription)
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    private func refreshValues() {
        self.healthKitManager.refreshValues()
    }
}
