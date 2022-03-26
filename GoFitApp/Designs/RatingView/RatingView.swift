//
//  RatingView.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 26/03/2022.
//

import UIKit
import Cosmos

class RatingView: UIView {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var starView: CosmosView!
    
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
            print("Current rating is:", rating)
            
        }
    }
    
    private func addBlurView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.7
        blurEffectView.frame = self.frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.bringSubviewToFront(mainView)
    }
}
