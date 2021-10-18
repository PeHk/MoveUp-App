//
//  HomeViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var login: SecondaryButton!
    @IBOutlet weak var getStarted: PrimaryButton!
    var viewModel: HomeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getStartedTapped(_ sender: Any) {
        viewModel.stepper.send(.getStarted)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        viewModel.stepper.send(.login)
    }
}
