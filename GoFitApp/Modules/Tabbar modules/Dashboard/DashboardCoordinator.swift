import Combine
import Foundation
import UIKit

class DashboardCoordinator: NSObject, Coordinator {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .dashboard }
    
    var childCoordinators: [Coordinator] = []
    
    var subscription = Set<AnyCancellable>()
    
    var viewModel: DashboardViewModel {
        let viewModel = DashboardViewModel(dependencyContainer)
        return viewModel
    }
    
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("DashboardViewModel deinit")
    }
    
    func start() {
        // Uncomment for using navigationbar back button
        // navigationController.delegate = self
        let viewController: DashboardViewController = .instantiate()
        viewController.viewModel = viewModel
        viewController.coordinator = self
        
        viewController.viewModel.stepper
            .sink { [weak self] event in
                self?.finish()
            }
            .store(in: &subscription)
        
        navigationController.setViewControllers([viewController], animated: false)
    }
}

// Uncomment for navigation bar
//extension DashboardCoordinator: CoordinatorFinishDelegate {
//    func coordinatorDidFinish(childCoordinator: Coordinator) {
//        childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
//        switch childCoordinator.type {
//        case .TODO:
//
//        default:
//            break
//        }
//    }
//}
//
//extension DashboardCoordinator: UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
//            return
//        }
//
//        if navigationController.viewControllers.contains(fromViewController) {
//            return
//        }
//    }
//}
