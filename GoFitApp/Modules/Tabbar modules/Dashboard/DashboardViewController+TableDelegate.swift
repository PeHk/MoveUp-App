//
//  DashboardViewController+TableDelegate.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 06/11/2021.
//

import UIKit

extension DashboardViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recommendationCell", for: indexPath)
        
        return cell
    }
}
