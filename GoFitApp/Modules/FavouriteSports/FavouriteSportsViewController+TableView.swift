//
//  FavouriteSportsViewController+TableVIew.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 28/11/2021.
//

import UIKit
import Foundation

extension FavouriteSportsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sports.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SportTableViewCell.reuseIdentifier(), for: indexPath) as? SportTableViewCell {
            let sport = viewModel.sports.value[indexPath.row]
            let cellViewModel = viewModel.createSportCellViewModel(sport: sport)
            
            cell.viewModel = cellViewModel
            
            return cell
        } else {
            fatalError("Unexpected kind")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
}
