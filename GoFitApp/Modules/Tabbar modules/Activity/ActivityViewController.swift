import Combine
import UIKit
import EmptyDataSet_Swift

class ActivityViewController: BaseTableViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    
    var viewModel: ActivityViewModel!
    weak var coordinator: ActivityCoordinator!
    
    private var subscription = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.action.send(.checkActivities)
    }

    private func setupView() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.emptyDataSetView { [weak self] view in
            if self != nil {
                view.titleLabelString(self?.viewModel.configuration.titleString)
                    .detailLabelString(self?.viewModel.configuration.detailString)
                    .image(nil)
                    .isScrollAllowed(true)
                    .verticalOffset(-150)
            }
        }
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
    
    @objc func addTapped() {
        self.viewModel.stepper.send(.startActivity)
    }
}
