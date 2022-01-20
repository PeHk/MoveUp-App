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
    fileprivate let userManager: UserManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.configuration = Configuration(.activities)
        self.activityManager = dependencyContainer.activityManager
        self.networkManager = dependencyContainer.networkManager
        self.userManager = dependencyContainer.userManager
        
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
                if let error = dataResponse.error {
                    // TODO
                } else {
                    if let value = dataResponse.value {
                        let serverDate = Helpers.getDateFromStringWithout(from: value.last_activity_update)

                        let activities = self.activityManager.findMissingActivities(serverDate: serverDate)
                        
                        let object = try! JSONSerialization.data(withJSONObject: Helpers.getJSONFromActivityResourceArray(array: activities))
                        
                        print(object)
                    }
                    
                }
            }
            .store(in: &subscription)
    }
    
//    private func saveBackendWorkout(workouts: Data) {
//        let activityPublisher: AnyPublisher<DataResponse<[ActivityResource], NetworkError>, Never> = self.networkManager.request(
//            Endpoint.activity.url,
//            method: .post,
//            parameters: workouts
//        )
//
//
//        activityPublisher
//            .sink { dataResponse in
//                if let error = dataResponse.error {
////                    TODO
//                } else {
////                    TODO
//                }
//            }
//            .store(in: &subscription)
//    }
    
    // MARK: ViewModels
    func createActivityHistoryCellViewModel(activity: Activity) -> ActivityHistoryCellViewModel {
        ActivityHistoryCellViewModel(name: activity.name ?? "None", duration: activity.duration, calories: activity.calories)
    }
}
