//
//  HomeViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import UIKit
import Combine

class HomeViewController: BaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var login: SecondaryButton!
    @IBOutlet weak var getStarted: PrimaryButton!
    
    public var fromInterceptor: Bool?
    
    var viewModel: HomeViewModel!
    private var subscription = Set<AnyCancellable>()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupViews()
    }
    
    private func setupViews() {
        if let intercepted = fromInterceptor {
            if intercepted == true {
                AlertManager.showAlert(title: Constants.loggedOutTitle, message: Constants.interceptorDescription, over: self)
            } else {
                AlertManager.showAlert(title: Constants.loggedOutTitle, message: Constants.loggedOutDescription, over: self)
            }
        }
    }
    
    private func setupBindings() {
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
    }
    
    // MARK: Actions
    @IBAction func getStartedTapped(_ sender: Any) {
        viewModel.stepper.send(.getStarted)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        viewModel.stepper.send(.login)
    }
}
