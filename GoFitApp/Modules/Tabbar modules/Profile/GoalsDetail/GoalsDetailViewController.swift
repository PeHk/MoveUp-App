import Combine
import UIKit

class GoalsDetailViewController: BaseTableViewController {
    
    // MARK: Variables
    var viewModel: GoalsDetailViewModel!
    weak var coordinator: GoalsDetailCoordinator!
    
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
        
        viewModel.reloadTableView
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.tableView.reloadData()
            }
            .store(in: &subscription)
    }
}
