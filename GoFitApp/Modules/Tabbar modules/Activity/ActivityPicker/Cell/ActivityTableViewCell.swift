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
            
            if let viewModel = viewModel {
                self.enableSelection = viewModel.enableSelection
            }
        }
    }
    
    var enableSelection: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        accessoryType = enableSelection ? (selected ? .checkmark : .none): . none
    }
    
    static func reuseIdentifier() -> String {
        return "activityCell"
    }
}
