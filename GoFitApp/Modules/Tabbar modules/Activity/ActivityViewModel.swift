import Combine
import Foundation
import Alamofire

class ActivityViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case checkActivities
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
        switch action {
        case .checkActivities:
            if networkMonitor.isReachable {
                self.downloadNewSports()
                self.checkActivities()
            }
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
    
    var sections = CurrentValueSubject<[ActivitySectionData], Never>([])
    
    var configuration: Configuration
    var subscription = Set<AnyCancellable>()
    
    fileprivate let activityManager: ActivityManager
    fileprivate let networkManager: NetworkManager
    fileprivate let sportsManager: SportManager
    fileprivate let userDefaultsManager: UserDefaultsManager
    fileprivate let userManager: UserManager
    fileprivate let networkMonitor: NetworkMonitor
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.configuration = Configuration(.activities)
        self.activityManager = dependencyContainer.activityManager
        self.networkManager = dependencyContainer.networkManager
        self.userManager = dependencyContainer.userManager
        self.sportsManager = dependencyContainer.sportManager
        self.userDefaultsManager = dependencyContainer.userDefaultsManager
        self.networkMonitor = dependencyContainer.networkMonitor
        
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
                
                let empty: [Date: [Activity]] = [:]
                let groupedByDate = activities.reduce(into: empty) { acc, cur in
                    let components = Calendar.current.dateComponents([.year, .month, .day], from: cur.end_date ?? Date())
                    let date = Calendar.current.date(from: components)!
                    let existing = acc[date] ?? []
                    acc[date] = existing + [cur]
                }
            
                let keys = groupedByDate.keys.sorted(by: >)
                
                let sections: [ActivitySectionData] = keys.map { ActivitySectionData(
                    sectionIndexName: Helpers.printDate(from: $0),
                    sectionName: Helpers.printDate(from: $0),
                    sectionItems: groupedByDate[$0]!.sorted(by: { Helpers.getTimeFromDate(from: $0.end_date ?? Date()) > Helpers.getTimeFromDate(from: $1.end_date ?? Date())
                }))}
                
                
                self.sections.send(sections)
            }
            .store(in: &subscription)
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    // MARK: Functions
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
    
    // MARK: Download new sports
    private func downloadNewSports() {
        let sportsPublisher: AnyPublisher<DataResponse<[SportResource], NetworkError>, Never> = self.networkManager.request(
            Endpoint.sports.url,
            method: .get
        )
        
        sportsPublisher
            .sink { dataResponse in
                if dataResponse.error == nil {
                    if let newSports = dataResponse.value {
                        self.saveNewSports(sports: newSports)
                    }
                }
            }
            .store(in: &subscription)
    }
    
    private func saveNewSports(sports: [SportResource]) {
        let currentSports = self.sportsManager.currentSports.value
        
        for sport in sports {
            if let dbSport = currentSports.first(where: {$0.id == sport.id}) {
                if dbSport.name != sport.name || dbSport.met != sport.met || dbSport.type != sport.type || dbSport.healthKitType != sport.health_kit_type {
                    self.sportsManager.updateOneSport(sportToUpdate: sport, currSport: dbSport)
                        .sink { _ in
                            ()
                        } receiveValue: { _ in
                            ()
                        }
                        .store(in: &subscription)
                }
            } else {
                self.sportsManager.saveSports(newSports: [sport])
                    .sink { _ in
                        ()
                    } receiveValue: { _ in
                        ()
                    }
                    .store(in: &subscription)
            }
        }
        
        self.sportsManager.fetchCurrentSports()
    }

    // MARK: ViewModels
    func createActivityHistoryCellViewModel(activity: Activity) -> ActivityHistoryCellViewModel {
        ActivityHistoryCellViewModel(name: activity.name ?? "None", duration: activity.duration, calories: activity.calories, external: activity.externalType)
    }
}
