//
//  LoginFlowUITests.swift
//  GoFitAppUITests
//
//  Created by Peter Hlavatík on 07/12/2021.
//

import XCTest
import GoFitApp

class LoginFlowUITests: XCTestCase {
    
    // Tests founded issue with validator of emails and wrong button enabling
    
    var app: XCUIApplication!
    var alreadyHaveAccountButton: XCUIElement!
    var emailTextField: XCUIElement!
    var passwordTextField: XCUIElement!
    var loginButton: XCUIElement!
    var tabBar: XCUIElement!
    
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
        tabBar = app.tabBars["Tab Bar"]

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
        emailTextField = nil
        passwordTextField = nil
        loginButton = nil
        tabBar = nil
        
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
        
        logoutFromDashboard()
    }
    
    func testLoginViewController_WhenLogout_AlertShowed() {
        // Arrange
        loginFromHomeController()
        tabBar.children(matching: .button).element(boundBy: 2).tap()
        
        // Act
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Logout"]/*[[".cells.staticTexts[\"Logout\"]",".staticTexts[\"Logout\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Assert
        XCTAssertTrue(app.alerts["alertDialog"].waitForExistence(timeout: 5), "An logout alert dialog was not presented when logout was provided")
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
    
    
    // MARK: Heleper functions
    func logoutFromDashboard() {
        tabBar.children(matching: .button).element(boundBy: 2).tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Logout"]/*[[".cells.staticTexts[\"Logout\"]",".staticTexts[\"Logout\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
    
    func loginFromHomeController() {
        alreadyHaveAccountButton.tap()
        emailTextField.tap()
        emailTextField.typeText("test@test.com")
        dismissKeyboardIfPresent()
        
        passwordTextField.tap()
        passwordTextField.typeText("test123")
        dismissKeyboardIfPresent()
        
        loginButton.tap()
    }
}
