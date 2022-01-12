//
//  ActivityViewController+TableViewDelegate.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 09/01/2022.
//

import Foundation
import UIKit

extension ActivityViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.activities.value.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ActivityHistoryTableViewCell.reuseIdentifier(), for: indexPath) as? ActivityHistoryTableViewCell {
            
            let activity = viewModel.activities.value[indexPath.row]
            let cellViewModel = viewModel.createActivityHistoryCellViewModel(activity: activity)
            
            cell.viewModel = cellViewModel
            
            return cell
        } else {
            fatalError("Unexpected kind!")
        }
    }
}

