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
    internal var isLoading = CurrentValueSubject<Bool, Never>(false)
    internal var errorState = PassthroughSubject<NetworkError, Never>()
    internal let action = PassthroughSubject<Action, Never>()
    internal let stepper = PassthroughSubject<Step, Never>()
    internal let state = CurrentValueSubject<State, Never>(.initial)
    
    internal var subscription = Set<AnyCancellable>()
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    fileprivate let loginManager: LoginManager
    fileprivate let userManager: UserManager
    fileprivate let permissionManager: PermissionManager
    fileprivate let sportManager: SportManager
    fileprivate let activityManager: ActivityManager
    
    private(set) lazy var isInputValid = Publishers.CombineLatest($email, $password)
        .map { $0.count < 2 || $1.count < 3 || !Validators.textFieldValidatorEmail($0) }
        .eraseToAnyPublisher()

    // MARK: Init
    init(_ dependencyContainer: DependencyContainer) {
        self.loginManager = dependencyContainer.loginManager
        self.userManager = dependencyContainer.userManager
        self.permissionManager = dependencyContainer.permissionManager
        self.sportManager = dependencyContainer.sportManager
        self.activityManager = dependencyContainer.activityManager
        
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
                    self.state.send(.error(error))
                }
            } receiveValue: { user in
                self.saveUser(user: user)
            }
            .store(in: &subscription)
    }
    
    // MARK: Save user
    private func saveUser(user: UserResource) {
        self.userManager.deleteUser()
            .zip(self.sportManager.saveSports(newSports: user.sports ?? []))
            .zip(self.userManager.saveUserWithBioData(newUser: user))
            .zip(self.activityManager.saveActivities(newActivities: user.activities ?? []))
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { _, _ in
                self.activityManager.fetchCurrentActivities()
                self.userManager.fetchCurrentUser()
                self.sportManager.fetchCurrentSports()
                self.saveFavouriteSports(sports: user.favourite_sports ?? [])
            }
            .store(in: &subscription)
    }
    
    // MARK: Favourite sports
    private func saveFavouriteSports(sports: [SportResource]) {
        self.userManager.updateUserFavouriteSports(sports: sports)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { _ in
                self.action.send(.permissionsShowed)
            }
            .store(in: &subscription)
    }
    
    // MARK: Show healthkit permissions
    private func showHealthKit() {
        self.loginManager.registerForPushNotifications()
        self.permissionManager.authorizeHealthKit { success in
            DispatchQueue.main.async {
                self.isLoading.send(false)
                self.stepper.send(.login)
            }
        }
    }
}
