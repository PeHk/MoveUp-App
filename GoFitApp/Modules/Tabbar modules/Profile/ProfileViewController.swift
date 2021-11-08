import Combine
import UIKit

class ProfileViewController: UITableViewController {
    
    var viewModel: ProfileViewModel!
    var coordinator: ProfileCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupView() {
        
    }
    
    private func setupBindings() {
        
    }
}
