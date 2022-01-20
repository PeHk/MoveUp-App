//
//  BackupTableViewController+Delegate.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 20/01/2022.
//

import UIKit
import Foundation

extension BackupDetailViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = "\(viewModel.backupDate)"
            default:
                break
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                self.viewModel.state.send(.loading)
                self.viewModel.action.send(.reload)
            default:
                break
            }
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
