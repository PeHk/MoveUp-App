import Combine
import Foundation
import UIKit

class ProfileCoordinator: NSObject, Coordinator {
    // MARK: Variables
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
    
    // MARK: Init
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("ProfileViewModel deinit")
    }
    
    // MARK: Start
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
                case .sports:
                    self?.showSports()
                case .goals:
                    self?.showGoals()
                default:
                    return
                }
            }
            .store(in: &subscription)
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    // MARK: Modules
    private func showProfile() {
        let profileDetailCoordinator = ProfileDetailCoordinator(navigationController, dependencyContainer)
        profileDetailCoordinator.finishDelegate = self
        profileDetailCoordinator.start()
        childCoordinators.append(profileDetailCoordinator)
    }
    
    private func showSports() {
        let sportsDetailCoordinator = FavouriteSportsDetailCoordinator(navigationController, dependencyContainer)
        sportsDetailCoordinator.finishDelegate = self
        sportsDetailCoordinator.start()
        childCoordinators.append(sportsDetailCoordinator)
    }
    
    private func showGoals() {
        let goalsDetailCoordinator = GoalsDetailCoordinator(navigationController, dependencyContainer)
        goalsDetailCoordinator.finishDelegate = self
        goalsDetailCoordinator.start()
        childCoordinators.append(goalsDetailCoordinator)
    }
}

// MARK: Navigation controller extensions
extension ProfileCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
        
        switch childCoordinator.type {
        case .profileDetail:
            navigationController.popViewController(animated: true)
        case .sportsDetail:
            navigationController.popViewController(animated: true)
        case .goalsDetail:
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
        } else if let sportsDetailController = fromViewController as? FavouriteSportsDetailViewController {
            if let coordinator = sportsDetailController.coordinator {
                coordinatorDidFinish(childCoordinator: coordinator)
            }
        } else if let goalsDetailController = fromViewController as? GoalsDetailViewController {
            if let coordinator = goalsDetailController.coordinator {
                coordinatorDidFinish(childCoordinator: coordinator)
            }
        }
    }
}
