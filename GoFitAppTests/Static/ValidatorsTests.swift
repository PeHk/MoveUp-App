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
        let email = "peter@gmail.com"
        
        // Act
        let sut = Validators.textFieldValidatorEmail(email)
        
        // Assert
        XCTAssertTrue(sut, "The textFieldValidatorEmail() should have returned TRUE for a valid email but returned FALSE")
    }
    
    func testEmailValidator_WhenInvalidEmailWithoutAddressProvided_ShouldReturnFalse() {
        // Arrange
        let email = "peter@.com"
        
        // Act
        let sut = Validators.textFieldValidatorEmail(email)
        
        // Assert
        XCTAssertFalse(sut, "The textFieldValidatorEmail() should have returned FALSE for a invalid email but returned TRUE")
    }
    
    func testEmailValidator_WhenInvalidEmailWithDashCharacterProvided_ShouldReturnFalse() {
        // Arrange
        let email = "abc-@gmail.com"
        
        // Act
        let sut = Validators.textFieldValidatorEmail(email)
        
        // Assert
        XCTAssertFalse(sut, "The textFieldValidatorEmail() should have returned FALSE for a invalid email but returned TRUE")
    }
    
    // Found a error - added a "-" to the validation regex!
    func testEmailValidator_WhenValidEmailWithDashCharacterProvided_ShouldReturnTrue() {
        // Arrange
        let email = "abc-d@mail.com"
        
        // Act
        let sut = Validators.textFieldValidatorEmail(email)
        
        // Assert
        XCTAssertTrue(sut, "The textFieldValidatorEmail() should have returned TRUE for a valid email but returned FALSE")
    }
    
    func testEmailValidator_WhenValidEmailWithUnderscoreProvided_ShouldReturnTrue() {
        // Arrange
        let email = "abc_d@mail.com"
        
        // Act
        let sut = Validators.textFieldValidatorEmail(email)
        
        // Assert
        XCTAssertTrue(sut, "The textFieldValidatorEmail() should have returned TRUE for a valid email but returned FALSE")
    }
    
    func testEmailValidator_WhenInvalidEmailWithForbiddenCharacterProvided_ShouldReturnFalse() {
        // Arrange
        let email = "abc?@mail.com"
        
        // Act
        let sut = Validators.textFieldValidatorEmail(email)
        
        // Assert
        XCTAssertFalse(sut, "The textFieldValidatorEmail() should have returned FALSE for an invalid email but returned TRUE")
    }
    
    func testEmailValidator_WhenInvalidEmailWithShortInvalidDomainProvided_ShouldReturnFalse() {
        // Arrange
        let email = "abc@mail.c"
        
        // Act
        let sut = Validators.textFieldValidatorEmail(email)
        
        // Assert
        XCTAssertFalse(sut, "The textFieldValidatorEmail() should have returned FALSE for an invalid email but returned TRUE")
    }
    
    func testEmailValidator_WhenInvalidEmailWithLongInvalidDomainProvided_ShouldReturnFalse() {
        // Arrange
        let email = "abc@mail.abcdef"
        
        // Act
        let sut = Validators.textFieldValidatorEmail(email)
        
        // Assert
        XCTAssertFalse(sut, "The textFieldValidatorEmail() should have returned FALSE for an invalid email but returned TRUE")
    }
    
    func testEmailValidator_WhenTooManyCharactersProvided_ShouldReturnFalse() {
        // Arrange
        let email = "abc@mail.abcdeffsfasjhfjshfjshfjhsafjhsajfhsajfhsahfjshfhfhfshsafhahsfheuhutetuurtuhtjahtjhstjjcjhcvhvhcjbhjhcbjchbjchbjcbhcjhbjchbjhcjbhcjbhcjbhcjbhc"
        
        // Act
        let sut = Validators.textFieldValidatorEmail(email)
        
        // Assert
        XCTAssertFalse(sut, "The textFieldValidatorEmail() should have returned FALSE for an invalid email but returned TRUE")
    }
}
