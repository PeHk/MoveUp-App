import Combine
import Foundation
import Alamofire

class ActivityViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        
    }
    
    enum Step {
        case startActivity
        case showActivityHistory(activity: Activity)
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
    fileprivate let networkManager: NetworkManager
    fileprivate let sportsManager: SportManager
    fileprivate let userDefaultsManager: UserDefaultsManager
    fileprivate let userManager: UserManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.configuration = Configuration(.activities)
        self.activityManager = dependencyContainer.activityManager
        self.networkManager = dependencyContainer.networkManager
        self.userManager = dependencyContainer.userManager
        self.sportsManager = dependencyContainer.sportManager
        self.userDefaultsManager = dependencyContainer.userDefaultsManager
        
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
                
                let sections: [ActivitySectionData] = keys.map{ ActivitySectionData(sectionIndexName: $0, sectionName: $0, sectionItems: grouppedActivities[$0]!.sorted(by: { Helpers.getTimeFromDate(from: $0.end_date ?? Date()) > Helpers.getTimeFromDate(from: $1.end_date ?? Date())
                }))}
                
                
                self.sections.send(sections)
            }
            .store(in: &subscription)
        
        self.checkActivities()
        self.fetchSports()
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    private func checkActivities() {
        let statusPublisher: AnyPublisher<DataResponse<LastUpdatedActivityResource, NetworkError>, Never> = self.networkManager.request(
            Endpoint.activityStatus.url,
            method: .get
        )
        
        statusPublisher
            .sink { dataResponse in
                if dataResponse.error == nil {
                    if let value = dataResponse.value {
                        var serverDate = Helpers.getDateFromStringWithout(from: value.last_activity_update)
                        serverDate = Calendar.current.date(byAdding: .hour, value: 1, to: serverDate) ?? serverDate
                        print("[server_date: \(serverDate)]")
                        let activities = self.activityManager.fetchMissingActivities(serverDate: serverDate)
                        print("[activities_count: \(activities.count)]")
                        
                        guard activities.count > 0 else {
                            self.userDefaultsManager.setNewBackupDate()
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
                if dataResponse.error == nil {
                    self.userDefaultsManager.set(value: Date(), forKey: Constants.backupDate)
                }
            }
            .store(in: &subscription)
    }
    
    private func fetchSports() {
        let dateToStart: Date? = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        
        guard dateToStart != nil else { return }
        var date: Date = self.userDefaultsManager.get(forKey: Constants.sportBackupDate) as? Date ?? dateToStart!
        
        date = Calendar.current.date(byAdding: .minute, value: -60, to: date) ?? date
        let resource = SportUpdateResource(date: date)
        
        let sportsPublisher: AnyPublisher<DataResponse<[SportResource], NetworkError>, Never> = self.networkManager.request(
            Endpoint.sportsStatus.url,
            method: .post,
            parameters: resource.getDateJSON()
        )
        
        print(resource.getDateJSON())
        
        sportsPublisher
            .sink { dataResponse in
                if dataResponse.error == nil {
                    if let sports = dataResponse.value {
                        guard sports.count > 0 else {
                            self.userDefaultsManager.setNewSportBackupDate()
                            return
                        }
                        
                        self.sportsManager.saveSports(newSports: sports)
                            .sink { _ in
                                ()
                            } receiveValue: { _ in
                                self.userDefaultsManager.setNewSportBackupDate()
                                self.sportsManager.fetchCurrentSports()
                            }
                            .store(in: &self.subscription)
                    }
                }
            }
            .store(in: &subscription)
    }

    // MARK: ViewModels
    func createActivityHistoryCellViewModel(activity: Activity) -> ActivityHistoryCellViewModel {
        ActivityHistoryCellViewModel(name: activity.name ?? "None", duration: activity.duration, calories: activity.calories)
    }
}
