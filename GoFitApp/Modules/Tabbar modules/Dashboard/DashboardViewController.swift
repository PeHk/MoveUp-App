import Combine
import UIKit
import ALProgressView
import ContentLoader
import EmptyDataSet_Swift
import SPIndicator

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
        
        
        if isBeingPresented || isMovingToParent {
            self.viewModel.action.send(.checkRecommendations(withLoading: false))
        } else {
            self.viewModel.action.send(.checkRecommendations(withLoading: true))
        }
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
    
    // MARK: Bindings
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
                }
            }
            .store(in: &subscription)
        
        viewModel.isLoading
            .sink { state in
                if !state {
                    self.tableView.reloadData()
                }
            }
            .store(in: &subscription)
        
        viewModel.action
            .sink { action in
                switch action {
                case .showAlert(let title, let message):
                    AlertManager.showAlert(title: title, message: message, over: self)
                case .presentRatingView(let recommendation):
                    self.presentRatingView(recommendation: recommendation)
                default:
                    break
                }
            }
            .store(in: &subscription)
        
        viewModel.showAlert
            .sink { state in
                if state {
                    self.showSPAlert()
                }
            }
            .store(in: &subscription)
    }
    
    // MARK: Rating view
    private func presentRatingView(recommendation: Recommendation) {
        if let keyWindow = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first(where: { $0.isKeyWindow }) {
            
            if keyWindow.subviews.contains(where: {($0 as? RatingView) != nil}) {
                return
            }
            
            let ratingView = RatingView()
            ratingView.frame = keyWindow.bounds
            keyWindow.addSubview(ratingView)
            
            ratingView.rating
                .sink { rating in
                    self.viewModel.action.send(.ratingReceived(rating: rating, recommendation: recommendation))
                    ratingView.removeFromSuperview()
                }
                .store(in: &subscription)
        }
    }
    
    private func showSPAlert() {
        let spView = SPIndicatorView(title: "Sport added to favourites", preset: .done)
        spView.presentSide = .top
        spView.tintColor = Asset.primary.color
        spView.present(duration: 4, haptic: .success)
    }
}
