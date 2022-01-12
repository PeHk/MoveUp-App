import Combine
import Foundation

class ActivityViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        
    }
    
    enum Step {
        case startActivity
    }
    
    enum State {
        case initial
        case loading
        case error(_ error: NetworkError)
    }
    
    // MARK: Actions and States
    func processAction(_ action: Action) {
        return
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
    
    var activities = CurrentValueSubject<[Activity], Never>([])
    
    var configuration: Configuration
    var subscription = Set<AnyCancellable>()
    
    fileprivate let activityManager: ActivityManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.configuration = Configuration(.activities)
        self.activityManager = dependencyContainer.activityManager
        
        action.sink(receiveValue: { [weak self] action in
            self?.processAction(action)
        })
            .store(in: &subscription)
        
        state.sink(receiveValue: { [weak self] state in
            self?.processState(state)
        })
            .store(in: &subscription)
        
        self.activityManager.currentActivities
            .sink { activities in
                self.activities.send(activities)
            }
            .store(in: &subscription)
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    // MARK: ViewModels
    func createActivityHistoryCellViewModel(activity: Activity) -> ActivityHistoryCellViewModel {
        ActivityHistoryCellViewModel(name: activity.name ?? "None", duration: activity.duration, calories: activity.calories)
    }
}
