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

    // MARK: Lifecycle
    init(_ dependencyContainer: DependencyContainer) {
        self.networkManager = dependencyContainer.networkManager
        
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
        
        let registrationPublisher: AnyPublisher<DataResponse<User, NetworkError>, Never> = self.networkManager.request(
            Endpoint.registration.url,
            method: .post,
            parameters: ["name": username, "password": SwiftyBase64.EncodeString([UInt8](password.utf8)), "email": email],
            withInterceptor: false
        )
        
        registrationPublisher
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    print(dataResponse.value!)
                }
            }
            .store(in: &subscription)
    }
}
