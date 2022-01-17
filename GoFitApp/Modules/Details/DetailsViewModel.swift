//
//  DetailsViewModel.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import Foundation
import Combine
import Alamofire

final class DetailsViewModel: ViewModelProtocol {

    // MARK: - Enums
    enum Action {
        case saveTapped
        case permissionsShowed
        case healthKitPermissions
    }
    
    enum Step {
        case save
    }
    
    enum State {
        case initial
        case loading
        case error(_ error: NetworkError)
    }
    
    // MARK: Actions and States
    func processAction(_ action: Action) {
        switch action {
        case .saveTapped:
            saveTapped()
        case .permissionsShowed:
            return
        case .healthKitPermissions:
            showHealthKit()
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
    
    internal var subscription = Set<AnyCancellable>()
    
    fileprivate let networkManager: NetworkManager
    fileprivate let userManager: UserManager
    fileprivate let permissionManager: PermissionManager
    fileprivate let loginManager: LoginManager
    
    var availableGenders: [GenderResource?] = []
    
    @Published var height: String = ""
    @Published var weight: String = ""
    
    var selectedGender = CurrentValueSubject<GenderResource?, Never>(nil)
    var selectedDate = CurrentValueSubject<Date?, Never>(nil)
    var currentUser = CurrentValueSubject<User?, Never>(nil)
    
    private var alreadySent: Bool = false

    // MARK: Init
    init(_ dependencyContainer: DependencyContainer) {
        self.networkManager = dependencyContainer.networkManager
        self.userManager = dependencyContainer.userManager
        self.permissionManager = dependencyContainer.permissionManager
        self.loginManager = dependencyContainer.loginManager
        
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
        
        self.userManager.currentUser
            .sink { user in
                self.currentUser.send(user)
            }
            .store(in: &subscription)
    }
    
    internal func initializeView() {
        self.fetchGenders()
    }
    
    private(set) lazy var isInputValid = Publishers.CombineLatest($weight, $height)
        .map { $0.count < 1 || $1.count < 2 }
        .eraseToAnyPublisher()
    
    // MARK: Actions
    private func saveTapped() {
        if !alreadySent {
            updateUserDetails()
        } else {
            self.action.send(.permissionsShowed)
        }
    }
    
    private func fetchGenders() {
        isLoading.send(true)
        
        let genderRequest: AnyPublisher<DataResponse<[GenderResource], NetworkError>, Never> = networkManager.request(
            Endpoint.genders.url,
            withInterceptor: false
        )
        
        genderRequest
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    self.availableGenders = dataResponse.value!
                    self.isLoading.send(false)
                }
            }
            .store(in: &self.subscription)
    }
    
    private func updateUserDetails() {
        isLoading.send(true)
        
        let birthDate = Helpers.formatDate(from: selectedDate.value ?? Date())
        
        let updateRequest: AnyPublisher<DataResponse<UserResource, NetworkError>, Never> = networkManager.request(
            Endpoint.userDetails.url,
            method: .post,
            parameters: [
                "weight": Float(weight) ?? 0,
                "height": Float(height) ?? 0,
                "date_of_birth": birthDate,
                "gender": selectedGender.value?.value ?? "",
                "type": 2
            ]
        )
        
        updateRequest
            .sink { dataResponse in
                if let error = dataResponse.error {
                    self.state.send(.error(error))
                } else {
                    self.alreadySent = true
                    self.saveBioData(data: dataResponse.value!)
                }
            }
            .store(in: &self.subscription)
    }
    
    private func saveBioData(data: UserResource) {
        self.userManager.saveBioDataAfterRegistration(data: data)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state.send(.error(error))
                }
            } receiveValue: { _ in
                self.isLoading.send(false)
                self.action.send(.permissionsShowed)
            }
            .store(in: &subscription)
    }
    
    private func showHealthKit() {
        self.loginManager.registerForPushNotifications()
        
        self.permissionManager.authorizeHealthKit { success in
            DispatchQueue.main.async {
                self.stepper.send(.save)
            }
        }
    }
}
