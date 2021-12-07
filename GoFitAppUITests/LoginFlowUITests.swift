//
//  LoginFlowUITests.swift
//  GoFitAppUITests
//
//  Created by Peter Hlavatík on 07/12/2021.
//

import XCTest

class LoginFlowUITests: XCTestCase {
    
    // Tests founded issue with validator of emails and wrong button enabling
    
    var app: XCUIApplication!
    var alreadyHaveAccountButton: XCUIElement!
    var emailTextField: XCUIElement!
    var passwordTextField: XCUIElement!
    var loginButton: XCUIElement!
    
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
        
        emailTextField = app.textFields["emailTextField"]
        passwordTextField = app.secureTextFields["passwordTextField"]
        loginButton = app.buttons["loginButton"]
        alreadyHaveAccountButton = app.buttons["alreadyAccountButton"]

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
        emailTextField = nil
        passwordTextField = nil
        loginButton = nil
        
        try super.tearDownWithError()
    }

    func testLoginViewController_WhenInvalidInputInserted_LoginButtonDisabled() {
        // Arrange
        alreadyHaveAccountButton.tap()
        
        XCTAssertFalse(loginButton.isEnabled, "Login button is enabled even when no input is provided!")
        
        emailTextField.tap()
        emailTextField.typeText("p.hlavatik@.c")
        dismissKeyboardIfPresent()
        
        passwordTextField.tap()
        passwordTextField.typeText("123456789")
        dismissKeyboardIfPresent()
        
        // Assert
        XCTAssertFalse(loginButton.isEnabled, "Login button is enabled even when valid input is not inserted!")
    }
    
    func testLoginViewController_WhenValidInputInserted_LoginButtonEnabled() {
        // Arrange
        alreadyHaveAccountButton.tap()
        
        XCTAssertFalse(loginButton.isEnabled, "Login button is enabled even when no input is provided!")
        
        emailTextField.tap()
        emailTextField.typeText("p.hlavatik@gmail.com")
        dismissKeyboardIfPresent()
        
        passwordTextField.tap()
        passwordTextField.typeText("123456789")
        dismissKeyboardIfPresent()
        
        // Assert
        XCTAssertTrue(loginButton.isEnabled, "Login button is not enabled even when valid input is inserted!")
    }
    
    func testLoginViewController_WhenValidInputInsertedAndLoginTapped_DashboardControllerInitiated() {
        // Arrange
        alreadyHaveAccountButton.tap()
        
        XCTAssertFalse(loginButton.isEnabled, "Login button is enabled even when no input is provided!")
        
        emailTextField.tap()
        emailTextField.typeText("test@test.com")
        dismissKeyboardIfPresent()
        
        passwordTextField.tap()
        passwordTextField.typeText("test123")
        dismissKeyboardIfPresent()
        
        XCTAssertTrue(loginButton.isEnabled, "Login button is not enabled even when valid input is inserted!")
        
        // Act
        loginButton.tap()
        
        // Assert
        XCTAssertTrue(app.tables["DashboardViewController"].waitForExistence(timeout: 10), "Dashboard View Controller is not presented after tapping on already have account button!")
    }
    
    func testLoginViewController_WhenInvalidPasswordInsertedAndLoginTapped_ErrorAlertShowed() {
        // Arrange
        alreadyHaveAccountButton.tap()
        
        XCTAssertFalse(loginButton.isEnabled, "Login button is enabled even when no input is provided!")
        
        emailTextField.tap()
        emailTextField.typeText("p.hlavatik@gmail.com")
        dismissKeyboardIfPresent()
        
        passwordTextField.tap()
        passwordTextField.typeText("123456789")
        dismissKeyboardIfPresent()
        
        XCTAssertTrue(loginButton.isEnabled, "Login button is not enabled even when valid input is inserted!")
        
        // Act
        loginButton.tap()
        
        // Assert
        XCTAssertTrue(app.alerts["alertDialog"].waitForExistence(timeout: 5), "An error alert dialog was not presented when invalid signup form was submitted")
    }

}
