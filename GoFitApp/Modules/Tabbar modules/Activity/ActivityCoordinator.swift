import Combine
import Foundation
import UIKit

class ActivityCoordinator: NSObject, Coordinator {
    // MARK: Variables
    let dependencyContainer: DependencyContainer
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var type: CoordinatorType { .activity }
    var childCoordinators: [Coordinator] = []
    var subscription = Set<AnyCancellable>()
    
    var viewModel: ActivityViewModel {
        let viewModel = ActivityViewModel(dependencyContainer)
        return viewModel
    }
    
    // MARK: Init
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("ActivityViewModel deinit")
    }
    
    // MARK: Start
    func start() {
        navigationController.delegate = self
        let viewController: ActivityViewController = .instantiate()
        viewController.viewModel = viewModel
        viewController.coordinator = self
        
        viewController.viewModel.stepper
            .sink { [weak self] event in
                switch event {
                case .startActivity:
                    self?.showActivityPicker()
                }
            }
            .store(in: &subscription)
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    // MARK: Modules
    private func showActivityPicker() {
        let activityPickerCoordinator = ActivityPickerCoordinator(navigationController, dependencyContainer)
        activityPickerCoordinator.finishDelegate = self
        activityPickerCoordinator.start()
        childCoordinators.append(activityPickerCoordinator)
    }
}

// MARK: Navigation extensions
extension ActivityCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
        
        switch childCoordinator.type {
        case .activityPicker:
            navigationController.popViewController(animated: true)
        default:
            break
        }
    }
}

extension ActivityCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }

        if navigationController.viewControllers.contains(fromViewController) {
            return
        }
        
        if let activityPickerController = fromViewController as? ActivityPickerViewController {
            if let coordinator = activityPickerController.coordinator {
                coordinatorDidFinish(childCoordinator: coordinator)
            }
        }
    }
}
