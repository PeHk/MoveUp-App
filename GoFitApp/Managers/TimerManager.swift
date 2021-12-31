//
//  TimerManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 31/12/2021.
//

import Foundation
import Combine
import UIKit

class TimerManager: ObservableObject {
    @Published var timeString = "00:00:00"
    
    private(set) public var time = Int()
    private var timer: Timer?
    private var notificationDate: Date?
    var subscription = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification, object: nil)
            .sink { _ in
                self.movingToBackground()
            }
            .store(in: &subscription)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification, object: nil)
            .sink { _ in
                self.movingToForeground()
            }
            .store(in: &subscription)
    }
    
    public func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.time += 1
            self.countdown()
        }
    }
    
    public func stopTimer() {
        timer?.invalidate()
        time = Int()
        timeString = "00:00:00"
    }
    
    public func pauseTimer() {
        timer?.invalidate()
    }
    
    @objc private func countdown() {
        var hours: Int
        var minutes: Int
        var seconds: Int

        if time == 0 {
            timer?.invalidate()
        }
        
        hours = time / 3600
        minutes = (time % 3600) / 60
        seconds = (time % 3600) % 60
        timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func movingToBackground() {
        notificationDate = Date()
        self.pauseTimer()
    }
    
    private func movingToForeground() {
        let deltaTime: Int = Int(Date().timeIntervalSince(notificationDate ?? Date()))
        self.time += deltaTime
        self.startTimer()
    }

}
