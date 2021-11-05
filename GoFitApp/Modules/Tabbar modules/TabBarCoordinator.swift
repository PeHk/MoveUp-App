//
//  TabBarCoordinator.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 20/10/2021.
//

import Foundation
import UIKit
import Combine

enum TabBarPage {
    case dashboard
    case profile
    case activity
    case history

    init?(index: Int) {
        switch index {
        case 0:
            self = .dashboard
        case 1:
            self = .activity
        case 2:
            self = .history
        case 3:
            self = .profile
        default:
            return nil
        }
    }
    
    func pageOrderNumber() -> Int {
        switch self {
        case .dashboard:
            return 0
        case .activity:
            return 1
        case .history:
            return 2
        case .profile:
            return 3
        }
    }
}


protocol TabBarCoordinatorProtocol: Coordinator {
    var tabBarController: UITabBarController { get set }
    
    func selectPage(_ page: TabBarPage)
    
    func setSelectedIndex(_ index: Int)
    
    func currentPage() -> TabBarPage?
}

class TabBarCoordinator: NSObject, Coordinator {
    let dependencyContainer: DependencyContainer
    
    var childCoordinators: [Coordinator] = []
    
    var subscription = Set<AnyCancellable>()
    
    weak var finishDelegate: CoordinatorFinishDelegate?

    var navigationController: UINavigationController
    
    var tabBarController: UITabBarController

    var type: CoordinatorType { .tab }
    
    required init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        self.tabBarController = .init()
    }

    func start() {
        // Let's define which pages do we want to add into tab bar
        let pages: [TabBarPage] = [.dashboard, .profile, .history, .activity]
            .sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
        
        // Initialization of ViewControllers or these pages
        let controllers: [UINavigationController] = pages.map({ getTabController($0) })
        
        prepareTabBarController(withTabControllers: controllers)
    }
    
    deinit {
        print("TabCoordinator deinit")
    }
    
    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        /// Assign page's controllers
        tabBarController.setViewControllers(tabControllers, animated: true)
        /// Let set index
        tabBarController.selectedIndex = TabBarPage.dashboard.pageOrderNumber()
        /// Styling
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .backgroundColor
            appearance.selectionIndicatorTintColor = .primary
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            tabBarController.tabBar.standardAppearance = appearance

        } else {
            tabBarController.tabBar.isTranslucent = false
            tabBarController.tabBar.tintColor = .primary
            tabBarController.tabBar.unselectedItemTintColor = .secondary
            tabBarController.tabBar.barTintColor = .backgroundColor
            tabBarController.tabBar.standardAppearance.shadowColor = nil
            tabBarController.tabBar.standardAppearance.shadowImage = nil
        }

        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = tabBarController.tabBar.standardAppearance
        }
        
        /// In this step, we attach tabBarController to navigation controller associated with this coordinator
        navigationController.viewControllers = [tabBarController]
    }
      
    private func getTabController(_ page: TabBarPage) -> UINavigationController {
        let navController = UINavigationController()
        
//        if #available(iOS 13.0, *) {
//            let appearence = UINavigationBarAppearance()
//            appearence.configureWithOpaqueBackground()
//            appearence.backgroundColor = .backgroundColor
//            appearence.shadowColor = nil
//            appearence.shadowImage = nil
//
//            navController.navigationBar.standardAppearance = appearence
//            navController.navigationBar.scrollEdgeAppearance = navController.navigationBar.standardAppearance
//        } else {
//            navController.navigationBar.shadowImage = nil
//            navController.navigationBar.shadowColor = nil
//            navController.navigationBar.isTranslucent = false
//            navController.navigationBar.barTintColor = .backgroundColor
//        }
//
        navController.navigationBar.tintColor = .primary
        navController.setNavigationBarHidden(true, animated: false)

        switch page {
        case .dashboard:
            let dashboardCoordinator = DashboardCoordinator(navController, dependencyContainer)
            dashboardCoordinator.finishDelegate = self
            dashboardCoordinator.start()
            childCoordinators.append(dashboardCoordinator)
            
        case .profile:
            let profileCoordinator = ProfileCoordinator(navController, dependencyContainer)
            profileCoordinator.finishDelegate = self
            profileCoordinator.start()
            childCoordinators.append(profileCoordinator)
        
        case .activity:
            let activityCoordinator = ActivityCoordinator(navController, dependencyContainer)
            activityCoordinator.finishDelegate = self
            activityCoordinator.start()
            childCoordinators.append(activityCoordinator)
            
        case .history:
            let historyCoordinator = HistoryCoordinator(navController, dependencyContainer)
            historyCoordinator.finishDelegate = self
            historyCoordinator.start()
            childCoordinators.append(historyCoordinator)
        }
        
        
        return navController
    }
    
    func currentPage() -> TabBarPage? { TabBarPage.init(index: tabBarController.selectedIndex) }

    func selectPage(_ page: TabBarPage) {
        tabBarController.selectedIndex = page.pageOrderNumber()
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = TabBarPage.init(index: index) else { return }
        
        tabBarController.selectedIndex = page.pageOrderNumber()
    }
}

extension TabBarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
        switch childCoordinator.type {
        case .profile:
            self.finish()
        default:
            break
        }
    }
}
