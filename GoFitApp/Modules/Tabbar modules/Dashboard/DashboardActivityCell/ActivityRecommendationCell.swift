//
//  ActivityRecommendationCell.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/04/2022.
//

import Foundation
import UIKit

class ActivityRecommendationCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dateAt: UILabel!
    @IBOutlet weak var timeAt: UILabel!
    
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
    
}
