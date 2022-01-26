import Combine
import Foundation
import UIKit

class DashboardViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case update
        case checkPermissions
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
    
    var configuration: Configuration
    var subscription = Set<AnyCancellable>()
    
    let healthKitManager: HealthKitManager
    let userDefaultsManager: UserDefaultsManager
    let permissionManager: PermissionManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.configuration = Configuration(.recommendations)
        self.healthKitManager = dependencyContainer.healthKitManager
        self.userDefaultsManager = dependencyContainer.userDefaultsManager
        self.permissionManager = dependencyContainer.permissionManager
        
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
    
    private func refreshValues() {
        self.healthKitManager.refreshValues()
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
}
