//
//  Int+Extension.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/20.
//

import Foundation

extension Int {
    func formatUsingAbbrevation () -> String {
        let numFormatter = NumberFormatter()

        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (1000.0, 1000.0, "천"),
                                           (10000.0, 10000.0, "만")]
                                           // you can add more !
        let startValue = Double (abs(self))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()

        let value = Double(self) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        if abbreviation.divisor == 10000 {
            numFormatter.maximumFractionDigits = 1
        } else {
            numFormatter.maximumFractionDigits = 2
        }

        return numFormatter.string(from: NSNumber(value: value))!
    }
}
