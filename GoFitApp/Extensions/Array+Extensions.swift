//
//  Array+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 16/04/2022.
//

import Foundation

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
