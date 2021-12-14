//
//  DetailViewControllerTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 06/12/2021.
//

import XCTest
@testable import GoFitApp
import Combine

class DetailViewControllerTests: XCTestCase {

    var dependencyContainer: DependencyContainer!
    var storyboard: UIStoryboard!
    var viewModel: DetailsViewModel!
    var sut: DetailsViewController!
    var subscription: Set<AnyCancellable>!

    override func setUp() {
        dependencyContainer = DependencyContainer()
        viewModel = DetailsViewModel(dependencyContainer)
        storyboard = UIStoryboard(name: "DetailsViewController", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
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

    func testDetailViewController_WhenCreated_HasRequiredTextFieldsEmpty() {
        XCTAssertEqual(sut?.heightTextField.text, "", "Height textfield is not initially empty")
        XCTAssertEqual(sut?.weightTextField.text, "", "Weight textfield is not initially empty")
    }

    func testDetailViewController_WhenCreated_HasLoginButtonAndAction() throws {
        // Arrange
        let saveButton: UIButton = try XCTUnwrap(sut.saveButton, "Save button has no referencing outlet")
        
        // Act
        let actions = try XCTUnwrap(saveButton.actions(forTarget: sut, forControlEvent: .touchUpInside), "Save button have no actions assigned!")
        
        // Assert
        XCTAssertEqual(actions.count, 1, "Save button have no exactly one action!")
        XCTAssertEqual(actions.first, "saveButtonTapped:", "There is no correct action assigned")
    }
    
    func testDetailViewController_WhenDetailButtonTapped_InvokesDetailSavingProcess() {
        // Act
        sut.saveButton.sendActions(for: .touchUpInside)
        
        // Assert
        viewModel.action
            .sink { action in
                XCTAssertEqual(action, DetailsViewModel.Action.saveTapped, "Wrong action assigned to on save button")
            }
            .store(in: &subscription)
    }
}
