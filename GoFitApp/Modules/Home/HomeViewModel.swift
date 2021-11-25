//
//  HomeViewModel.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import Foundation
import Combine
import Alamofire

final class HomeViewModel: ViewModelProtocol {

    // MARK: - Enums
    enum Action {

    }
    
    enum Step {
        case getStarted
        case login
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
    
    internal let networkManager: NetworkManager

    
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
        
        initializeView()
    }
    
    internal func initializeView() {
        isLoading.send(false)
        fetch()
        
    }
    
    struct Test: Decodable {
        let message: String
    }
    
    func fetch() {
        let t: AnyPublisher<DataResponse<Test, NetworkError>, Never> = networkManager.request(Endpoint.test.url)
        
        t.sink { (dataResponse) in
            if dataResponse.error != nil {
                print(dataResponse.error!)
            } else {
                print(dataResponse.value!)
            }
        }.store(in: &subscription)
            
    }
}
