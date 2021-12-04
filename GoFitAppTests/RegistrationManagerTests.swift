//
//  RegistrationManagerTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 04/12/2021.
//

import XCTest
@testable import GoFitApp

class RegistrationManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        let signUpModel = SignUpRequestModel(email: "p.hlavatik@gmail.com", name: "Peter", password: "123456")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
