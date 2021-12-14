import Combine
import Foundation
import UIKit

class ActivityPickerCoordinator: NSObject, Coordinator {
    // MARK: Variables
    let dependencyContainer: DependencyContainer
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var type: CoordinatorType { .activityPicker }
    var childCoordinators: [Coordinator] = []
    var subscription = Set<AnyCancellable>()
    
    var viewModel: ActivityPickerViewModel {
        let viewModel = ActivityPickerViewModel(dependencyContainer)
        return viewModel
    }
    
    // MARK: Init
    init(_ navigationController: UINavigationController, _ dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        print("ActivityPickerViewModel deinit")
    }
    
    // MARK: Start
    func start() {
        let viewController: ActivityPickerViewController = .instantiate()
        viewController.viewModel = viewModel
        viewController.coordinator = self
        
        viewController.viewModel.stepper
            .sink { [weak self] event in
                self?.finish()
            }
            .store(in: &subscription)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: Modules
}
