//
//  RegistrationViewModel.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import Foundation
import Combine

final class RegistrationViewModel: ViewModelProtocol {

    // MARK: - Enums
    enum Action {

    }
    
    enum Step {
        case signUp
    }
    
    enum State {
        case initial
        case loading
//        case error(_ error: ServerError)
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
//    internal var errorState = PassthroughSubject<ServerError, Never>()
    
    internal var subscription = Set<AnyCancellable>()

    
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
