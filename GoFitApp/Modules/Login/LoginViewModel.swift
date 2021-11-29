//
//  LoginViewModel.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import Foundation
import Combine

final class LoginViewModel: ViewModelProtocol {

    // MARK: - Enums
    enum Action {
        case loginTapped
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
        
    }
    
    func processState(_ state: State) {
        
    }
    
    // MARK: - Variables
    internal let state = CurrentValueSubject<State, Never>(.initial)
    internal var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    internal let action = PassthroughSubject<Action, Never>()
    internal let stepper = PassthroughSubject<Step, Never>()
    internal var errorState = PassthroughSubject<NetworkError, Never>()
    
    internal var subscription = Set<AnyCancellable>()
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    private(set) lazy var isInputValid = Publishers.CombineLatest($email, $password)
        .map { $0.count < 2 || $1.count < 3 || Validators.textFieldValidatorEmail($0) }
        .eraseToAnyPublisher()

    init(_ dependencyContainer: DependencyContainer) {
        action
            .sink(receiveValue: { [weak self] action in
                self?.processAction(action)
            })
            .store(in: &subscription)
        
        state
            .sink(receiveValue: { [weak self] state in
                self?.processState(state)
            })
            .store(in: &subscription)
    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
}
