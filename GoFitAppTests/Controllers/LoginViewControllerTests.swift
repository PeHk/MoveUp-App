//
//  LoginViewControllerTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 06/12/2021.
//

import XCTest
import Combine
@testable import GoFitApp

class LoginViewControllerTests: XCTestCase {
    
    var dependencyContainer: DependencyContainer!
    var storyboard: UIStoryboard!
    var viewModel: LoginViewModel!
    var sut: LoginViewController!
    var subscription: Set<AnyCancellable>!

    override func setUp() {
        dependencyContainer = DependencyContainer()
        viewModel = LoginViewModel(dependencyContainer)
        storyboard = UIStoryboard(name: "LoginViewController", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        sut?.viewModel = viewModel
        sut?.loadViewIfNeeded()
        subscription = Set<AnyCancellable>()
    }

    override func tearDown() {
        storyboard = nil
        viewModel = nil
        dependencyContainer = nil
        sut = nil
        subscription = nil
    }

    func testLoginViewController_WhenCreated_HasRequiredTextFieldsEmpty() {
        XCTAssertEqual(sut?.emailTextField.text, "", "Email textfield is not initially empty")
        XCTAssertEqual(sut?.passwordTextField.text, "", "Password textfield is not initially empty")
    }
    
    func testLoginViewController_WhenCreated_HasLoginButtonAndAction() throws {
        // Arrange
        let loginButton: UIButton = try XCTUnwrap(sut.loginButton, "Login button has no referencing outlet")
        
        // Act
        let actions = try XCTUnwrap(loginButton.actions(forTarget: sut, forControlEvent: .touchUpInside), "Login button have no actions assigned!")
        
        // Assert
        XCTAssertEqual(actions.count, 1, "Login button have no exactly one action!")
        XCTAssertEqual(actions.first, "loginTapped:", "There is no correct action assigned")
    }
    
    func testLoginViewController_WhenLoginButtonTapped_InvokesLoginProcess() {
        // Act
        sut.loginButton.sendActions(for: .touchUpInside)
        
        // Assert
        viewModel.action
            .sink { action in
                XCTAssertEqual(action, LoginViewModel.Action.loginTapped, "Wrong action assigned to on login button")
            }
            .store(in: &subscription)
    }
}
