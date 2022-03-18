//
//  String+Extension.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import Foundation
import UIKit

extension String {
    
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func removeSpecialCharsFromString() -> String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return self.filter { okayChars.contains($0) }
    }
    
}
