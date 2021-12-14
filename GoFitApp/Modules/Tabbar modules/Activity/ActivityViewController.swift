import Combine
import UIKit
import EmptyDataSet_Swift

class ActivityViewController: UITableViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    
    var viewModel: ActivityViewModel!
    weak var coordinator: ActivityCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }

    private func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
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
        
    }
    
    @objc func addTapped() {
        self.viewModel.stepper.send(.startActivity)
    }
}
