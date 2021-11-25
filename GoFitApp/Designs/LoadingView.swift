//
//  LoadingView.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 24/11/2021.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class LoadingView: UIView {

    var blurEffectView: UIVisualEffectView?

    override init(frame: CGRect) {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView = blurEffectView
        super.init(frame: frame)
        addSubview(blurEffectView)
        addLoader()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLoader() {
        guard let blurEffectView = blurEffectView else { return }
        let activityIndicator = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 50, height: 50),
            type: .ballTrianglePath,
            color: Asset.primary.color
        )
        
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        activityIndicator.startAnimating()
    }
}
