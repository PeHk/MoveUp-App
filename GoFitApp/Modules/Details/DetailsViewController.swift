//
//  DetailsViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import UIKit
import SkyFloatingLabelTextField
import Combine

class DetailsViewController: BaseViewController,  UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var heightTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var weightTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var genderTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: PrimaryButton!
    
    var viewModel: DetailsViewModel!
    var coordinator: DetailsCoordinator!
    var subscription = Set<AnyCancellable>()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupBindings()
    }
    
    private func setupBindings() {
        viewModel.errorState
            .compactMap( { $0 })
            .assign(to: \.errorState, on: self)
            .store(in: &subscription)
        
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
        
        heightTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.height, on: viewModel)
            .store(in: &subscription)
        
        weightTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.weight, on: viewModel)
            .store(in: &subscription)
        
        // MARK: Textfields validation
        viewModel.$weight
            .sink { weight in
                if weight.count > 0 && (Int(weight) ?? 0) > 250 {
                    (self.weightTextField.errorMessage = "Weight is too big!")
                } else if weight.count > 0 && (Int(weight) ?? 0) < 20 {
                    (self.weightTextField.errorMessage = "Weight is too small!")
                } else {
                    (self.weightTextField.errorMessage = nil)
                }
            }
            .store(in: &subscription)
        
        viewModel.$height
            .sink { height in
                if height.count > 0 && (Int(height) ?? 0) > 230 {
                    (self.heightTextField.errorMessage = "Height is too big!")
                } else if height.count > 0 && (Int(height) ?? 0) < 130 {
                    (self.heightTextField.errorMessage = "Height is too small!")
                } else {
                    (self.heightTextField.errorMessage = nil)
                }
            }
            .store(in: &subscription)
        
        
        Publishers.CombineLatest3(viewModel.isInputValid, viewModel.selectedGender, viewModel.selectedDate)
            .sink(receiveValue: { (input, gender, date) in
                if !input
                    && gender != nil
                    && date != nil
                    && !self.heightTextField.hasErrorMessage
                    && !self.weightTextField.hasErrorMessage
                {
                    self.saveButton.setEnabled()
                } else {
                    self.saveButton.setDisabled()
                }
            })
            .store(in: &subscription)
    }
    
    private func setupViews() {
        self.birthDatePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        createPickerView()
    }
    
    // MARK: Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        viewModel.stepper.send(.save)
    }
    
    @IBAction func dateOfBirthPicked(_ sender: Any) {
        viewModel.selectedDate.send(birthDatePicker.date)
    }
}
