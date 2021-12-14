import Combine
import UIKit

class ActivityPickerViewController: BaseTableViewController {
    
    var viewModel: ActivityPickerViewModel!
    weak var coordinator: ActivityPickerCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func setupView() {
        
    }
    
    private func setupBindings() {
        
    }
}


extension ActivityPickerViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section]
    }
}
