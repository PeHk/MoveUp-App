//
//  LoginViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import UIKit
import Combine
import SkyFloatingLabelTextField
import SPPermissions

class LoginViewController: BaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var forgotPasswordButton: UILabel!
    @IBOutlet weak var loginButton: PrimaryButton!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    
    var viewModel: LoginViewModel!
    weak var coordinator: LoginCoordinator!

    private var subscription = Set<AnyCancellable>()
    private var permissionsHidden: Bool = false
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: Bindings
    private func setupBindings() {
        viewModel.errorState
            .compactMap( { $0 })
            .assign(to: \.errorState, on: self)
            .store(in: &subscription)
        
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
        
        emailTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.email, on: viewModel)
            .store(in: &subscription)
        
        passwordTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.password, on: viewModel)
            .store(in: &subscription)
        
        viewModel.$email
            .sink { email in
                email.count > 0 && !Validators.textFieldValidatorEmail(email)
                ? (self.emailTextField.errorMessage = "Not a valid email address!")
                : (self.emailTextField.errorMessage = nil)
            }
            .store(in: &subscription)
        
        viewModel.isInputValid
            .sink { input in
                !input ? self.loginButton.setEnabled() : self.loginButton.setDisabled()
            }
            .store(in: &subscription)
        
        viewModel.action
            .sink { action in
                if case .permissionsShowed = action {
                    self.presentPermissions()
                }
            }
            .store(in: &subscription)
    }
    
    // MARK: Actions
    @IBAction func loginTapped(_ sender: Any) {
        self.viewModel.action.send(.loginTapped)
    }
    
    private func presentPermissions() {
        if !SPPermissions.Permission.locationAlways.authorized || !SPPermissions.Permission.notification.authorized || !SPPermissions.Permission.calendar.authorized {
            let basicPermissions = SPPermissions.list([.calendar, .notification, .locationAlways])
            basicPermissions.delegate = self
            basicPermissions.allowSwipeDismiss = false
            basicPermissions.present(on: self)

        } else {
            viewModel.action.send(.healthKitPermissions)
        }
    }
}

extension LoginViewController: SPPermissionsDelegate {
    func didHidePermissions(_ permissions: [SPPermissions.Permission]) {
        if SPPermissions.Permission.locationAlways.authorized && SPPermissions.Permission.notification.authorized && SPPermissions.Permission.calendar.authorized {
            viewModel.action.send(.healthKitPermissions)
        } else {
            self.permissionsHidden = true
        }
    }
}
