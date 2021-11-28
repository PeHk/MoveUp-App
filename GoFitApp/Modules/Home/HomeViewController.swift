//
//  HomeViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import UIKit
import Combine

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var login: SecondaryButton!
    @IBOutlet weak var getStarted: PrimaryButton!
    
    var viewModel: HomeViewModel!
    private var subscription = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
    }
    
    @IBAction func getStartedTapped(_ sender: Any) {
        viewModel.stepper.send(.getStarted)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        viewModel.stepper.send(.login)
    }
}
