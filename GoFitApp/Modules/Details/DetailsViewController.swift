//
//  DetailsViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import UIKit
import CloudKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var genderPicker: UIView! {
        didSet {
            genderPicker.addBottomBorder(color: .lightGray, margins: 0, borderLineSize: 0.5)
        }
    }
    var viewModel: DetailsViewModel!
    var coordinator: DetailsCoordinator!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
