//
//  SignUpRequestModelTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 04/12/2021.
//

import XCTest
@testable import GoFitApp

class SignUpRequestModelTests: XCTestCase {
    
    let password: String = "123456789"
    var sut: SignUpRequestModel!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = SignUpRequestModel(email: "mail@mail.com", name: "Dummy", password: password)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSignUpRequestModel_DecodeInsertedPassword_ShouldBeEquals() {
        // Act
        let decodedPassword = sut.getDecodedPassword()
        
        // Assert
        XCTAssertEqual(decodedPassword, password, "The getDecodedPassword() should return decoded password from base64 but returned \(decodedPassword ?? "nothing")")
    }
    
    func testSignUpRequestModel_EncodeInsertedPassword_ShouldBeNotEquals() {
        // Act
        let encodedPassword = sut.password
        
        // Assert
        XCTAssertNotEqual(encodedPassword, password, "The password from the model should be different and encoded in base64 but is the same")
    }
    
    func testSignUpRequestModel_DecodeAndEncodeInsertedPassword_ShouldBeEquals() {
        // Act
        let encodedPassword = sut.password
        let encodedInsertedPassword = password.base64Encoded
        
        // Assert
        XCTAssertEqual(encodedPassword, encodedInsertedPassword, "The password from model is not encoded in the same way as password inserted")
    }    
}
