import Combine
import UIKit
import ALProgressView

class DashboardViewController: UITableViewController {
    
    @IBOutlet weak var caloriesRing: ALProgressRing!
    @IBOutlet weak var stepsRing: ALProgressRing!
    @IBOutlet weak var caloriesView: UIView!
    @IBOutlet weak var stepsView: UIView!
    var viewModel: DashboardViewModel!
    weak var coordinator: DashboardCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.sizeToFit()
    }
    
    private func setupView() {
        caloriesView.layer.cornerRadius = 10
        stepsView.layer.cornerRadius = 10
        
        stepsRing.startColor = Asset.secondary.color
        caloriesRing.startColor = Asset.secondary.color
        
        stepsRing.endColor = Asset.primary.color
        caloriesRing.endColor = Asset.primary.color
        
        stepsRing.setProgress(0.9, animated: true)
        caloriesRing.setProgress(0.4, animated: true)
    }
    
    private func setupBindings() {
        
    }
}
