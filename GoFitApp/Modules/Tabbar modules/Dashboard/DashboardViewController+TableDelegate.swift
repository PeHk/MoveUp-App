//
//  DashboardViewController+TableDelegate.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 06/11/2021.
//

import UIKit

extension DashboardViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.recommendations.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SportRecommendationCell.reuseIdentifier(), for: indexPath) as? SportRecommendationCell {
            // TODO
            
            let cellViewModel = viewModel.createSportRecommendationCellViewModel(recommendation: viewModel.recommendations.value[indexPath.row])
            
            cell.viewModel = cellViewModel
            
            return cell
        }
        else {
            fatalError("Unexpected kind!")
        }
    }
}
