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
    
    var sections = CurrentValueSubject<[ActivitySectionData], Never>([])
    
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
                let grouppedActivities = Dictionary(grouping: activities, by: { Helpers.printDate(from: $0.end_date ?? Date()) })
                
                let keys = grouppedActivities.keys.sorted(by: >)
                
                let sections: [ActivitySectionData] = keys.map{ ActivitySectionData(sectionIndexName: $0, sectionName: $0, sectionItems: grouppedActivities[$0]!)}
                
                
                self.sections.send(sections)
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
