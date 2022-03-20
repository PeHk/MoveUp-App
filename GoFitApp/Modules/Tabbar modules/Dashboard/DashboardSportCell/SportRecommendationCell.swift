//
//  SportRecommendationCell.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 20/03/2022.
//

import UIKit

class SportRecommendationCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    var viewModel: SportRecommendationCellViewModel? {
        didSet {
            self.title.text = viewModel?.type
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
        return "sportRecommendationCell"
    }

}
