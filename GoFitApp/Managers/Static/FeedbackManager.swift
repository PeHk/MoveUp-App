//
//  feedbackManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 31/12/2021.
//

import Foundation
import UIKit

final class FeedbackManager {

    static func sendFeedbackNotification(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(notificationType)
    }
    
    static func sendImpactFeedback(_ type: UIImpactFeedbackGenerator.FeedbackStyle) {
        let hapticFeedback = UIImpactFeedbackGenerator(style: type)
        hapticFeedback.impactOccurred()
    }
}
