//
//  RegistrationViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import UIKit
import Combine
import SkyFloatingLabelTextField

class RegistrationViewController: BaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var repeatPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var signUpButton: PrimaryButton!
    @IBOutlet weak var informationView: UIView! {
        didSet {
            informationView.layer.cornerRadius = 10
        }
    }

    weak var coordinator: RegistrationCoordinator!
    var viewModel: RegistrationViewModel!
    private var subscription = Set<AnyCancellable>()

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
        
        repeatPasswordTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.repeatPassword, on: viewModel)
            .store(in: &subscription)
        
        usernameTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.username, on: viewModel)
            .store(in: &subscription)
        
        // MARK: Validation of textfields
        Publishers.CombineLatest(viewModel.isInputValid, viewModel.isPasswordSame)
            .sink { input, passwords in
                !input && !passwords ? self.signUpButton.setEnabled() : self.signUpButton.setDisabled()
                
                passwords && self.passwordTextField.text?.count ?? 0 > 0 && self.repeatPasswordTextField.text?.count ?? 0 > 0 ? (self.repeatPasswordTextField.errorMessage = "Passwords are not the same!") : (self.repeatPasswordTextField.errorMessage = nil)
            }
            .store(in: &subscription)
        
        viewModel.$username
            .sink { username in
                username.count > 0 && username.count < 3
                ? (self.usernameTextField.errorMessage = "Username is too short!")
                : (self.usernameTextField.errorMessage = nil)
            }
            .store(in: &subscription)
        
        viewModel.$email
            .sink { email in
                email.count > 0 && !Validators.textFieldValidatorEmail(email)
                ? (self.emailTextField.errorMessage = "Not a valid email address!")
                : (self.emailTextField.errorMessage = nil)
            }
            .store(in: &subscription)
        
        viewModel.$password
            .sink { password in
                password.count > 0 && password.count < 5
                ? (self.passwordTextField.errorMessage = "Password is too short!")
                : (self.passwordTextField.errorMessage = nil)
            }
            .store(in: &subscription)
        
    }
    
    // MARK: Actions
    @IBAction func signUpButtonTapped(_ sender: Any) {
        viewModel.action.send(.signUpButton)
    }
}
