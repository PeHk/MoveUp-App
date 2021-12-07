//
//  HomeFlowUITests.swift
//  GoFitAppUITests
//
//  Created by Peter Hlavatík on 07/12/2021.
//

import XCTest

class HomeFlowUITests: XCTestCase {
    
    var app: XCUIApplication!
    var getStartedButton: XCUIElement!
    var alreadyHaveAccountButton: XCUIElement!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        getStartedButton = app.buttons["getStartedButton"]
        alreadyHaveAccountButton = app.buttons["alreadyAccountButton"]
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
        getStartedButton = nil
        alreadyHaveAccountButton = nil
        
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
}
