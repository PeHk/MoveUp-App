//
//  AppDelegate.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/10/2021.
//

import UIKit
import CoreData
import Combine
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var appCoordinator: AppCoordinator?
    var window: UIWindow?
    var subscription = Set<AnyCancellable>()
    var dependencyContainer: DependencyContainer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.dependencyContainer = DependencyContainer()
        
        let navigationController: UINavigationController = .init()
        
        if #available(iOS 13.0, *) {
            let appearence = UINavigationBarAppearance()
            appearence.configureWithOpaqueBackground()
            appearence.backgroundColor = Asset.backgroundColor.color
            appearence.shadowColor = nil
            appearence.shadowImage = nil
            navigationController.navigationBar.standardAppearance = appearence
            navigationController.navigationBar.scrollEdgeAppearance = navigationController.navigationBar.standardAppearance
        } else {
            navigationController.navigationBar.isTranslucent = false
            navigationController.navigationBar.barTintColor = Asset.backgroundColor.color
            navigationController.navigationBar.shadowImage = nil
        }
        
        navigationController.navigationBar.tintColor = Asset.primary.color
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        appCoordinator = AppCoordinator(navigationController, self.dependencyContainer!)
        appCoordinator?.start()
        
        return true
    }
}

