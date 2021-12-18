//
//  ProfileDetailViewController+TableView.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/12/2021.
//

import Foundation
import UIKit

extension ProfileDetailViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let user = viewModel.currentUser.value
        let bioData: [BioData]? = user?.bio_data?.toArray()
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = user?.name ?? "None"
            case 1:
                cell.detailTextLabel?.text = user?.email ?? "None"
            case 2:
                cell.detailTextLabel?.text = Helpers.printDate(from: user?.date_of_birth ?? Date())
            case 3:
                cell.detailTextLabel?.text = user?.gender ?? "None"
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = "\(bioData?.first?.weight ?? 0) kg"
            case 1:
                cell.detailTextLabel?.text = "\(bioData?.first?.height ?? 0) cm"
            case 2:
                cell.detailTextLabel?.text = "\(bioData?.first?.bmi.rounded() ?? 0)"
            default:
                break
            }
        default:
            break
        }
    }
}
