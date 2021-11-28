//
//  SportTableViewCell.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 28/11/2021.
//

import UIKit

class SportTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sportName: UILabel!
    var viewModel: SportCellViewModel? {
        didSet {
            sportName.text = viewModel?.name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        accessoryType = selected ? .checkmark : .none
    }
    
    static func reuseIdentifier() -> String {
        return "sportCell"
    }

}
