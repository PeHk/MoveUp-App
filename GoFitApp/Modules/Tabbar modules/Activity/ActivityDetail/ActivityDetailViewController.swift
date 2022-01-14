import Combine
import UIKit

class ActivityDetailViewController: BaseViewController {
    
    @IBOutlet weak var pauseString: UILabel!
    @IBOutlet weak var pauseImage: UIImageView!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(pauseTapped(_:)))
            playView.addGestureRecognizer(tap)
            playView.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var stopView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(stopTapped(_:)))
            stopView.addGestureRecognizer(tap)
            stopView.isUserInteractionEnabled = true
        }
    }
    var viewModel: ActivityDetailViewModel!
    var coordinator: ActivityDetailCoordinator!
    
    private var isRunning = false
    private var subscription = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func setupView() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.title = viewModel.sport.name
        self.isRunning = true
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
        
        viewModel.$caloriesString
            .sink { calories in
                self.caloriesLabel.text = calories
            }
            .store(in: &subscription)
        
        viewModel.$distanceString
            .sink { distance in
                self.distanceLabel.text = distance
            }
            .store(in: &subscription)
    }
    
    private func changeIcon() {
        self.isRunning ? (self.pauseString.text = "Pause") : (self.pauseString.text = "Resume")
        self.isRunning ? (self.pauseImage.image = UIImage(systemName: "pause.fill")) :
        (self.pauseImage.image = UIImage(systemName: "play.fill"))
        
    }
    
    @objc func stopTapped(_ sender: UITapGestureRecognizer) {
        self.viewModel.action.send(.stop)
    }
    
    @objc func pauseTapped(_ sender: UITapGestureRecognizer) {
        self.isRunning ? self.viewModel.action.send(.pause) : self.viewModel.action.send(.resume)
        self.isRunning ? (self.isRunning = false) : (self.isRunning = true)
        self.changeIcon()
    }
}
