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
        let val: RecommendationArray = viewModel.recommendations.value[indexPath.row]
        
        if val.recommendedActivity == nil && val.recommendedSport != nil {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SportRecommendationCell.reuseIdentifier(), for: indexPath) as? SportRecommendationCell {
                
                guard let recommendation = val.recommendedSport else {
                    fatalError("Unexpected kind!")
                }
                
                let cellViewModel = viewModel.createSportRecommendationCellViewModel(recommendation: recommendation)
                
                cell.viewModel = cellViewModel
                
                cell.acceptAction = { [weak self] () in
                    self?.viewModel.handleRecommendation(recommendation: recommendation, state: true)
                }
                
                cell.rejectAction = { [weak self] () in
                    self?.viewModel.handleRecommendation(recommendation: recommendation, state: false)
                }
                
                return cell
            }
            else {
                fatalError("Unexpected kind!")
            }
        } else if val.recommendedActivity != nil && val.recommendedSport == nil {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ActivityRecommendationCell.reuseIdentifier(), for: indexPath) as? ActivityRecommendationCell {
                
                guard let recommendation = val.recommendedActivity else {
                    fatalError("Unexpected kind!")
                }
                
                let cellViewModel = viewModel.createActivityRecommendationCellViewModel(recommendation: recommendation)
                
                cell.viewModel = cellViewModel
                
                cell.acceptAction = { [weak self] () in
                    self?.viewModel.handleActivityRecommendation(recommendation: recommendation, state: true)
                }
                
                cell.rejectAction = { [weak self] () in
                    self?.viewModel.handleActivityRecommendation(recommendation: recommendation, state: false)
                }
                
                return cell
            }
        } else {
            fatalError("Unexpected kind!")
        }
        
        fatalError("Unexpected kind!")
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
