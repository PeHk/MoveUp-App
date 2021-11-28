//
//  Optional+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 28/11/2021.
//

import Foundation

extension Optional where Wrapped == NSSet {
    func array<T: Hashable>(of: T.Type) -> [T] {
        if let set = self as? Set<T> {
            return Array(set)
        }
        return [T]()
    }
}
