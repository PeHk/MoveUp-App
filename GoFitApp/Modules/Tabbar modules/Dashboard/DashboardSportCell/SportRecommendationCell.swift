//
//  SportRecommendationCell.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 20/03/2022.
//

import UIKit
import HeartButton
import Combine

class SportRecommendationCell: UITableViewCell {
    
    @IBOutlet weak var heartView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(heartTapped(_:)))
            heartView.addGestureRecognizer(tap)
            heartView.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var addToFavourites: HeartButton!
    @IBOutlet weak var title: UILabel!
    
    var cellButton = PassthroughSubject<Void, Never>()
    
    var viewModel: SportRecommendationCellViewModel? {
        didSet {
            self.title.text = viewModel?.sport?.name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addToFavourites.stateChanged = { sender, isOn in
            if isOn {
                FeedbackManager.sendFeedbackNotification(.warning)
            } else {
                FeedbackManager.sendFeedbackNotification(.success)
            }
            
            self.cellButton.send(())
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func reuseIdentifier() -> String {
        return "sportRecommendationCell"
    }
    
    @objc func heartTapped(_ sender: UITapGestureRecognizer) {
        self.addToFavourites.setOn(!self.addToFavourites.isOn, animated: true)
    }

}
