//
//  ProfileViewController+TableView.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 29/11/2021.
//

import Foundation
import UIKit

extension ProfileViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                viewModel.stepper.send(.profile)
            case 1:
                viewModel.stepper.send(.sports)
            case 2:
                viewModel.action.send(.logout)
            default:
                break
            }
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont.init(font: FontFamily.Roboto.regular, size: 17)
        header?.textLabel?.textColor = Asset.primary.color
        header?.tintColor = Asset.backgroundColor.color
    }
}
