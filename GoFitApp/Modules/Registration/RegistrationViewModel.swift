//
//  RegistrationViewModel.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import Foundation
import Combine
import SwiftyBase64
import Alamofire

final class RegistrationViewModel: ViewModelProtocol {

    // MARK: - Enums
    enum Action {
        case signUpButton
    }
    
    enum Step {
        case signUp
    }
    
    enum State {
        case initial
        case loading
        case error(_ error: NetworkError)
    }
    
    // MARK: Actions and States
    func processAction(_ action: Action) {
        switch action {
        case .signUpButton:
            signUpButtonTapped()
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
    internal let state = CurrentValueSubject<State, Never>(.initial)
    internal var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    internal let action = PassthroughSubject<Action, Never>()
    internal let stepper = PassthroughSubject<Step, Never>()
    internal var errorState = PassthroughSubject<NetworkError, Never>()
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    @Published var email: String = ""
    
    internal var subscription = Set<AnyCancellable>()
    
    private let networkManager: NetworkManager
    private let registrationManager: RegistrationManager
    private let userManager: UserManager

    // MARK: Lifecycle
    init(_ dependencyContainer: DependencyContainer) {
        self.networkManager = dependencyContainer.networkManager
        self.registrationManager = dependencyContainer.registrationManager
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
    
    private(set) lazy var isPasswordSame = Publishers.CombineLatest($password, $repeatPassword)
        .map { $0.count < 5 || $1.count < 5 || $0 != $1 }
        .eraseToAnyPublisher()
    
    private(set) lazy var isInputValid = Publishers.CombineLatest($email, $username)
        .map { $0.count < 2 || $1.count < 3 || !Validators.textFieldValidatorEmail($0) }
        .eraseToAnyPublisher()
    
    // MARK: Actions
    private func signUpButtonTapped() {
        self.state.send(.loading)
        
        let model = SignUpRequestModel(email: email, name: username, password: password)
        
        self.registrationManager.registration(withForm: model)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { user in
                self.saveUser(user: user)
            }
            .store(in: &subscription)
    }
    
    private func saveUser(user: UserResource) {
        self.userManager.deleteUser()
            .zip(self.userManager.saveUser(newUser: user))
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { _, _ in
                self.userManager.fetchCurrentUser()
                self.isLoading.send(false)
                self.stepper.send(.signUp)
            }
            .store(in: &subscription)
    }
}
