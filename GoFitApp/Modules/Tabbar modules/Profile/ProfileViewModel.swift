import Combine
import Foundation
import UIKit

class ProfileViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case logout
        case support
    }
    
    enum Step {
        case logout
        case profile
        case sports
        case goals
        case notifications
    }
    
    enum State {
        case initial
        case loading
        case error(_ error: NetworkError)
    }
    
    // MARK: Actions and States
    func processAction(_ action: Action) {
        switch action {
        case .logout:
            self.logout()
        case .support:
            self.contactSupport()
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
    
    var subscription = Set<AnyCancellable>()
    
    fileprivate let logoutManager: LogoutManager
    fileprivate let userManager: UserManager
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.logoutManager = dependencyContainer.logoutManager
        self.userManager = dependencyContainer.userManager
        
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
    
    // MARK: Actions
    private func logout() {
        self.logoutManager.logout(false)
    }
    
    private func contactSupport() {
        if let url = URL(string: Constants.supportAddress) {
            UIApplication.shared.open(url)
        }
    }
}
