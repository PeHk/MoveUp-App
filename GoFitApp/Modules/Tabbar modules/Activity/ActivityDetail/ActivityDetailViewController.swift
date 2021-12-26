import Combine
import UIKit

class ActivityDetailViewController: UIViewController {
    
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var stopView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(stopTapped(_:)))
            stopView.addGestureRecognizer(tap)
            stopView.isUserInteractionEnabled = true
        }
    }
    var viewModel: ActivityDetailViewModel!
    var coordinator: ActivityDetailCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func setupView() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.hidesBackButton = true
        self.title = viewModel.sport.name
    }
    
    private func setupBindings() {
        
    }
    
    @objc func stopTapped(_ sender: UITapGestureRecognizer) {
        self.viewModel.stepper.send(.endActivity)
    }
}
