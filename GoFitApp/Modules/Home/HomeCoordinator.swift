//
//  HomeCoordinator.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import Foundation
import UIKit
import Combine

final class HomeCoordinator: NSObject, Coordinator  {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .home }
    
    var childCoordinators: [Coordinator] = []
    
    var subscription = Set<AnyCancellable>()
    
    var fromCoordinator: CoordinatorType?
    
    var homeViewModel: HomeViewModel {
        let homeViewModel = HomeViewModel(dependencyContainer)
        return homeViewModel
    }
        
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("Home deinit")
    }
    
    private func showRegistration() {
        let registrationCoordinator = RegistrationCoordinator(navigationController, dependencyContainer)
        registrationCoordinator.finishDelegate = self
        registrationCoordinator.start()
        childCoordinators.append(registrationCoordinator)
    }
    
    private func showLogin() {
        let loginCoordinator = LoginCoordinator(navigationController, dependencyContainer)
        loginCoordinator.finishDelegate = self
        loginCoordinator.start()
        childCoordinators.append(loginCoordinator)
    }
    
    func start() {
        navigationController.delegate = self
        let homeViewController: HomeViewController = .instantiate()
        homeViewController.viewModel = homeViewModel
        
        homeViewController.viewModel.stepper
            .sink(receiveValue: { [weak self] event in
                switch event {
                case .getStarted:
                    self?.showRegistration()
                case .login:
                    self?.showLogin()
                }
            })
            .store(in: &subscription)
        
        navigationController.setViewControllers([homeViewController], animated: false)
    }
}

extension HomeCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })

        switch childCoordinator.type {
        case .registration:
            let coor = childCoordinator as! RegistrationCoordinator
            
            self.fromCoordinator = .registration
            
            if coor.registrationSuccessfull {
                self.finish()
                
                navigationController.setNavigationBarHidden(true, animated: true)
                navigationController.popViewController(animated: true)
            } else {
                navigationController.setNavigationBarHidden(true, animated: true)
                navigationController.popViewController(animated: true)
            }
        case .login:
            
            self.fromCoordinator = .login
            
            navigationController.setNavigationBarHidden(true, animated: true)
            navigationController.popViewController(animated: true)
        default:
            break
        }
    }
}

extension HomeCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }

        if navigationController.viewControllers.contains(fromViewController) {
            return
        }

        if let loginViewController = fromViewController as? LoginViewController {
            if let coordinator = loginViewController.coordinator {
                coordinatorDidFinish(childCoordinator: coordinator)
            }
        } else if let registrationViewController = fromViewController as? RegistrationViewController {
            if let coordinator = registrationViewController.coordinator {
                coordinatorDidFinish(childCoordinator: coordinator)
            }
        }
    }
}
