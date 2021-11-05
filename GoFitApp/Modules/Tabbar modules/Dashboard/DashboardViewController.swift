import Combine
import UIKit

class DashboardViewController: UITableViewController {
    
    @IBOutlet weak var caloriesView: UIView!
    @IBOutlet weak var stepsView: UIView!
    var viewModel: DashboardViewModel!
    var coordinator: DashboardCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func setupView() {
        caloriesView.layer.cornerRadius = 10
        stepsView.layer.cornerRadius = 10
    }
    
    private func setupBindings() {
        
    }
}
