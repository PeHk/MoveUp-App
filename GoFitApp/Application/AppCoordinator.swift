//
//  AppCoordinator.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import UIKit
import Combine

final class AppCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var type: CoordinatorType { .app }
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var subscription = Set<AnyCancellable>()
    
    let dependencyContainer: DependencyContainer

    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    func start() {
        showHomePage()
    }
    
    func showHomePage(_ fromInterceptor: Bool = false) {
        let homeCoordinator = HomeCoordinator(navigationController, dependencyContainer)
        homeCoordinator.finishDelegate = self
        homeCoordinator.start()
        childCoordinators.append(homeCoordinator)
    }
    
//    func showTabBar() {
//        let tabBarCoordinator = TabBarCoordinator(navigationController, dependencyContainer)
//        tabBarCoordinator.finishDelegate = self
//        tabBarCoordinator.start()
//        childCoordinators.append(tabBarCoordinator)
//    }
//
//    func showLogin() {
//        let downloadCoordinator = DownloadCoordinator(navigationController, dependencyContainer)
//        downloadCoordinator.finishDelegate = self
//        downloadCoordinator.start()
//        childCoordinators.append(downloadCoordinator)
//    }
//
//    func showRegistration() {
//        let downloadCoordinator = DownloadCoordinator(navigationController, dependencyContainer)
//        downloadCoordinator.finishDelegate = self
//        downloadCoordinator.start()
//        childCoordinators.append(downloadCoordinator)
//    }
}

extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
        switch childCoordinator.type {
//        case .tab:
//            navigationController.viewControllers.removeAll()
//
//            showHomePage()
//        case .animation:
//            navigationController.viewControllers.removeAll()
//
//            showTutorial()
//        case .tutorial:
//            navigationController.viewControllers.removeAll()
//
//            showHomePage()
//        case .home:
//            navigationController.viewControllers.removeAll()
//
//            showDownloadPage()
//        case .download:
//            navigationController.viewControllers.removeAll()
//
//            showTabBar()
        default:
            break
        }
    }
}
