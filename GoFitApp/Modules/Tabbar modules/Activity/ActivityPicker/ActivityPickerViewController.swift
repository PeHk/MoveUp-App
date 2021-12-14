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


extension ActivityPickerViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.value.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections.value[section].sectionName
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections.value[section].sectionItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ActivityTableViewCell.reuseIdentifier(), for: indexPath) as? ActivityTableViewCell {
            let sport = viewModel.sections.value[indexPath.section].sectionItems[indexPath.row]
            
            let cellViewModel = viewModel.createActivityCellViewModel(sport: sport)
            
            cell.viewModel = cellViewModel
            
            return cell
        } else {
            fatalError("Unexpected kind")
        }
    }
}
