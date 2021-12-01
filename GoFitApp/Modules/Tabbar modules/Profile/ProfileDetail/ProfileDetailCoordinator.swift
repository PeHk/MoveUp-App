import Combine
import Foundation
import UIKit

class ProfileDetailCoordinator: NSObject, Coordinator {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .profileDetail }
    
    var childCoordinators: [Coordinator] = []
    
    var subscription = Set<AnyCancellable>()
    
    var viewModel: ProfileDetailViewModel {
        let viewModel = ProfileDetailViewModel(dependencyContainer)
        return viewModel
    }
    
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("ProfileDetailViewModel deinit")
    }
    
    func start() {
        let viewController: ProfileDetailViewController = .instantiate()
        viewController.hidesBottomBarWhenPushed = true
        viewController.viewModel = viewModel
        viewController.coordinator = self
        
        viewController.viewModel.stepper
            .sink { [weak self] event in
                
            }
            .store(in: &subscription)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
