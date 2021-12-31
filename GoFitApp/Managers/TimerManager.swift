//
//  TimerManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 31/12/2021.
//

import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var timeString = ""
    
    private var time = Int()
    private var timer: Timer?
    
    public func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.time += 1
            self.countdown()
        }
    }
    
    public func stopTimer() {
        timer?.invalidate()
        time = Int()
        timeString = ""
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

}
