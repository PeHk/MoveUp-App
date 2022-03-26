//
//  RatingView.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 26/03/2022.
//

import UIKit
import Cosmos
import Combine

class RatingView: UIView {

    // MARK: Outlets
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var starView: CosmosView!
    
    public var rating = PassthroughSubject<Int, Never>()
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RatingView", owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = self.bounds
        mainView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addBlurView()
        
        
        starView.didFinishTouchingCosmos = { rating in
            if let ratingInt = rating.toInt() {
                self.rating.send(ratingInt)
            }
        }
        
        starView.didTouchCosmos = { _ in
            FeedbackManager.sendImpactFeedback(.light)
        }
    }
    
    private func addBlurView() {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.8
        blurEffectView.frame = self.frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.bringSubviewToFront(mainView)
    }
}
