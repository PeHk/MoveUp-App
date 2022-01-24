//
//  Constants.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 22/11/2021.
//

import Foundation

struct Constants {
    
    static let usernameKey = "username"
    static let passwordKey = "password"
    static let serviceName = "goFitApp"
    static let accessToken = "access_token_cookie"
    static let refreshToken = "refresh_token_cookie"
       
// MARK: LOCAL CONFIG
//    static let cookieDomain = "192.168.0.104"
//    static let cookieAccessPath = "/api"
//    static let cookieRefreshPath = "/auth/refresh"
    
// MARK: DEVELOPMENT CONFIG
    static let cookieDomain = "pehk.rocks"
    static let cookieAccessPath = "/backend_develop/api"
    static let cookieRefreshPath = "/backend_develop/auth/refresh"
    
// MARK: PRODUCTION CONFIG
//    static let cookieDomain = "pehk.rocks"
//    static let cookieAccessPath = "/backend_production/api"
//    static let cookieRefreshPath = "/backend_production/auth/refresh"

    static let isLoggedIn = "loggedIn"
    static let stepsGoal = "stepsGoal"
    static let caloriesGoal = "caloriesGoal"
    static let backupDate = "backupDate"
    static let sportBackupDate = "sportBackupDate"
    static let permissions = "healthPermissions"
    
    static let errorWhileSaving = "Error while saving the data"
    static let errorWhileGetting = "Error while getting the data"
    static let errorWhileDeleting = "Error while deleting the data"
    static let userNotFound = "Current user not found!"
    
    static let loggedOutTitle = "Logged out!"
    static let loggedOutDescription = "You have been successfully logged out!"
    
    static let interceptorDescription = "Please log in again!"
    
    static let supportAddress = "https://forms.gle/ADimvyVnpRfrgwDC7"
}
