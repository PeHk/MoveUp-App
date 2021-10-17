//
//  ViewModelProtocol.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import Foundation
import UIKit
import Combine

protocol ViewModelProtocol {
    associatedtype State
    associatedtype Action
    associatedtype Step
    
    var action: PassthroughSubject<Action, Never> { get }
    var stepper: PassthroughSubject<Step, Never> { get }
//    var errorState: PassthroughSubject<ServerError, Never> { get set }
    
    var state: CurrentValueSubject<State, Never> { get }
    var isLoading: CurrentValueSubject<Bool, Never> { get set }
    
    var subscription: Set<AnyCancellable> { get set }
    
    func processState(_ state: State) -> Void
    func processAction(_ action: Action) -> Void
    func initializeView() -> Void
}
