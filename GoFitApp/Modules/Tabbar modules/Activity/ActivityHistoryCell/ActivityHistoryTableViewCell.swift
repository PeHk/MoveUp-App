//
//  ActivityTableViewCell.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 12/01/2022.
//

import UIKit

class ActivityHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var external: UIImageView!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var calories: UILabel!
    @IBOutlet weak var name: UILabel!
    
    var viewModel: ActivityHistoryCellViewModel? {
        didSet {
            self.duration.text = Helpers.formatTimeInterval(time: viewModel?.duration ?? 0)
            self.calories.text = "\(viewModel?.calories.rounded() ?? 0) kCal"
            self.name.text = viewModel?.name
            self.external.isHidden = !(viewModel?.external ?? false)
        }
    }
    
    let formatter = DateComponentsFormatter()


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func reuseIdentifier() -> String {
        return "activityHistoryCell"
    }


}
