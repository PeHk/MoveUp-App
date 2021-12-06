//
//  HomeViewControllerTests.swift
//  GoFitAppTests
//
//  Created by Peter Hlavatík on 06/12/2021.
//

import XCTest
@testable import GoFitApp
import Combine

class HomeViewControllerTests: XCTestCase {

    var dependencyContainer: DependencyContainer!
    var storyboard: UIStoryboard!
    var viewModel: HomeViewModel!
    var sut: HomeViewController!
    var subscription: Set<AnyCancellable>!

    override func setUp() {
        dependencyContainer = DependencyContainer()
        viewModel = HomeViewModel(dependencyContainer)
        storyboard = UIStoryboard(name: "HomeViewController", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
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

    func testHomeViewController_WhenCreated_HasGetStartedButtonAndAction() throws {
        // Arrange
        let getStarted: UIButton = try XCTUnwrap(sut.getStarted, "Get Started button has no referencing outlet")
        
        // Act
        let actions = try XCTUnwrap(getStarted.actions(forTarget: sut, forControlEvent: .touchUpInside), "Get Started button have no actions assigned!")
        
        // Assert
        XCTAssertEqual(actions.count, 1, "Get Started button have no exactly one action!")
        XCTAssertEqual(actions.first, "getStartedTapped:", "There is no correct action assigned")
    }
    
    func testHomeViewController_WhenCreated_HasLoginButtonAndAction() throws {
        // Arrange
        let login: UIButton = try XCTUnwrap(sut.login, "Already have an account button has no referencing outlet")
        
        // Act
        let actions = try XCTUnwrap(login.actions(forTarget: sut, forControlEvent: .touchUpInside), "Already have an account button have no actions assigned!")
        
        // Assert
        XCTAssertEqual(actions.count, 1, "Already have an account button have no exactly one action!")
        XCTAssertEqual(actions.first, "loginTapped:", "There is no correct action assigned")
    }
    
    func testHomeViewController_WhenLoginButtonTapped_InvokesLoginProcess() {
        // Act
        sut.login.sendActions(for: .touchUpInside)
        
        // Assert
        viewModel.stepper
            .sink { step in
                XCTAssertEqual(step, HomeViewModel.Step.login, "Wrong step assigned to on login button")
            }
            .store(in: &subscription)
    }
    
    func testHomeViewController_WhenGetStartedButtonTapped_InvokesRegistrationProcess() {
        // Act
        sut.getStarted.sendActions(for: .touchUpInside)
        
        // Assert
        viewModel.stepper
            .sink { step in
                XCTAssertEqual(step, HomeViewModel.Step.getStarted, "Wrong step assigned to on get started button")
            }
            .store(in: &subscription)
    }
}
