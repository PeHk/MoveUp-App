import Combine
import Foundation
import Alamofire

class ProfileDetailViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case nameChange(_ name: String)
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
        case .nameChange(let name):
            self.changeName(name)
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
    
    var currentUser = CurrentValueSubject<User?, Never>(nil)
    
    var subscription = Set<AnyCancellable>()
    
    fileprivate let userManager: UserManager
    fileprivate let networkManager: NetworkManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.userManager = dependencyContainer.userManager
        self.networkManager = dependencyContainer.networkManager
        
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
    
    // MARK: Functions
    private func changeName(_ name: String) {
        self.state.send(.loading)
        let userName = UserResource(name: name)
        
        let updateRequest: AnyPublisher<DataResponse<UserResource, NetworkError>, Never> = self.networkManager.request(
            Endpoint.userDetails.url,
            method: .put,
            parameters: userName.nameJSON()
        )
        
        updateRequest
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    self.updateUser(name: name)
                }
            }
            .store(in: &subscription)
    }
    
    private func updateUser(name: String) {
        userManager.updateUserName(name: name)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { _ in
                self.userManager.fetchCurrentUser()
                self.isLoading.send(false)
            }
            .store(in: &subscription)
    }
}
