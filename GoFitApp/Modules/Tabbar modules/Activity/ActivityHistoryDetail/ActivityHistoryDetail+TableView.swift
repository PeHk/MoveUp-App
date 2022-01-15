//
//  ActivityHistoryDetail+TableView.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 15/01/2022.
//

import Foundation
import UIKit

extension ActivityHistoryDetailViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = Helpers.getTimeAndDateFormatted(from: viewModel.activity.start_date ?? Date())
            case 1:
                cell.detailTextLabel?.text = Helpers.getTimeAndDateFormatted(from: viewModel.activity.end_date ?? Date())
            case 2:
                cell.detailTextLabel?.text = Helpers.formatTimeInterval(time: viewModel.activity.duration)
            case 3:
                cell.detailTextLabel?.text = String(format: "%.2f", viewModel.activity.traveledDistance) + " km"
            case 4:
                cell.detailTextLabel?.text = String(format: "%.2f", viewModel.activity.calories) + " kCal"
            case 5:
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont.init(font: FontFamily.Roboto.regular, size: 15)
        header?.tintColor = Asset.backgroundColor.color
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 1) && hideMapSection {
            return nil
        } else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1) && hideMapSection {
            return 0
        }
        else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1) && hideMapSection {
            return 0.1
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 1) && hideMapSection {
            return 0.1
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
}
