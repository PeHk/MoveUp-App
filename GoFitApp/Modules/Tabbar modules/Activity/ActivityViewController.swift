import Combine
import UIKit

class ActivityViewController: UITableViewController {
    
    var viewModel: ActivityViewModel!
    weak var coordinator: ActivityCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }

    private func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    private func setupBindings() {
        
    }
    
    @objc func addTapped() {
        
    }
}
