import Combine
import Foundation
import Alamofire

class FavouriteSportsViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case saveSports(_ sports: [Sport])
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
        case .saveSports(let sports):
            updateSports(sports: sports)
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
    
    public var sports = CurrentValueSubject<[Sport], Never>([])
    public var user = CurrentValueSubject<User?, Never>(nil)
    
    private let networkManager: NetworkManager
    private let userManager: UserManager
    private let sportManager: SportManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.networkManager = dependencyContainer.networkManager
        self.userManager = dependencyContainer.userManager
        self.sportManager = dependencyContainer.sportManager
        
        action.sink(receiveValue: { [weak self] action in
            self?.processAction(action)
        })
            .store(in: &subscription)
        
        state.sink(receiveValue: { [weak self] state in
            self?.processState(state)
        })
            .store(in: &subscription)
        
        self.sportManager.currentSports
            .sink { sports in
                self.sports.send(sports)
            }
            .store(in: &subscription)
        
        self.userManager.currentUser
            .sink { user in
                self.user.send(user)
            }
            .store(in: &subscription)
    }
    
    internal func initializeView() {
        isLoading.send(false)
        fetchSports()
    }
    
    // MARK: Functions
    private func fetchSports() {
        self.state.send(.loading)
        
        let fetchRequest: AnyPublisher<DataResponse<[SportResource], NetworkError>, Never> = self.networkManager.request(
            Endpoint.sports.url,
            withInterceptor: false
        )
        
        fetchRequest
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    self.saveSportsToCoreData(sports: dataResponse.value!)
                }
            }
            .store(in: &subscription)

    }
    
    private func saveSportsToCoreData(sports: [SportResource]) {
        self.sportManager.saveSports(newSports: sports)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { _ in
                self.isLoading.send(false)
                self.sportManager.fetchCurrentSports()
            }
            .store(in: &subscription)
    }
    
    private func updateSports(sports: [Sport]) {
        self.state.send(.loading)
        
        var ids: [Int64] = []
        
        for sport in sports {
            ids.append(sport.id)
        }
        
        let updateRequest: AnyPublisher<DataResponse<UserResource, NetworkError>, Never> = self.networkManager.request(
            Endpoint.sports.url,
            method: .post,
            parameters: ["ids": ids]
        )
        
        updateRequest
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    self.updateUser(sports: sports)
                }
            }
            .store(in: &subscription)
    }
    
    private func updateUser(sports: [Sport]) {
        if let currentUser = user.value {
            self.sportManager.saveSportToUser(user: currentUser, sports: sports)
                .sink { completion in
                    if case .failure(let error) = completion {
                        self.state.send(.error(error))
                    }
                } receiveValue: { _ in
                    self.isLoading.send(false)
                    self.stepper.send(.save)
                }
                .store(in: &subscription)
        }
    }
    
    // MARK: ViewModels
    func createSportCellViewModel(sport: Sport) -> SportCellViewModel {
        SportCellViewModel(isSelected: false, name: sport.name ?? "")
    }
}
