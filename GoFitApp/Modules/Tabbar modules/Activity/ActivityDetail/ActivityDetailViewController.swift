import Combine
import UIKit

class ActivityDetailViewController: BaseViewController {
    
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var heartbeatLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
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
    
    private var subscription = Set<AnyCancellable>()
    
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
        self.viewModel.action.send(.start)
    }
    
    private func setupBindings() {
        viewModel.errorState
            .compactMap( { $0 })
            .assign(to: \.errorState, on: self)
            .store(in: &subscription)
        
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
        
        
        viewModel.$timeString
            .sink { time in
                self.timeLabel.text = time
            }
            .store(in: &subscription)
    }
    
    @objc func stopTapped(_ sender: UITapGestureRecognizer) {
        self.viewModel.action.send(.stop)
    }
}
