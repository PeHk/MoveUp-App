import Combine
import UIKit

class ProfileDetailViewController: BaseTableViewController {
        
    var viewModel: ProfileDetailViewModel!
    weak var coordinator: ProfileDetailCoordinator!
    
    private var subscription = Set<AnyCancellable>()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.errorState
            .compactMap( { $0 })
            .assign(to: \.errorState, on: self)
            .store(in: &subscription)
    
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
        
        viewModel.currentUser
            .sink { _ in
                self.tableView.reloadData()
            }
            .store(in: &subscription)
    }
}
