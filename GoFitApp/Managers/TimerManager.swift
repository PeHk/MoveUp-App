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
    
    private(set) public var time = Double()
    public var isPaused: Bool = false
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
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.time += 1
            self.countdown()
        }
    }
    
    public func stopTimer() {
        self.timer?.invalidate()
        self.time = Double()
        self.timeString = "00:00:00"
    }
    
    public func pauseTimer() {
        self.timer?.invalidate()
    }
    
    @objc private func countdown() {
        var hours: Int
        var minutes: Int
        var seconds: Int

        if time == 0 {
            timer?.invalidate()
        }
        
        hours = Int(time) / 3600
        minutes = (Int(time) % 3600) / 60
        seconds = (Int(time) % 3600) % 60
        timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func movingToBackground() {
        if !isPaused {
            notificationDate = Date()
            self.pauseTimer()
        }
    }
    
    private func movingToForeground() {
        if !isPaused {
            let deltaTime: Double = Date().timeIntervalSince(notificationDate ?? Date())
            self.time += deltaTime
            self.startTimer()
        }
    }

}
