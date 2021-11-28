import Combine
import Foundation

class SetCaloriesViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        
    }
    
    enum Step {
        case save
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
    internal var state = CurrentValueSubject<State, Never>(.initial)
    internal var action = PassthroughSubject<Action, Never>()
    internal var stepper = PassthroughSubject<Step, Never>()
    internal var errorState = PassthroughSubject<NetworkError, Never>()
    internal var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    internal var subscription = Set<AnyCancellable>()
    
    var currentUser = CurrentValueSubject<User?, Never>(nil)
    
    private let userManager: UserManager
    
    let increaseNumber = 10
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.userManager = dependencyContainer.userManager
        
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
            }
            .store(in: &subscription)
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
}
