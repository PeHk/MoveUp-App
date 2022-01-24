import Combine
import Foundation
import Alamofire

class BackupDetailViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case backup
        case reload
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
        case .reload:
            self.checkActivities()
        case .backup:
            return
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
    var reloadTableView = PassthroughSubject<Bool, Never>()
    var backupDate: String = "Not yet"
    
    fileprivate let userDefaultsManager: UserDefaultsManager
    fileprivate let networkManager: NetworkManager
    fileprivate let activityManager: ActivityManager
    
    var subscription = Set<AnyCancellable>()
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.userDefaultsManager = dependencyContainer.userDefaultsManager
        self.networkManager = dependencyContainer.networkManager
        self.activityManager = dependencyContainer.activityManager
        
        action.sink(receiveValue: { [weak self] action in
            self?.processAction(action)
        })
            .store(in: &subscription)
        
        state.sink(receiveValue: { [weak self] state in
            self?.processState(state)
        })
            .store(in: &subscription)
        
        self.getBackupDate()
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    private func getBackupDate() {
        let backup: Date? = self.userDefaultsManager.get(forKey: Constants.backupDate) as? Date
        
        if backup != nil {
            self.backupDate = Helpers.getTimeAndDateFormatted(from: backup!)
        }
    }
    
    private func checkActivities() {
        let statusPublisher: AnyPublisher<DataResponse<LastUpdatedActivityResource, NetworkError>, Never> = self.networkManager.request(
            Endpoint.activityStatus.url,
            method: .get
        )
        
        statusPublisher
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    if let value = dataResponse.value {
                        var serverDate = Helpers.getDateFromStringWithout(from: value.last_activity_update)
                        serverDate = Calendar.current.date(byAdding: .hour, value: 1, to: serverDate) ?? serverDate
                        print("[server_date: \(serverDate)]")
                        let activities = self.activityManager.fetchMissingActivities(serverDate: serverDate)
                        print("[activities_count: \(activities.count)]")
                        
                        guard activities.count > 0 else {
                            self.userDefaultsManager.setNewBackupDate()
                            self.getBackupDate()
                            self.reloadTableView.send(true)
                            self.isLoading.send(false)
                            return
                        }
                        
                        self.fetchFoundedActivities(workouts: Helpers.getJSONFromActivityResourceArray(array: activities))
                    }
                }
            }
            .store(in: &subscription)
    }
    
    private func fetchFoundedActivities(workouts: [String: Any]) {
        let activityPublisher: AnyPublisher<DataResponse<[ActivityResource], NetworkError>, Never> = self.networkManager.request(
            Endpoint.activity.url,
            method: .post,
            parameters: workouts
        )
        
        activityPublisher
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    self.userDefaultsManager.setNewBackupDate()
                    self.getBackupDate()
                    self.reloadTableView.send(true)
                    self.isLoading.send(false)
                }
            }
            .store(in: &subscription)
    }
}
