//
//  ActivityTableViewCell.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 14/12/2021.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    
    var viewModel: ActivityCellViewModel? {
        didSet {
            self.textLabel?.text = viewModel?.name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func reuseIdentifier() -> String {
        return "activityCell"
    }
}
