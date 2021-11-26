//
//  DetailsViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import UIKit
import SkyFloatingLabelTextField

class DetailsViewController: BaseViewController,  UITextFieldDelegate {
    
    @IBOutlet weak var genderTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: PrimaryButton!
    
    var viewModel: DetailsViewModel!
    var coordinator: DetailsCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    private func setupViews() {
        self.birthDatePicker.maximumDate = Date()
        createPickerView()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        viewModel.stepper.send(.save)
    }
}
