import Combine
import UIKit

class ActivityHistoryDetailViewController: UIViewController {
    
    var viewModel: ActivityHistoryDetailViewModel!
    var coordinator: ActivityHistoryDetailCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func setupView() {
        self.title = viewModel.activity.name
    }
    
    private func setupBindings() {
        
    }
}
