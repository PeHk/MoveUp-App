//
//  DetailsViewController+Picker.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 26/11/2021.
//

import Foundation
import UIKit

extension DetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.countryList.count // number of dropdown items
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.countryList[row] // dropdown item
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedCountry = viewModel.countryList[row]
        genderTextField.text = viewModel.selectedCountry
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        genderTextField.inputView = pickerView
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        genderTextField.inputAccessoryView = toolBar
    }
    
    @objc func action() {
        view.endEditing(true)
    }
}
