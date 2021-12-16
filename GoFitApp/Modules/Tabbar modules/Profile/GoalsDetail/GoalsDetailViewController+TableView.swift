//
//  GoalsDetailViewController+TableView.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 16/12/2021.
//

import Foundation
import UIKit

extension GoalsDetailViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            cell.detailTextLabel?.text = "\(viewModel.steps)"
        case 1:
            cell.detailTextLabel?.text = "\(viewModel.calories)"
        case 2:
            cell.detailTextLabel?.text = "200"
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.showInputDialog(
                title: "Daily steps goal",
                subtitle: "Enter new daily steps goal:",
                inputText: "\(viewModel.steps)",
                inputKeyboardType: .numberPad,
                actionHandler:  { text in
                    if let t = text {
                        self.viewModel.action.send(.saveSteps(Int(t) ?? 10000))
                    }
                    
                })
        case 1:
            self.showInputDialog(
                title: "Daily calories goal",
                subtitle: "Enter new daily calories goal:",
                inputText: "\(viewModel.calories)",
                inputKeyboardType: .numberPad,
                actionHandler:  { text in
                    if let t = text {
                        self.viewModel.action.send(.saveCalories(Int(t) ?? 800))
                    }
                })
        case 2:
            self.showInputDialog(
                title: "Active minutes update",
                subtitle: "Enter new weekly minutes goal:",
                inputPlaceholder: "",
                inputKeyboardType: .numberPad,
                actionHandler:  { text in
                    if let t = text {
                        self.viewModel.action.send(.saveMinutes(Int(t) ?? 200))
                    }
                })
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
