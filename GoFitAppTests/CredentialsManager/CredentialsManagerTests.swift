//
//  CredentialsManagerTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 11/12/2021.
//

import XCTest
import Combine
@testable import GoFitApp

class CredentialsManagerTests: XCTestCase {
    
    var sut: CredentialsManager!
    var dependencyContainer: DependencyContainer!
    var subscription: Set<AnyCancellable>!

    override func setUp() {
        dependencyContainer = DependencyContainer()
        sut = CredentialsManager(dependencyContainer)
        subscription = Set<AnyCancellable>()
    }

    override func tearDown() {
        _ = sut.removeCredentials()
        
        sut = nil
        dependencyContainer = nil
        subscription = nil
    }

    func testCredentialsManager_WhenEmptyCredentialsRequested_ShouldReturnNil() {
        XCTAssertNil(sut.getEncodedCredentials(), "getEncodedCredentials not returned nil")
    }
    
    func testCredentialsManager_WhenCredentialsInserted_ShouldReturnNotNil() {
        // Act
        sut.saveCredentials(email: "email", password: "pass")
        
        // Assert
        XCTAssertNotNil(sut.getEncodedCredentials(), "getEncodedCredentials returned nil")
    }
    
    func testCredentialsManager_WhenCredentialsInserted_CredentialsShouldEquals() throws {
        // Arrange
        let email = "email"
        let password = "pass"
        sut.saveCredentials(email: email, password: password)
        
        // Act
        let tuple: (String, String) = try XCTUnwrap(sut.getEncodedCredentials())
        
        // Assert
        XCTAssertEqual(tuple.0, email, "Email is not the same as inserted one")
        XCTAssertEqual(tuple.1, password, "Password is not the same as inserted one")
    }
    
    func testCredentialsManager_WhenCredentialsDeletedAfterInsertion_GetCredentialsShouldReturnNil() {
        // Arrange
        sut.saveCredentials(email: "email", password: "pass")
        
        // Act
        _ = sut.removeCredentials()
        
        // Assert
        XCTAssertNil(sut.getEncodedCredentials(), "getEncodedCredentials not returned nil")
    }
    
    func testCredentialsManager_WhenCredentialsDeleted_RemoveCredentialsShouldReturnTrue() {
        // Arrange
        sut.saveCredentials(email: "email", password: "pass")
        
        // Assert
        XCTAssertTrue(sut.removeCredentials(), "removeCredentials() not returning True after successfull deletion")
    }
    
    func testCredentialsManager_WhenCredentialsNotInsertedButDeleted_RemoveCredentialsShouldReturnFalse() {
        // Assert
        XCTAssertFalse(sut.removeCredentials(), "removeCredentials() not returning False after unsuccessfull deletion")
    }
}
