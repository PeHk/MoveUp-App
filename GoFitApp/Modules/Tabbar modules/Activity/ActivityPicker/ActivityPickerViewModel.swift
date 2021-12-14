import Combine
import Foundation

class ActivityPickerViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        
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
    
    var subscription = Set<AnyCancellable>()
    
    let sportManager: SportManager
    
    var sections = CurrentValueSubject<[SectionData], Never>([])
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.sportManager = dependencyContainer.sportManager
        
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
        self.fetchSports()
    }
    
    private func fetchSports() {
        self.state.send(.loading)
        self.sportManager.currentSports
            .sink { _ in
                ()
            } receiveValue: { sports in
                self.sections.send([SectionData(sectionName: "All sports", sectionItems: sports)])
                self.isLoading.send(false)
            }
            .store(in: &subscription)

    }
    
    func createActivityCellViewModel(sport: Sport) -> ActivityCellViewModel {
        ActivityCellViewModel(name: sport.name ?? "", id: sport.id)
    }
}
