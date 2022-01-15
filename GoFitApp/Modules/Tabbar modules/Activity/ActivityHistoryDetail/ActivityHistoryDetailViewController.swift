import Combine
import UIKit
import MapKit

class ActivityHistoryDetailViewController: BaseTableViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.layer.cornerRadius = 10
        }
    }
    
    var viewModel: ActivityHistoryDetailViewModel!
    var coordinator: ActivityHistoryDetailCoordinator!
    var hideMapSection: Bool = false
    
    private var subscription = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func setupView() {
        self.title = viewModel.activity.name
        mapView.delegate = self
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
                    self.hideMapSection = true
                    self.tableView.reloadData()
                }
            }
            .store(in: &subscription)
    }
}
