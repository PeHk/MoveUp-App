//
//  NetworkManager+CookieStorage.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 25/11/2021.
//

import Foundation

extension NetworkManager {

    func saveTokenFromCookies(cookies: [HTTPCookie]?) {
        if let confirmedCookies = cookies {
            for cookie in confirmedCookies {
                switch cookie.name {
                case Constants.accessToken:
                    userDefaultsManager.set(value: cookie.value, forKey: Constants.accessToken)
                case Constants.refreshToken:
                    userDefaultsManager.set(value: cookie.value, forKey: Constants.refreshToken)
                default:
                    break
                }
            }
        }
    }
}
