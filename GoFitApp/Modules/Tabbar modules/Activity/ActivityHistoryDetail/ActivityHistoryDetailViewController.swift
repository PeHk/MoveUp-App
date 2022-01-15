import Combine
import UIKit
import MapKit

class ActivityHistoryDetailViewController: BaseTableViewController, MKMapViewDelegate {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var averagePaceLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var startedTime: UILabel!
    @IBOutlet weak var startedDate: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var viewModel: ActivityHistoryDetailViewModel!
    var coordinator: ActivityHistoryDetailCoordinator!
    
    private var subscription = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func setupView() {
        self.title = viewModel.activity.name
        mapView.delegate = self
        
        self.durationLabel.text = Helpers.formatTimeInterval(time: viewModel.activity.duration)
        self.startedDate.text = Helpers.printDate(from: viewModel.activity.start_date ?? Date())
        self.startedTime.text = Helpers.getTimeFromDate(from: viewModel.activity.start_date ?? Date())
        self.caloriesLabel.text = String(format: "%.2f", viewModel.activity.calories) + " kCal"
        self.distanceLabel.text = String(format: "%.2f", viewModel.activity.traveledDistance) + " km"
    }
    
    private func setupBindings() {
        viewModel.errorState
            .compactMap( { $0 })
            .assign(to: \.errorState, on: self)
            .store(in: &subscription)
        
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
        
        viewModel.$coordinates
            .receive(on: DispatchQueue.main)
            .sink { coordinates in
                if coordinates.count > 0 {
                    let polyline = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
                    self.mapView.addOverlay(polyline)
                    self.setVisibleMapArea(polyline: polyline, edgeInsets: self.viewModel.edges)
                } else {
                    self.mapView.isHidden = true
                    
                    var frame = self.headerView.frame
                    frame.size.height = 380
                    self.headerView.frame = frame
                }
            }
            .store(in: &subscription)
    }
}
