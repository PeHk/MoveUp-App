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
    
    func testUserManager_WhenUserWithDataInserted_BioDataShouldEquals() {
        // Arrange
        let data = BioDataResource(weight: 94, height: 184, activity_minutes: 200, bmi: 26.5)
        let user = UserDataResource(id: 1, email: "test@test.com", name: "Test", admin: false, registered_at: "2021-06-11'T'00:00:00", date_of_birth: "2021-06-11'T'00:00:00", gender: "male", bio_data: [data])
        
        // Act
        sut.saveUserWithData(newUser: user)
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
                XCTAssertEqual(users.first?.bio_data?.count, 1)
            }
            .store(in: &subscription)
    }
}
