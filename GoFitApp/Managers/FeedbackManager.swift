//
//  feedbackManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 31/12/2021.
//

import Foundation
import UIKit

class FeedbackManager {
    
    let notificationFeedback = UINotificationFeedbackGenerator()
   
    func sendFeedbackNotification(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        notificationFeedback.notificationOccurred(notificationType)
    }
    
    func sendImpactFeedback(_ type: UIImpactFeedbackGenerator.FeedbackStyle) {
        let hapticFeedback = UIImpactFeedbackGenerator(style: type)
        hapticFeedback.impactOccurred()
    }
}
