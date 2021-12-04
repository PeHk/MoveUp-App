//
//  ValidatorsTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 04/12/2021.
//

import XCTest
@testable import GoFitApp

class ValidatorsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testEmailValidator_WhenValidEmailProvided_ShouldReturnTrue() {
        // Arrange
        let validEmail = "peter@gmail.com"
        
        // Act
        let sut = Validators.textFieldValidatorEmail(validEmail)
        
        // Assert
        XCTAssertTrue(sut, "The textFieldValidatorEmail() should have returned TRUE for a valid email but returned FALSE")
    }
    
    func testEmailValidator_WhenInvalidEmailProvided_ShouldReturnFalse() {
        // Arrange
        let invalidEmail = "peter@.com"
        
        // Act
        let sut = Validators.textFieldValidatorEmail(invalidEmail)
        
        // Assert
        XCTAssertFalse(sut, "The textFieldValidatorEmail() should have returned FALSE for a invalid email but returned TRUE")
    }
    
    

}
