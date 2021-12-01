import Combine
import Foundation
import UIKit

class FavouriteSportsDetailCoordinator: NSObject, Coordinator {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .sportsDetail }
    
    var childCoordinators: [Coordinator] = []
    
    var subscription = Set<AnyCancellable>()
    
    var viewModel: FavouriteSportsDetailViewModel {
        let viewModel = FavouriteSportsDetailViewModel(dependencyContainer)
        return viewModel
    }
    
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("FavouriteSportsDetailViewModel deinit")
    }
    
    func start() {
        let viewController: FavouriteSportsDetailViewController = .instantiate()
        viewController.viewModel = viewModel
        viewController.coordinator = self
        
        viewController.viewModel.stepper
            .sink { [weak self] event in
                
            }
            .store(in: &subscription)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
