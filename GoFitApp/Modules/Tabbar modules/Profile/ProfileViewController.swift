import Combine
import UIKit

class ProfileViewController: BaseTableViewController {
    
    var viewModel: ProfileViewModel!
    weak var coordinator: ProfileCoordinator!
    
    private var subscription = Set<AnyCancellable>()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func setupView() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    private func setupBindings() {
        viewModel.errorState
            .compactMap( { $0 })
            .assign(to: \.errorState, on: self)
            .store(in: &subscription)
        
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
        
    }
}
