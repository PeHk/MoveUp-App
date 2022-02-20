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
import Alamofire

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var appCoordinator: AppCoordinator?
    var window: UIWindow?
    var subscription = Set<AnyCancellable>()
    var dependencyContainer: DependencyContainer?
    var networkManager: NetworkManager?
    
    // MARK: Finish launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.dependencyContainer = DependencyContainer()
        self.networkManager = dependencyContainer?.networkManager
        self.dependencyContainer?.networkMonitor.startMonitoring()
        
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
    
    // MARK: Registration of APN
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        self.registerAPN(token: token)
            .sink { completion in
                if case .failure(_) = completion {
                    application.unregisterForRemoteNotifications()
                }
            } receiveValue: { apn in
                print("Successfully registered for APN:", apn)
            }
            .store(in: &subscription)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    private func registerAPN(token: String) -> Future<TokenResource, NetworkError> {
        return Future { promise in
            if let networkManager = self.networkManager {
                let withToken = TokenResource(uuid: token)
                
                let apnPublisher: AnyPublisher<DataResponse<TokenResource, NetworkError>, Never> = networkManager.request(
                    Endpoint.apn.url,
                    method: .post,
                    parameters: withToken.tokenJSON(),
                    withInterceptor: false
                )
                
                apnPublisher
                    .sink { dataResponse in
                        if let error = dataResponse.error {
                            promise(.failure(error))
                        } else {
                            promise(.success(dataResponse.value!))
                        }
                    }
                    .store(in: &self.subscription)
            } else {
                promise(.failure(NetworkError(initialError: nil, backendError: nil, NSError())))
            }
        }
    }
}

