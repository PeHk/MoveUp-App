//
//  ActivityDetailViewController+TableViewDelegate.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/01/2022.
//

import Foundation
import UIKit

extension ActivityDetailViewController {
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont.init(font: FontFamily.Roboto.regular, size: 15)
        header?.tintColor = Asset.backgroundColor.color
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 1) && self.viewModel.hideMapSection {
            return nil
        } else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1) && self.viewModel.hideMapSection {
            return 0
        }
        else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1) && self.viewModel.hideMapSection {
            return 0.1
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 1) && self.viewModel.hideMapSection {
            return 0.1
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
}
