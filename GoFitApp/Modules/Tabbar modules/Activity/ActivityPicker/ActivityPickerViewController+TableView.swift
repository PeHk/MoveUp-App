//
//  ActivityPickerViewController+TableView.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 15/12/2021.
//

import Foundation
import UIKit

extension ActivityPickerViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.value.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections.value[section].sectionName
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.sections.value.map{$0.sectionIndexName}
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections.value[section].sectionItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ActivityTableViewCell.reuseIdentifier(), for: indexPath) as? ActivityTableViewCell {
            let sport = viewModel.sections.value[indexPath.section].sectionItems[indexPath.row]
            
            let cellViewModel = viewModel.createActivityCellViewModel(sport: sport)
            
            cell.viewModel = cellViewModel
            
            return cell
        } else {
            fatalError("Unexpected kind")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sport = viewModel.sections.value[indexPath.section].sectionItems[indexPath.row]
        self.viewModel.action.send(.selected(sport))
    }
}
