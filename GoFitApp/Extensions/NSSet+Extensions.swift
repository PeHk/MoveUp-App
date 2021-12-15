//
//  NSSet+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 15/12/2021.
//

import Foundation

extension NSSet {
  func toArray<T>() -> [T] {
    let array = self.map({ $0 as! T})
    return array
  }
}

