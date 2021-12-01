import Combine
import Foundation
import UIKit

class ProfileCoordinator: NSObject, Coordinator {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .profile }
    
    var childCoordinators: [Coordinator] = []
    
    var subscription = Set<AnyCancellable>()
    
    var viewModel: ProfileViewModel {
        let viewModel = ProfileViewModel(dependencyContainer)
        return viewModel
    }
    
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("ProfileViewModel deinit")
    }
    
    func start() {
        navigationController.delegate = self
        let viewController: ProfileViewController = .instantiate()
        viewController.viewModel = viewModel
        viewController.coordinator = self
        
        viewController.viewModel.stepper
            .sink { [weak self] event in
                switch event {
                case .profile:
                    self?.showProfile()
                case .logout:
                    self?.finish()
                }
            }
            .store(in: &subscription)
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showProfile() {
        let profileDetailCoordinator = ProfileDetailCoordinator(navigationController, dependencyContainer)
        profileDetailCoordinator.finishDelegate = self
        profileDetailCoordinator.start()
        childCoordinators.append(profileDetailCoordinator)
    }
}

extension ProfileCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
        
        switch childCoordinator.type {
        case .profileDetail:
            navigationController.popViewController(animated: true)
        default:
            break
        }
    }
}

extension ProfileCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }

        if navigationController.viewControllers.contains(fromViewController) {
            return
        }
        
        if let profileDetailController = fromViewController as? ProfileDetailViewController {
            if let coordinator = profileDetailController.coordinator {
                coordinatorDidFinish(childCoordinator: coordinator)
            }
        }
    }
}
