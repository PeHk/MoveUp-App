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
        case permissionsShowed
        case healthKitPermissions
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
        case .permissionsShowed:
            return
        case .healthKitPermissions:
            showHealthKit()
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
    fileprivate let permissionManager: PermissionManager
    fileprivate let sportManager: SportManager
    
    private(set) lazy var isInputValid = Publishers.CombineLatest($email, $password)
        .map { $0.count < 2 || $1.count < 3 || !Validators.textFieldValidatorEmail($0) }
        .eraseToAnyPublisher()

    // MARK: Init
    init(_ dependencyContainer: DependencyContainer) {
        self.loginManager = dependencyContainer.loginManager
        self.userManager = dependencyContainer.userManager
        self.permissionManager = dependencyContainer.permissionManager
        self.sportManager = dependencyContainer.sportManager
        
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
        
        let model = UserResource(email: email, password: password)
        
        self.loginManager.login(withForm: model)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error)
                    self.state.send(.error(error))
                }
            } receiveValue: { user in
                self.saveSportsToCoreData(user: user, sports: user.sports)
            }
            .store(in: &subscription)
    }
    
    private func saveUser(user: UserResource) {
        self.userManager.deleteUser()
            .zip(self.userManager.saveUserWithData(newUser: user))
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { _, _ in
                self.userManager.fetchCurrentUser()
                self.isLoading.send(false)
                self.action.send(.permissionsShowed)
            }
            .store(in: &subscription)
    }
    
    private func saveSportsToCoreData(user: UserResource, sports: [SportResource]?) {
        if let allSports = sports {
            for sport in allSports {
                self.sportManager.saveSport(newSport: sport)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            self.state.send(.error(error))
                        }
                    } receiveValue: { _ in
                        ()
                    }
                    .store(in: &subscription)
            }
        }
        
        self.sportManager.fetchCurrentSports()
        self.saveUser(user: user)
    }
    
    private func showHealthKit() {
        self.permissionManager.authorizeHealthKit { success in
            DispatchQueue.main.async {
                self.stepper.send(.login)
            }
        }
    }
}
