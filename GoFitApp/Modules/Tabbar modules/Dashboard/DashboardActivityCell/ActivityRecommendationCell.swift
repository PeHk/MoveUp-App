//
//  ActivityRecommendationCell.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/04/2022.
//

import Foundation
import UIKit

class ActivityRecommendationCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dateAt: UILabel!
    @IBOutlet weak var timeAt: UILabel!
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
    
    // MARK: Variables
    var acceptAction : (()->())?
    var rejectAction : (()->())?
    
    var viewModel: ActivityRecommendationViewModel? {
        didSet {
            if let viewModel = viewModel, let sport = viewModel.sport {
                name.text = sport.name
                dateAt.text = viewModel.checkDate()
                timeAt.text = viewModel.start_time.formatted(date: .omitted, time: .shortened)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static func reuseIdentifier() -> String {
        return "activityRecommendationCell"
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
