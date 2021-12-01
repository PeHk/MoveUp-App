import Combine
import UIKit

class ProfileDetailViewController: BaseTableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var genderCell: UITableViewCell!
    @IBOutlet weak var dateOfBirthCell: UITableViewCell!
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var nameCell: UITableViewCell!
    
    var viewModel: ProfileDetailViewModel!
    var coordinator: ProfileDetailCoordinator!
    
    private var subscription = Set<AnyCancellable>()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func setupView() {
        
    }
    
    private func setupBindings() {
        viewModel.errorState
            .compactMap( { $0 })
            .assign(to: \.errorState, on: self)
            .store(in: &subscription)
    
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
        
    
        viewModel.currentUser
            .sink { currentUser in
                if let user = currentUser {
                    self.emailCell.detailTextLabel?.text = user.email
                    self.dateOfBirthCell.detailTextLabel?.text = Helpers.printDate(from: user.date_of_birth ?? Date())
                    self.genderCell.detailTextLabel?.text = user.gender
                    self.nameCell.detailTextLabel?.text = user.name
                    
                }
            }
            .store(in: &subscription)
    }
}
