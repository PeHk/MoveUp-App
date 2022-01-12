//
//  ActivityViewController+TableViewDelegate.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 09/01/2022.
//

import Foundation
import UIKit

extension ActivityViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.value.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections.value[section].sectionName
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections.value[section].sectionItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ActivityHistoryTableViewCell.reuseIdentifier(), for: indexPath) as? ActivityHistoryTableViewCell {
            
            let activity = viewModel.sections.value[indexPath.section].sectionItems[indexPath.row]
            let cellViewModel = viewModel.createActivityHistoryCellViewModel(activity: activity)
            
            cell.viewModel = cellViewModel
            
            return cell
        } else {
            fatalError("Unexpected kind!")
        }
    }
}

