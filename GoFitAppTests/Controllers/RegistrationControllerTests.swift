//
//  RegistrationControllerTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 06/12/2021.
//

import XCTest
@testable import GoFitApp
import Combine

class RegistrationControllerTests: XCTestCase {
    
    var dependencyContainer: DependencyContainer!
    var storyboard: UIStoryboard!
    var viewModel: RegistrationViewModel!
    var sut: RegistrationViewController!
    var subscription: Set<AnyCancellable>!

    override func setUp() {
        dependencyContainer = DependencyContainer()
        viewModel = RegistrationViewModel(dependencyContainer)
        storyboard = UIStoryboard(name: "RegistrationViewController", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "RegistrationViewController") as? RegistrationViewController
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
    
    func testRegistrationViewController_WhenCreated_HasRequiredTextFieldsEmtpy() throws {
        XCTAssertEqual(sut?.emailTextField.text, "", "Email textfield is not initially empty")
        XCTAssertEqual(sut?.passwordTextField.text, "", "Password textfield is not initially empty")
        XCTAssertEqual(sut?.usernameTextField.text, "", "Username textfield is not initially empty")
        XCTAssertEqual(sut?.repeatPasswordTextField.text, "", "Repeat password textfield is not initially empty")
    }
    
    func testRegistrationViewController_WhenCreated_HasRegisterButtonAndAction() throws {
        // Arrange
        let registerButton: UIButton = try XCTUnwrap(sut.signUpButton, "Signup button has no referencing outlet")
        
        // Act
        let actions = try XCTUnwrap(registerButton.actions(forTarget: sut, forControlEvent: .touchUpInside), "Signup button have no actions assigned!")
        
        // Assert
        XCTAssertEqual(actions.count, 1, "Signup button have no exactly one action!")
        XCTAssertEqual(actions.first, "signUpButtonTapped:", "There is no correct action assigned")
    }
    
    func testRegistrationViewController_WhenRegistrationButtonTapped_InvokesSignupProcess() {
        // Act
        sut.signUpButton.sendActions(for: .touchUpInside)
        
        // Assert
        viewModel.action
            .sink { action in
                XCTAssertEqual(action, RegistrationViewModel.Action.signUpButton, "Wrong action assigned to signup button")
            }
            .store(in: &subscription)
    }
    
    func testRegistrationViewController_WhenCreated_PasswordTextFieldHasSecureEntry() {
        // Assert
        XCTAssertTrue(sut.passwordTextField.isSecureTextEntry, "PasswordTextField has no secure entry attribute!")
    }
    
    func testRegistrationViewController_WhenCreated_RepeatPasswordTextFieldHasSecureEntry() {
        // Assert
        XCTAssertTrue(sut.repeatPasswordTextField.isSecureTextEntry, "RepeatPasswordTextField has no secure entry attribute!")
    }
    
    // Bug found
    func testRegistrationViewController_WhenCreated_EmailTextFieldHasEmailContentType() {
        // Assert
        XCTAssertEqual(sut.emailTextField.keyboardType, .emailAddress, "Email textfield has no email content type keyboard")
    }
}
