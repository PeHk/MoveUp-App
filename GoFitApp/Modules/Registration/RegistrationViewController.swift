//
//  RegistrationViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/10/2021.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var informationView: UIView! {
        didSet {
            informationView.layer.cornerRadius = 25
        }
    }
    var viewModel: RegistrationViewModel!
    var coordinator: RegistrationCoodrinator!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
