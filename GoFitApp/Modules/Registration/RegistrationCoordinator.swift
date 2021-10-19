//
//  RegistrationCoordinator.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import Foundation
import UIKit
import Combine

final class RegistrationCoordinator: Coordinator  {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .registration }
    
    var childCoordinators: [Coordinator] = []
    
    var registrationSuccessfull: Bool = false
    
    var subscription = Set<AnyCancellable>()
    
    var registrationViewModel: RegistrationViewModel {
        let registrationViewModel = RegistrationViewModel(dependencyContainer)
        return registrationViewModel
    }
        
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("Registration deinit")
    }
        
    func start() {
        let registrationViewController: RegistrationViewController = .instantiate()
        registrationViewController.viewModel = registrationViewModel
        registrationViewController.coordinator = self
        
        registrationViewController.viewModel.stepper
            .sink { [weak self] event in
                switch event {
                case .signUp:
                    self?.registrationSuccessfull = true
                    self?.finish()
                }
                
            }
            .store(in: &subscription)
        
        navigationController.pushViewController(registrationViewController, animated: true)
    }
}
