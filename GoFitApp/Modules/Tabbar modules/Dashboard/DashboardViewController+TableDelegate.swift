//
//  DashboardViewController+TableDelegate.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 06/11/2021.
//

import UIKit
import ContentLoader

extension DashboardViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.recommendations.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SportRecommendationCell.reuseIdentifier(), for: indexPath) as? SportRecommendationCell {
            // TODO
            
            let cellViewModel = viewModel.createSportRecommendationCellViewModel(recommendation: viewModel.recommendations.value[indexPath.row])
            
            cell.viewModel = cellViewModel
            
            cell.cellButton
                .sink { _ in
                    print("Button on cell", indexPath.row)
                }
                .store(in: &subscription)
            
            return cell
        }
        else {
            fatalError("Unexpected kind!")
        }
    }
}

extension DashboardViewController {

    /// Number of sections you would like to show in loader
    func numSections(in contentLoaderView: UIView) -> Int {
        return 1
    }

    /// Number of rows you would like to show in loader
    func contentLoaderView(_ contentLoaderView: UIView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    /// Cell reuse identifier you would like to use (ContenLoader will search loadable objects here!)
    func contentLoaderView(_ contentLoaderView: UIView, cellIdentifierForItemAt indexPath: IndexPath) -> String {
        return SportRecommendationCell.reuseIdentifier()
    }
}
