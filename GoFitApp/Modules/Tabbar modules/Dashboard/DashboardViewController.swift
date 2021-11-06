import Combine
import UIKit
import ALProgressView

class DashboardViewController: UITableViewController {
    
    @IBOutlet weak var stepsRing: ALProgressRing!
    @IBOutlet weak var caloriesView: UIView!
    @IBOutlet weak var stepsView: UIView!
    var viewModel: DashboardViewModel!
    var coordinator: DashboardCoordinator!
    
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
        caloriesView.layer.cornerRadius = 10
        stepsView.layer.cornerRadius = 10
        
        stepsRing.startColor = .secondary
        stepsRing.endColor = .primary
        stepsRing.setProgress(0.9, animated: true)
    }
    
    private func setupBindings() {
        
    }
}
