//
//  NetworkManager+CookieStorage.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 25/11/2021.
//

import Foundation
import Alamofire

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
    
    func setupCookies() {
        if let accessToken = userDefaultsManager.get(forKey: Constants.accessToken),
           let refreshToken = userDefaultsManager.get(forKey: Constants.refreshToken) {
            let access = [
                HTTPCookiePropertyKey.domain: Constants.cookieDomain,
                HTTPCookiePropertyKey.path: Constants.cookieAccessPath,
                HTTPCookiePropertyKey.name: Constants.accessToken,
                HTTPCookiePropertyKey.value: accessToken
            ]
            let refresh = [
                HTTPCookiePropertyKey.domain: Constants.cookieDomain,
                HTTPCookiePropertyKey.path: Constants.cookieRefreshPath,
                HTTPCookiePropertyKey.name: Constants.refreshToken,
                HTTPCookiePropertyKey.value: refreshToken
            ]
            if let accessCookie = HTTPCookie(properties: access), let refreshCookie = HTTPCookie(properties: refresh) {
                AF.session.configuration.httpCookieStorage?.setCookie(accessCookie)
                AF.session.configuration.httpCookieStorage?.setCookie(refreshCookie)
            }
        }
    }
}
