//
//  ActivityRecommendationViewModel.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/04/2022.
//

import Foundation
import UIKit

struct ActivityRecommendationViewModel {
    var created_at: Date
    var start_time: Date
    var end_time: Date
    var sport: Sport?
    
    func checkDate() -> String {
        if Calendar.current.isDateInToday(start_time) {
            return "Today"
        } else {
            return "Tomorrow"
        }
    }
}

