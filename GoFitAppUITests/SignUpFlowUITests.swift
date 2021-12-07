//
//  GoFitAppUITests.swift
//  GoFitAppUITests
//
//  Created by Peter Hlavatík on 06/12/2021.
//

import XCTest

class SignUpFlowUITests: XCTestCase {
    
    var app: XCUIApplication!
    var getStartedButton: XCUIElement!
    var alreadyHaveAccountButton: XCUIElement!
    var nicknameTextField: XCUIElement!
    var emailTextField: XCUIElement!
    var passwordTextField: XCUIElement!
    var repeatPasswordTextField: XCUIElement!
    var signUpButton: XCUIElement!
    
    func dismissKeyboardIfPresent() {
        if app.keyboards.element(boundBy: 0).exists {
            if UIDevice.current.userInterfaceIdiom == .pad {
                app.keyboards.buttons["Hide keyboard"].tap()
            } else {
                app.toolbars.buttons["Done"].tap()
            }
        }
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        getStartedButton = app.buttons["getStartedButton"]
        alreadyHaveAccountButton = app.buttons["alreadyAccountButton"]
        nicknameTextField = app.textFields["nicknameTextField"]
        emailTextField = app.textFields["emailTextField"]
        passwordTextField = app.secureTextFields["passwordTextField"]
        repeatPasswordTextField = app.secureTextFields["repeatPasswordTextField"]
        signUpButton = app.buttons["signUpButton"]

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
        getStartedButton = nil
        alreadyHaveAccountButton = nil
        nicknameTextField = nil
        emailTextField = nil
        passwordTextField = nil
        repeatPasswordTextField = nil
        signUpButton = nil
        
        try super.tearDownWithError()
    }
    
    func testGetStartedButton_WhenTapped_RegistrationViewControllerPresented() {
        getStartedButton.tap()
        
        XCTAssertTrue(app.otherElements["RegistrationViewController"].waitForExistence(timeout: 1), "Registration View Controller is not presented after tapping on get started button!")
    }
    
    func testAlreadyHaveAnAccount_WhenTapped_LoginViewControllerPresented() {
        alreadyHaveAccountButton.tap()
        
        XCTAssertTrue(app.otherElements["LoginViewController"].waitForExistence(timeout: 1), "Login View Controller is not presented after tapping on already have account button!")
    }

    func testHomeViewController_WhenViewLoaded_RequiredButtonsAreEnabled() throws {
        XCTAssertTrue(getStartedButton.isEnabled, "Get started button is not enabled for user interactions!")
        XCTAssertTrue(alreadyHaveAccountButton.isEnabled, "Already have account button is not enabled for user interactions!")
    }
    
    func testRegistrationViewController_WhenInvalidInputInserted_ButtonDisabled() {
        // Arrange
        getStartedButton.tap()
        
        XCTAssertFalse(signUpButton.isEnabled, "Sign up button is enabled before any input inserted!")
        
        nicknameTextField.tap()
        nicknameTextField.typeText("Peter")
        self.dismissKeyboardIfPresent()
        
        emailTextField.tap()
        emailTextField.typeText("p.hlavatik@..c")
        self.dismissKeyboardIfPresent()
        
        passwordTextField.tap()
        passwordTextField.typeText("123456789")
        self.dismissKeyboardIfPresent()
        
        repeatPasswordTextField.tap()
        repeatPasswordTextField.typeText("1234569")
        self.dismissKeyboardIfPresent()
        
        XCTAssertFalse(signUpButton.isEnabled, "Sign up button is enabled before valid input inserted!")
    }
    
    func testRegistrationViewController_WhenInvalidFormSubmitted_PresentsAlertDialog() {
        // Arrange
        getStartedButton.tap()
        
        XCTAssertFalse(signUpButton.isEnabled, "Sign up button is enabled before any input inserted!")
        
        nicknameTextField.tap()
        nicknameTextField.typeText("Peter")
        self.dismissKeyboardIfPresent()
        
        emailTextField.tap()
        emailTextField.typeText("p.hlavatik@gmail.com")
        self.dismissKeyboardIfPresent()
        
        passwordTextField.tap()
        passwordTextField.typeText("123456789")
        self.dismissKeyboardIfPresent()
        
        repeatPasswordTextField.tap()
        repeatPasswordTextField.typeText("123456789")
        self.dismissKeyboardIfPresent()
        
        // Act
        XCTAssertTrue(signUpButton.isEnabled, "Sign up button is not enabled even with right input inserted!")
        
        signUpButton.tap()
        
        // Assert
        XCTAssertTrue(app.alerts["alertDialog"].waitForExistence(timeout: 1), "An error alert dialog was not presented when invalid signup form was submitted")
    }
}
