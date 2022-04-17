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
    @IBOutlet weak var startAt: UILabel!
    @IBOutlet weak var endAt: UILabel!
    

    var viewModel: ActivityRecommendationViewModel? {
        didSet {
            if let viewModel = viewModel, let sport = viewModel.sport {
                name.text = sport.name
                startAt.text = viewModel.start_time.formatted(date: .numeric, time: .shortened)
                endAt.text = viewModel.end_time.formatted() 
            }
//            name.text = viewModel?.sport?.name
//            print(viewModel?.sport?.healthKitType)
//            print(viewModel?.sport?.name)
//            print(viewModel?.start_time)
//            print(viewModel?.end_time)
//            print("Created at: ", viewModel?.created_at)
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
