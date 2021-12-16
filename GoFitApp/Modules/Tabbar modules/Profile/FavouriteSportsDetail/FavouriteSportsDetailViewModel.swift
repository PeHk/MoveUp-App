import Combine
import Foundation

class FavouriteSportsDetailViewModel: ViewModelProtocol {
    
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
    var sports = CurrentValueSubject<[Sport], Never>([])
    var user = CurrentValueSubject<User?, Never>(nil)
    
    var subscription = Set<AnyCancellable>()
    
    let sportManager: SportManager
    let userManager: UserManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.sportManager = dependencyContainer.sportManager
        self.userManager = dependencyContainer.userManager
        
        action.sink(receiveValue: { [weak self] action in
            self?.processAction(action)
        })
            .store(in: &subscription)
        
        state.sink(receiveValue: { [weak self] state in
            self?.processState(state)
        })
            .store(in: &subscription)
        
        self.sportManager.currentSports
            .sink(receiveValue: { sports in
                self.sports.send(sports)
            })
            .store(in: &subscription)
        
        self.userManager.currentUser
            .sink(receiveValue: { user in
                self.user.send(user)
            })
            .store(in: &subscription)
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    func createActivityCellViewModel(sport: Sport) -> ActivityCellViewModel {
        ActivityCellViewModel(name: sport.name ?? "", id: sport.id, enableSelection: true)
    }
}
