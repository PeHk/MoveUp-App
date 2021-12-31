import Combine
import Foundation
import UIKit

class ActivityDetailViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case start
        case stop
    }
    
    enum Step {
        case endActivity
    }
    
    enum State {
        case initial
        case loading
        case error(_ error: NetworkError)
    }
    
    // MARK: Actions and States
    func processAction(_ action: Action) {
        switch action {
        case .start:
            self.startTimer()
        case .stop:
            self.stopTimer()
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
    var sport: Sport
    
    private var weight: Float = 0
    
    var currentUser = CurrentValueSubject<User?, Never>(nil)
    
    @Published var timeString = "00:00:00"
    @Published var caloriesString = "0 cal"
    
    var subscription = Set<AnyCancellable>()
    
    fileprivate let timerManager: TimerManager
    fileprivate let userManager: UserManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer, sport: Sport) {
        self.sport = sport
        self.timerManager = dependencyContainer.timerManager
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
                self.setWeight()
            }
            .store(in: &subscription)
        
        timerManager.$timeString.sink { time in
            self.timeString = time
            self.calculateCalories()
        }
        .store(in: &subscription)
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    // MARK: Actions
    private func setWeight() {
        if let user = currentUser.value {
            let bioDataArr: [BioData]? = user.bio_data?.toArray()
            
            weight = bioDataArr?.first?.weight ?? 0
        }
    }
    
    private func startTimer() {
        timerManager.startTimer()
    }
    
    private func stopTimer() {
        timerManager.stopTimer()
        self.stepper.send(.endActivity)
    }
    
    private func calculateCalories() {
        var calories = sport.met * 3.5 * weight / 200
        calories = calories / 60
        calories = calories * Float(timerManager.time)
        caloriesString = "\(String(format: "%.2f", calories)) cal"
    }
}
