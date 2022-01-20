import Combine
import Foundation
import UIKit

class BackupDetailCoordinator: NSObject, Coordinator {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .backup }
    
    var childCoordinators: [Coordinator] = []
    
    var subscription = Set<AnyCancellable>()
    
    var viewModel: BackupDetailViewModel {
        let viewModel = BackupDetailViewModel(dependencyContainer)
        return viewModel
    }
    
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("BackupDetailViewModel deinit")
    }
    
    func start() {
        let viewController: BackupDetailViewController = .instantiate()
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
