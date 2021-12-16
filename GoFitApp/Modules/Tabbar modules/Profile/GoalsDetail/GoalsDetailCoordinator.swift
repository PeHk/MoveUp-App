import Combine
import Foundation
import UIKit

class GoalsDetailCoordinator: NSObject, Coordinator {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .goalsDetail }
    
    var childCoordinators: [Coordinator] = []
    
    var subscription = Set<AnyCancellable>()
    
    var viewModel: GoalsDetailViewModel {
        let viewModel = GoalsDetailViewModel(dependencyContainer)
        return viewModel
    }
    
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("GoalsDetailViewModel deinit")
    }
    
    func start() {
        let viewController: GoalsDetailViewController = .instantiate()
        viewController.viewModel = viewModel
        viewController.coordinator = self
        
        viewController.viewModel.stepper
            .sink { [weak self] event in
                self?.finish()
            }
            .store(in: &subscription)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
