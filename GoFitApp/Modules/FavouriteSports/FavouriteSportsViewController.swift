import Combine
import UIKit

class FavouriteSportsViewController: BaseTableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var saveButton: PrimaryButton!
    var viewModel: FavouriteSportsViewModel!
    weak var coordinator: FavouriteSportsCoordinator!
    
    private var subscription = Set<AnyCancellable>()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupViews()
    }
    
    private func setupViews() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//        self.navigationController?.navigationBar.sizeToFit()
//        
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//    
    // MARK: Bindings
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
    
    // MARK: Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        var items: [Int64] = []
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                items.append(viewModel.sports.value[indexPath.row].id)
            }
        }
        
        viewModel.action.send(.saveSports(items))
    }
}
