import Combine
import UIKit

class SetCaloriesViewController: UIViewController {
    
    @IBOutlet weak var setButton: PrimaryButton!
    var viewModel: SetCaloriesViewModel!
    var coordinator: SetCaloriesCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func setupView() {
        
    }
    
    private func setupBindings() {
        
    }
    
    @IBAction func setButtonTapped(_ sender: Any) {
        viewModel.stepper.send(.save)
    }
}
