import Combine
import Foundation
import Alamofire

class SetCaloriesViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case saveTapped(_ minutes: Int)
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
        switch action {
        case .saveTapped(let minutes):
            saveTapped(minutes: minutes)
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
    internal var state = CurrentValueSubject<State, Never>(.initial)
    internal var action = PassthroughSubject<Action, Never>()
    internal var stepper = PassthroughSubject<Step, Never>()
    internal var errorState = PassthroughSubject<NetworkError, Never>()
    internal var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    internal var subscription = Set<AnyCancellable>()
    
    var currentUser = CurrentValueSubject<User?, Never>(nil)
    
    private let userManager: UserManager
    private let networkManager: NetworkManager
    
    let increaseNumber = 10
    
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
    
    // MARK: Actions
    private func saveTapped(minutes: Int) {
        // TODO: Update minutes on user and on backend
        self.isLoading.send(true)
        let updateRequest: AnyPublisher<DataResponse<BioDataResource, NetworkError>, Never> = self.networkManager.request(
            Endpoint.userDetails.url,
            method: .post,
            parameters: ["type": 3, "activity_minutes": minutes]
        )
        
        updateRequest
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    self.updateBioData(data: dataResponse.value!)
                }
            }
            .store(in: &subscription)
    }
    
    private func updateBioData(data: BioDataResource) {
        if let user = currentUser.value {
            self.userManager.saveBioData(data: data, user: user)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(error)
                    }
                } receiveValue: { _ in
                    self.isLoading.send(false)
                    self.stepper.send(.save)
                }
                .store(in: &subscription)
        }
    }
}
