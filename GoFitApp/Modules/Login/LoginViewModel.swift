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
        case login
    }
    
    enum State {
        case initial
        case loading
        case error(_ error: NetworkError)
    }
    
    // MARK: Actions and States
    func processAction(_ action: Action) {
        switch action {
        case .loginTapped:
            self.loginTapped()
        }
    }
    
    func processState(_ state: State) {
        switch state {
        case .initial:
            self.initializeView()
        case .loading:
            self.isLoading.send(true)
        case .error(let error):
            self.isLoading.send(false)
            self.errorState.send(error)
        }
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
    
    fileprivate let loginManager: LoginManager
    fileprivate let userManager: UserManager
    
    private(set) lazy var isInputValid = Publishers.CombineLatest($email, $password)
        .map { $0.count < 2 || $1.count < 3 || !Validators.textFieldValidatorEmail($0) }
        .eraseToAnyPublisher()

    // MARK: Init
    init(_ dependencyContainer: DependencyContainer) {
        self.loginManager = dependencyContainer.loginManager
        self.userManager = dependencyContainer.userManager
        
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
    
    // MARK: Actions
    private func loginTapped() {
        self.state.send(.loading)
        
        self.loginManager.login(email: email, password: password)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error)
                    self.state.send(.error(error))
                }
            } receiveValue: { user in
                self.saveUser(user: user)
            }
            .store(in: &subscription)
    }
    
    private func saveUser(user: UserDataResource) {
        self.userManager.deleteUser()
            .zip(self.userManager.saveUserWithData(newUser: user))
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            } receiveValue: { _, _ in
                self.userManager.fetchCurrentUser()
                self.isLoading.send(false)
                self.stepper.send(.login)
            }
            .store(in: &subscription)
    }
}
