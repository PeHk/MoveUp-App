//
//  NotificationManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 18/04/2022.
//

import Foundation
import NotificationCenter

class NotificationManager {

    init(_ dependencyContainer: DependencyContainer) {
       requestPermissions()
    }
    
    private func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("[Notifications allowed]")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    public func sendLocalNotification(title: String, subtitle: String, timeInterval: TimeInterval, repeats: Bool = false, sound: UNNotificationSound = .default) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = sound

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
