//
//  AppCoordinator.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import UIKit
import Combine
import CloudKit

final class AppCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var type: CoordinatorType { .app }
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var subscription = Set<AnyCancellable>()
    
    let dependencyContainer: DependencyContainer
    let userDefaultsManager: UserDefaultsManager
    let logoutManager: LogoutManager

    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        self.userDefaultsManager = dependencyContainer.userDefaultsManager
        self.logoutManager = dependencyContainer.logoutManager
        
        navigationController.setNavigationBarHidden(true, animated: true)
        
        self.logoutManager.logoutCompleted
            .sink { state in
                self.logout(state)
            }
            .store(in: &subscription)
    }
    
    func start() {
        if userDefaultsManager.isLoggedIn() {
            showTabBar()
        } else {
            showHomePage()
        }
    }
    
    private func logout(_ fromInterceptor: Bool? = nil) {
        self.childCoordinators = []
        self.navigationController.viewControllers.removeAll()
        self.showHomePage(fromInterceptor)
    }
    
    private func showHomePage(_ fromInterceptor: Bool? = nil) {
        let homeCoordinator = HomeCoordinator(navigationController, dependencyContainer, fromInterceptor)
        homeCoordinator.finishDelegate = self
        homeCoordinator.start()
        childCoordinators.append(homeCoordinator)
    }
    
    private func showMoreDetails() {
        let detailsCoordinator = DetailsCoordinator(navigationController, dependencyContainer)
        detailsCoordinator.finishDelegate = self
        detailsCoordinator.start()
        childCoordinators.append(detailsCoordinator)
    }
    
    private func showSetActiveMinutes() {
        let setActiveMinutesCoordinator = SetActiveMinutesCoordinator(navigationController, dependencyContainer)
        setActiveMinutesCoordinator.finishDelegate = self
        setActiveMinutesCoordinator.start()
        childCoordinators.append(setActiveMinutesCoordinator)
    }
    
    private func showFavouriteSports() {
        let favouriteSportsCoordinator = FavouriteSportsCoordinator(navigationController, dependencyContainer)
        favouriteSportsCoordinator.finishDelegate = self
        favouriteSportsCoordinator.start()
        childCoordinators.append(favouriteSportsCoordinator)
    }
    
    private func showTabBar() {
        let tabBarCoordinator = TabBarCoordinator(navigationController, dependencyContainer)
        tabBarCoordinator.finishDelegate = self
        tabBarCoordinator.start()
        childCoordinators.append(tabBarCoordinator)
    }
}

extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
        switch childCoordinator.type {
        case .home:
            let coor = childCoordinator as! HomeCoordinator
            
            navigationController.viewControllers.removeAll()
            
            if coor.fromCoordinator == .registration {
                showMoreDetails()
            }
        case .favouriteSports:
            navigationController.viewControllers.removeAll()
            
            showTabBar()
        case .setActiveMinutes:
            navigationController.viewControllers.removeAll()
           
            showFavouriteSports()
        case .details:
            navigationController.viewControllers.removeAll()
            
            showSetActiveMinutes()
        case .tab:
            navigationController.viewControllers.removeAll()

            showHomePage()
        default:
            break
        }
    }
}
