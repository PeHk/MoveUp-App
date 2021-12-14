//
//  BaseTableViewController.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 28/11/2021.
//

import Foundation
import UIKit

class BaseTableViewController: UITableViewController {
    
    var isLoading: Bool = false {
        didSet {
            isLoading ? self.activityIndicatorBegin() : self.activityIndicatorEnd()
        }
    }
    
    var errorState: NetworkError? {
        didSet {
            handleError(errorState ?? nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(asset: Asset.backButton),
            style: UIBarButtonItem.Style.done,
            target: navigationController,
            action: #selector(navigationController?.goBack))
        
    }
    
    func activityIndicatorBegin() {
        self.view.isUserInteractionEnabled = false
        if let parent = self.parent {
            parent.view.showLoadingView()
        } else {
            self.view.showLoadingView()
        }
    }
    
    func activityIndicatorEnd() {
        self.view.isUserInteractionEnabled = true
        if let parent = self.parent {
            parent.view.removeLoadingView()
        } else {
            self.view.removeLoadingView()
        }
    }
    
    func handleError(_ error: NetworkError?) {
        if error != nil {
            AlertManager.showAlert(message: error?.backendError?.message ?? error?.initialError?.errorDescription ?? error?.coreDataError.debugDescription, over: self)
        }
    }
}
