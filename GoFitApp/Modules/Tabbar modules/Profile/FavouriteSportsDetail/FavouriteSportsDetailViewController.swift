import Combine
import UIKit

class FavouriteSportsDetailViewController: BaseTableViewController {
    
    var viewModel: FavouriteSportsDetailViewModel!
    weak var coordinator: FavouriteSportsDetailCoordinator!
    
    private var subscription = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
    }
    
    private func setupViews() {
//        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    private func setupBindings() {
        viewModel.errorState
            .compactMap( { $0 })
            .assign(to: \.errorState, on: self)
            .store(in: &subscription)
        
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
        
        viewModel.sports
            .sink { _ in
                self.tableView.reloadData()
            }
            .store(in: &subscription)
    }
    
//    override func setEditing(_ editing: Bool, animated: Bool) {
//        super.setEditing(editing, animated: animated)
//        
//        tableView.setEditing(editing, animated: true)
//    }
}
