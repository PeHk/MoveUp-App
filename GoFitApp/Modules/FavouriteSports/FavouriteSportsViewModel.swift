import Combine
import Foundation
import Alamofire

class FavouriteSportsViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case saveSports(_ sports: [Int64])
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
    
    public var sports = CurrentValueSubject<[SportResource], Never>([])
    
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
    }
    
    internal func initializeView() {
        isLoading.send(false)
        fetchSports()
    }
    
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
                    self.sports.value = dataResponse.value!
                    self.saveSportsToCoreData(sports: dataResponse.value!)
                    self.isLoading.send(false)
                    
                }
            }
            .store(in: &subscription)

    }
    
    private func saveSportsToCoreData(sports: [SportResource]) {
        for sport in sports {
            self.sportManager.saveSport(newSport: sport)
                .sink { _ in
                    ()
                } receiveValue: { _ in
                    ()
                }
                .store(in: &subscription)
        }
        
        self.sportManager.fetchCurrentSports()
    }
    
    private func updateSports(sports: [Int64]) {
        self.state.send(.loading)
        
        let updateRequest: AnyPublisher<DataResponse<UserSportsResource, NetworkError>, Never> = self.networkManager.request(
            Endpoint.sports.url,
            method: .post,
            parameters: ["ids": sports]
        )
        
        updateRequest
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    self.isLoading.send(false)
                    self.stepper.send(.save)
                }
            }
            .store(in: &subscription)
    }
    
    func createSportCellViewModel(sport: SportResource) -> SportCellViewModel {
        SportCellViewModel(isSelected: false, name: sport.name)
    }
}
