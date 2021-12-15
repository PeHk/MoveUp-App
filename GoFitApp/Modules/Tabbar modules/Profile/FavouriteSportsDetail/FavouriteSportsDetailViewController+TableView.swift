//
//  FavouriteSportsDetailViewController+TableView.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 15/12/2021.
//

import Foundation
import UIKit

extension FavouriteSportsDetailViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sports.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ActivityTableViewCell.reuseIdentifier(), for: indexPath) as? ActivityTableViewCell {
            let sport = viewModel.sports.value[indexPath.row]
            
            let cellViewModel = viewModel.createActivityCellViewModel(sport: sport)
            
            cell.viewModel = cellViewModel
            
            return cell
        } else {
            fatalError("Unexpected kind")
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        func shouldSelect() -> Bool {
            if let currentUser = viewModel.user.value, let favourites = currentUser.favourite_sports {
                let favourite_sports: [Sport] = favourites.toArray()
                let sport = viewModel.sports.value[indexPath.row]
                return favourite_sports.contains(where: {$0.id == sport.id})
            } else {
                return false
            }
        }
        
        if shouldSelect() {
            cell.setSelected(true, animated: false)
        }
    }
}
