//
//  UserManagerTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 10/12/2021.
//

import XCTest
@testable import GoFitApp
import Combine

class UserManagerTests: XCTestCase {
    
    var sut: UserManager!
    var dependencyContainer: DependencyContainer!
    var subscription: Set<AnyCancellable>!

    override func setUp() {
        dependencyContainer = DependencyContainer()
        sut = UserManager(dependencyContainer)
        subscription = Set<AnyCancellable>()
    }

    override func tearDown()  {
        sut.deleteUser()
            .sink { _ in
                ()
            } receiveValue: { _ in
                ()
            }
            .store(in: &subscription)

        sut = nil
        dependencyContainer = nil
        subscription = nil
    }
    
    func testUserManager_WhenUserInserted_UsersCountShouldEquals() {
        // Arrange
        let user = UserResource(id: 1, email: "test@test.com", name: "Test", admin: false, registered_at: "2021-06-11'T'00:00:00")
        
        // Act
        sut.saveUser(newUser: user)
            .sink { _ in
                ()
            } receiveValue: { _ in
                ()
            }
            .store(in: &subscription)

        // Assert
        sut.getUser()
            .sink { _ in
                ()
            } receiveValue: { users in
                XCTAssertEqual(users.count, 1)
            }
            .store(in: &subscription)

    }
    
    func testUserManager_WhenUserDeleted_UsersCountShouldEquals() {
        // Arrange
        let user = UserResource(id: 1, email: "test@test.com", name: "Test", admin: false, registered_at: "2021-06-11'T'00:00:00")
        
        sut.saveUser(newUser: user)
            .sink { _ in
                ()
            } receiveValue: { _ in
                ()
            }
            .store(in: &subscription)
        
        // Act
        sut.deleteUser()
            .sink { _ in
                ()
            } receiveValue: { _ in
                ()
            }
            .store(in: &subscription)
        
        // Assert
        sut.getUser()
            .sink { _ in
                ()
            } receiveValue: { users in
                XCTAssertEqual(users.count, 0)
            }
            .store(in: &subscription)
    }
}
