import Combine
import Foundation
import UIKit

class SetActiveMinutesCoordinator: NSObject, Coordinator {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .setActiveMinutes }
    
    var childCoordinators: [Coordinator] = []
    
    var subscription = Set<AnyCancellable>()
    
    var viewModel: SetActiveMinutesViewModel {
        let viewModel = SetActiveMinutesViewModel(dependencyContainer)
        return viewModel
    }
    
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("SetActiveMinutesViewModel deinit")
    }
    
    func start() {
        let viewController: SetActiveMinutesViewController = .instantiate()
        viewController.viewModel = viewModel
        viewController.coordinator = self
        
        viewController.viewModel.stepper
            .sink { [weak self] event in
                switch event {
                case .save:
                    self?.finish()
                }
            }
            .store(in: &subscription)
        
        self.navigationController.setViewControllers([viewController], animated: false)
    }
}
