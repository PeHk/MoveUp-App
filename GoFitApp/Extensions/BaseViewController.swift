//
//  BaseViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 20/10/2021.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(asset: Asset.backButton),
            style: UIBarButtonItem.Style.done,
            target: navigationController,
            action: #selector(navigationController?.goBack))
        
    }
}
