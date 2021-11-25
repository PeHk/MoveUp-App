//
//  DetailsViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import UIKit
import SkyFloatingLabelTextField

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: PrimaryButton!
    @IBOutlet weak var genderPicker: UIView! {
        didSet {
            genderPicker.addBottomBorder(color: .lightGray, margins: 0, borderLineSize: 0.5)
        }
    }
    var viewModel: DetailsViewModel!
    var coordinator: DetailsCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    private func setupViews() {
        self.birthDatePicker.maximumDate = Date()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        viewModel.stepper.send(.save)
    }
}
