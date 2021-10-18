//
//  DetailsCoordinator.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import Foundation
import UIKit
import Combine

final class DetailsCoordinator: Coordinator  {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .details }
    
    var childCoordinators: [Coordinator] = []
    
    var subscription = Set<AnyCancellable>()
    
    var detailsViewModel: DetailsViewModel {
        let detailsViewModel = DetailsViewModel(dependencyContainer)
        return detailsViewModel
    }
        
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("Details deinit")
    }
        
    func start() {
        let detailsViewController: DetailsViewController = .instantiate()
        detailsViewController.viewModel = detailsViewModel
        detailsViewController.coordinator = self
        
        detailsViewController.viewModel.stepper
            .sink { [weak self] _ in
                self?.finish()
            }
            .store(in: &subscription)
        
        navigationController.pushViewController(detailsViewController, animated: true)
    }
}
