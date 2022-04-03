//
//  SportRecommendationCell.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 20/03/2022.
//

import UIKit
import Combine

class SportRecommendationCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var acceptButton: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(acceptTapped(_:)))
            acceptButton.addGestureRecognizer(tap)
            acceptButton.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var rejectButton: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(rejectTapped(_:)))
            rejectButton.addGestureRecognizer(tap)
            rejectButton.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var title: UILabel!
    
    // MARK: Variables
    var acceptAction : (()->())?
    var rejectAction : (()->())?

//    var cellButton = PassthroughSubject<Bool, Never>()
    var viewModel: SportRecommendationCellViewModel? {
        didSet {
            self.title.text = viewModel?.sport?.name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static func reuseIdentifier() -> String {
        return "sportRecommendationCell"
    }
    
    @objc func acceptTapped(_ sender: UITapGestureRecognizer) {
        FeedbackManager.sendFeedbackNotification(.success)
        acceptAction?()
    }
    
    @objc func rejectTapped(_ sender: UITapGestureRecognizer) {
        FeedbackManager.sendFeedbackNotification(.warning)
        rejectAction?()
    }
}
