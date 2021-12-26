import Combine
import Foundation
import UIKit

class ActivityDetailCoordinator: NSObject, Coordinator {
    // MARK: Variables
    let dependencyContainer: DependencyContainer
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var type: CoordinatorType { .activityDetail }
    var childCoordinators: [Coordinator] = []
    var subscription = Set<AnyCancellable>()
    var sport: Sport
    
    var viewModel: ActivityDetailViewModel {
        let viewModel = ActivityDetailViewModel(dependencyContainer, sport: sport)
        return viewModel
    }
    
    // MARK: Init
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer, sport: Sport) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        self.sport = sport
    }
    
    deinit {
        print("ActivityDetailViewModel deinit")
    }
    
    // MARK: Start
    func start() {
        let viewController: ActivityDetailViewController = .instantiate()
        viewController.viewModel = viewModel
        viewController.coordinator = self
        
        viewController.viewModel.stepper
            .sink { [weak self] event in
                switch event {
                case .endActivity:
                    self?.finish()
                }
            }
            .store(in: &subscription)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
