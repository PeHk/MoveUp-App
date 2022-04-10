//
//  FloatingPoint+Extension.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 10/04/2022.
//

import Foundation

extension FloatingPoint {
    func converting(from input: ClosedRange<Self>, to output: ClosedRange<Self>) -> Self {
        let x = (output.upperBound - output.lowerBound) * (self - input.lowerBound)
        let y = (input.upperBound - input.lowerBound)
        return x / y + output.lowerBound
    }
}
