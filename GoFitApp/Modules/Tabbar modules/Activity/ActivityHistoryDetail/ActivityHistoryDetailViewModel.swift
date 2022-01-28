import Combine
import Foundation
import CoreLocation
import UIKit

class ActivityHistoryDetailViewModel: ViewModelProtocol {
    
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
    
    var subscription = Set<AnyCancellable>()
    
    @Published var coordinates: [CLLocationCoordinate2D] = []
    
    public var hideMapSection: Bool = false
    public let activity: Activity
    public let edges = UIEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0)
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer, activity: Activity) {
        self.activity = activity
        
        if WorkoutType(rawValue: self.activity.sport?.type ?? "") == .indoor || activity.externalType != false {
            self.hideMapSection = true
        }
        
        coordinates = Helpers.getCoreLocationObjects(from: activity)
        
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
    }
}
