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
    
    private let networkManager: NetworkManager
    
    var availableGenders: [Gender?] = []
    
    @Published var height: String = ""
    @Published var weight: String = ""
    
    var selectedGender = CurrentValueSubject<Gender?, Never>(nil)
    var selectedDate = CurrentValueSubject<Date?, Never>(nil)
    
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
        self.fetchGenders()
    }
    
    private(set) lazy var isInputValid = Publishers.CombineLatest($weight, $height)
        .map { $0.count < 1 || $1.count < 2 }
        .eraseToAnyPublisher()
    
    // MARK: Actions
    private func saveTapped() {
        updateUserDetails()
    }
    
    private func fetchGenders() {
        isLoading.send(true)
        
        let genderRequest: AnyPublisher<DataResponse<[Gender], NetworkError>, Never> = networkManager.request(
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let birthDate = formatter.string(from: selectedDate.value ?? Date())
        
        let updateRequest: AnyPublisher<DataResponse<BioData, NetworkError>, Never> = networkManager.request(
            Endpoint.userDetails.url,
            method: .post,
            parameters: ["weight": Float(weight) ?? 0,
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
                    print(dataResponse.value!)
                    self.isLoading.send(false)
                    self.stepper.send(.save)
                }
            }
            .store(in: &self.subscription)
    }
}
