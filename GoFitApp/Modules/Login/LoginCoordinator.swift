//
//  LoginCoordinator.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import Foundation
import UIKit
import Combine

final class LoginCoordinator: Coordinator  {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .login }
    
    var childCoordinators: [Coordinator] = []
    
    var loginSuccessfull: Bool = false
    
    var subscription = Set<AnyCancellable>()
    
    var loginViewModel: LoginViewModel {
        let loginViewModel = LoginViewModel(dependencyContainer)
        return loginViewModel
    }
        
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("Login deinit")
    }
        
    func start() {
        let loginViewController: LoginViewController = .instantiate()
        loginViewController.viewModel = loginViewModel
        loginViewController.coordinator = self
        
        loginViewController.viewModel.stepper
            .sink { [weak self] event in
                switch event {
                case .login:
                    self?.loginSuccessfull = true
                    self?.finish()
                }
            }
            .store(in: &subscription)
        
        navigationController.pushViewController(loginViewController, animated: true)
    }
}
