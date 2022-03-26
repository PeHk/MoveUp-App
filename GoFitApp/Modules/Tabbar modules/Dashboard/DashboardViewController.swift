import Combine
import UIKit
import ALProgressView
import ContentLoader
import EmptyDataSet_Swift

class DashboardViewController: BaseTableViewController, EmptyDataSetSource, ContentLoaderDataSource, EmptyDataSetDelegate {

    // MARK: Outlet
    @IBOutlet weak var caloriesRing: ALProgressRing! {
        didSet {
            caloriesRing.endColor = Asset.primary.color
            caloriesRing.startColor = Asset.secondary.color
        }
    }
    @IBOutlet weak var stepsRing: ALProgressRing! {
        didSet {
            stepsRing.startColor = Asset.secondary.color
            stepsRing.endColor = Asset.primary.color
        }
    }
    @IBOutlet weak var caloriesView: UIView! {
        didSet {
            caloriesView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var stepsView: UIView! {
        didSet {
            stepsView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    // MARK: Variables
    var viewModel: DashboardViewModel!
    weak var coordinator: DashboardCoordinator!
    
    var subscription = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.sizeToFit()
        self.viewModel.action.send(.update)
        self.viewModel.action.send(.checkWorkouts)
        self.viewModel.action.send(.checkRecommendations)
    }
    
    private func setupView() {
        navigationItem.leftBarButtonItem = nil
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.startLoading()
        
        tableView.emptyDataSetView { [weak self] view in
            if self != nil {
                view.titleLabelString(self?.viewModel.configuration.titleString)
                    .isScrollAllowed(true)
                    .detailLabelString(self?.viewModel.configuration.detailString)
            }
        }
    }
    
    private func setupBindings() {
        viewModel.errorState
            .compactMap( { $0 })
            .assign(to: \.errorState, on: self)
            .store(in: &subscription)
        
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
        
        viewModel.steps
            .receive(on: DispatchQueue.main)
            .sink { steps in
                self.stepsLabel.text = "\(Int(steps))"
                self.stepsRing.setProgress(Float(steps) / Float(self.viewModel.stepsGoal), animated: true)
            }
            .store(in: &subscription)
        
        viewModel.calories
            .receive(on: DispatchQueue.main)
            .sink { calories in
                self.caloriesLabel.text = "\(Int(calories))"
                self.caloriesRing.setProgress(Float(calories) / Float(self.viewModel.caloriesGoal), animated: true)
            }
            .store(in: &subscription)
        
        viewModel.tableLoading
            .sink { state in
                if state == false {
                    self.tableView.hideLoading()
                    self.presentRatingView()
                }
            }
            .store(in: &subscription)
        
        viewModel.action
            .sink { action in
                switch action {
                case .showAlert(let title, let message):
                    AlertManager.showAlert(title: title, message: message, over: self)
                default:
                    break
                }
            }
            .store(in: &subscription)
    }
    
    private func presentRatingView() {
        let ratingView = RatingView()
        ratingView.frame = self.view.bounds
        
        if let keyWindow = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first(where: { $0.isKeyWindow }) {
            ratingView.frame = keyWindow.bounds
            keyWindow.addSubview(ratingView)
        }
    }
}
