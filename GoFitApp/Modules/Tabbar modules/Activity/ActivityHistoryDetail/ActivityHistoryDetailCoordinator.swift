import Combine
import Foundation
import UIKit

class ActivityHistoryDetailCoordinator: NSObject, Coordinator {
    let dependencyContainer: DependencyContainer
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .historyDetail }
    
    var childCoordinators: [Coordinator] = []
    
    var subscription = Set<AnyCancellable>()
    
    var activity: Activity
    
    var viewModel: ActivityHistoryDetailViewModel {
        let viewModel = ActivityHistoryDetailViewModel(dependencyContainer, activity: activity)
        return viewModel
    }
    
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer, activity: Activity) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        self.activity = activity
    }
    
    deinit {
        print("ActivityHistoryDetailViewModel deinit")
    }
    
    func start() {
        let viewController: ActivityHistoryDetailViewController = .instantiate()
        viewController.viewModel = viewModel
        viewController.coordinator = self
        
        viewController.viewModel.stepper
            .sink { event in
                
            }
            .store(in: &subscription)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
