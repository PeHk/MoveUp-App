//
//  ActivityHistoryDetail+MapViewDelegate.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 15/01/2022.
//

import Foundation
import MapKit

extension ActivityHistoryDetailViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self) {
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.fillColor = Asset.primary.color
            polylineRenderer.strokeColor = Asset.primary.color
            polylineRenderer.lineWidth = 10
            
            return polylineRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func setVisibleMapArea(polyline: MKPolyline, edgeInsets: UIEdgeInsets, animated: Bool = true) {
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
    }
}
