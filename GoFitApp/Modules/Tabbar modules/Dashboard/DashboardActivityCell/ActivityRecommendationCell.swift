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
    var viewModel: ActivityRecommendationViewModel? {
        didSet {
            name.text = viewModel?.sport?.name
            print(viewModel?.start_time)
            print(viewModel?.end_time)
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
