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
    
    func showRegistration() {
        
    }
    
    func start() {
        navigationController.delegate = self
        let homeViewController: HomeViewController = .instantiate()
        homeViewController.viewModel = homeViewModel
        
        homeViewController.viewModel.stepper
            .sink(receiveValue: { [weak self] _ in
                self?.finish()
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
            navigationController.setNavigationBarHidden(true, animated: true)
            navigationController.popViewController(animated: true)
        case .login:
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

//        if let registrationController = fromViewController as? RegistrationViewController {
//            if let coordinator = registrationController.coordinator {
//                coordinatorDidFinish(childCoordinator: coordinator)
//            }
//        } else if let connectionTypeController = fromViewController as? ConnectionTypeViewController {
//            if let coordinator = connectionTypeController.coordinator {
//                coordinatorDidFinish(childCoordinator: coordinator)
//            }
//        } else if let aboutPageController = fromViewController as? AboutPageViewController {
//            if let coordinator = aboutPageController.coordinator {
//                coordinatorDidFinish(childCoordinator: coordinator)
//            }
//        }
    }
}
