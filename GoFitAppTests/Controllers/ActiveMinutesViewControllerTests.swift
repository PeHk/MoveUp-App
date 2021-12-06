//
//  ActiveMinutesViewControllerTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 06/12/2021.
//

import XCTest
@testable import GoFitApp
import Combine

class ActiveMinutesViewControllerTests: XCTestCase {

    var dependencyContainer: DependencyContainer!
    var storyboard: UIStoryboard!
    var viewModel: SetActiveMinutesViewModel!
    var sut: SetActiveMinutesViewController!
    var subscription: Set<AnyCancellable>!

    override func setUp() {
        dependencyContainer = DependencyContainer()
        viewModel = SetActiveMinutesViewModel(dependencyContainer)
        storyboard = UIStoryboard(name: "SetActiveMinutesViewController", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "SetActiveMinutesViewController") as? SetActiveMinutesViewController
        sut?.viewModel = viewModel
        sut?.loadViewIfNeeded()
        subscription = Set<AnyCancellable>()
    }

    override func tearDown() {
        storyboard = nil
        viewModel = nil
        dependencyContainer = nil
        sut = nil
        subscription = nil
    }

    func testSetActiveMinutesViewController_WhenCreated_HasLabelInitialValue() throws {
        let minutesField = try XCTUnwrap(sut.minutesField)
        
        XCTAssertEqual(minutesField.text, "150")
    }
    
    func testSetActiveMinutesViewController_WhenCreated_HasIncreaseRecognizer() throws {
        // Arrange
        let increaseView: UIView = try XCTUnwrap(sut.plusButtonView, "Increase view has no referencing outlet")
        
        // Act
        let recognizers = try XCTUnwrap(increaseView.gestureRecognizers, "Increase view has no gesture recognizers initialized")
        
        
        // Assert
        XCTAssertEqual(recognizers.count, 1, "Increase view have no exactly one recognizer!")
    }
    
    func testSetActiveMinutesViewController_WhenCreated_HasDecreaseRecognizer() throws {
        // Arrange
        let decreaseView: UIView = try XCTUnwrap(sut.minusButtonView, "Decrease view has no referencing outlet")
        
        // Act
        let recognizers = try XCTUnwrap(decreaseView.gestureRecognizers, "Decrease view has no gesture recognizers initialized")
        
        
        // Assert
        XCTAssertEqual(recognizers.count, 1, "Decrease view have no exactly one recognizer!")
    }
}
