//
//  UserDefaultsManagerTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 11/12/2021.
//

import XCTest
@testable import GoFitApp
import Combine

class UserDefaultsManagerTests: XCTestCase {
    
    var sut: UserDefaultsManager!
    var dependencyContainer: DependencyContainer!
    var subscription: Set<AnyCancellable>!


    override func setUp() {
        dependencyContainer = DependencyContainer()
        sut = UserDefaultsManager(dependencyContainer)
        subscription = Set<AnyCancellable>()
    }

    override func tearDown() {
        sut.resetDefaults()
        
        sut = nil
        dependencyContainer = nil
        subscription = nil
    }

    func testUserDefaultsManager_WhenSetLoggedInCalled_ShouldReturnTrue() {
        // Arrange
        XCTAssertFalse(sut.isLoggedIn(), "Is Logged in is set to different value")
        
        // Act
        sut.setLoggedIn()
        
        // Assert
        XCTAssertTrue(sut.isLoggedIn(), "Is Logged in is set to different value")
    }
    
    func testUserDefaultsManager_WhenSetLoggedOutCalled_ShouldReturnFalse() {
        // Arrange
        sut.setLoggedIn()
        XCTAssertTrue(sut.isLoggedIn(), "Is Logged in is set to different value")
        
        // Act
        sut.setLoggedOut()
        
        // Assert
        XCTAssertFalse(sut.isLoggedIn(), "Is Logged in is set to different value")
    }
    
    func testUserDefaultsManager_WhenSetValueCalled_ShouldReturnEqualValue() {
        // Act
        sut.set(value: UserDefaultsManagerTestsConstants.value, forKey: UserDefaultsManagerTestsConstants.key)
        
        // Assert
        let value = sut.get(forKey: UserDefaultsManagerTestsConstants.key) as! String
        XCTAssertEqual(value, UserDefaultsManagerTestsConstants.value, "Returned value is not the same")
    }
    
    func testUserDefaultsManager_WhenSetValueCalledInvalid_ShouldReturnNonEqualValue() {
        // Act
        sut.set(value: UserDefaultsManagerTestsConstants.value, forKey: UserDefaultsManagerTestsConstants.key)
        
        // Assert
        XCTAssertNil(sut.get(forKey: "UserDefaultsManagerTestsConstants.key"), "Returned value is not nil")
    }
}
