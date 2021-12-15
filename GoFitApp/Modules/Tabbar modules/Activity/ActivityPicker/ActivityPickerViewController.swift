import Combine
import UIKit

class ActivityPickerViewController: BaseTableViewController {
    
    var viewModel: ActivityPickerViewModel!
    weak var coordinator: ActivityPickerCoordinator!
    
    private var subscription = Set<AnyCancellable>()
    
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
        
        viewModel.sections
            .sink { _ in
                self.tableView.reloadData()
            }
            .store(in: &subscription)
    }
}
