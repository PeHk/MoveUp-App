//
//  HelpersTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 04/12/2021.
//

import XCTest
@testable import GoFitApp

class HelpersTests: XCTestCase {
    
    var formatter: DateFormatter!

    override func setUp() {
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
    }

    override func tearDown() {
        formatter = nil
    }
    
    func testFormatDate_WhenValidDateProvided_ShouldBeEquals() {
    
        // Arrange
        let date = formatter.date(from: "2016/10/08 22:31")!
        
        // Act
        let sut = Helpers.formatDate(from: date)
        
        // Assert
        XCTAssertEqual(sut, "2016-10-08T22:31:00", "The formatDate() should have returned formatted date as a string but returned string is NOT EQUAL")
    }

}
