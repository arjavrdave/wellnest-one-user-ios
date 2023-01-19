//
//  StringUtil.swift
//  Saiyarti
//
//  Created by Rakib Royale on 08/03/19.
//  Copyright © 2019 Royale Cheese. All rights reserved.
//

import Foundation
import CoreImage
import UIKit

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func trim() -> String {
        if self == "" {
            return ""
        } else {
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func isLessThan(maxLength: Int) -> Bool {
        return (self.count <= maxLength)
    }
    
    func isGratterThan(minLength: Int) -> Bool {
        return (self.count >= minLength)
    }
    func isEqualTo(length: Int) -> Bool {
        return (self.count == length)
    }
    
    func isValidName() -> Bool {
        let regex = "^[a-zA-Z0-9 ]*$"
        let stringTest = NSPredicate(format:"SELF MATCHES %@", regex)
        let result = stringTest.evaluate(with: self)
        return result
    }
    func isValidNameWithSpecialCharacters() -> Bool {
        let regex = "^[a-zA-Z0-9 !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]+]*$"
        let stringTest = NSPredicate(format:"SELF MATCHES %@", regex)
        let result = stringTest.evaluate(with: self)
        return result
    }
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,99}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.trim())
    }
    func isValidPhone() -> Bool {
        return  self.numbersOnly().isGratterThan(minLength: 7) && self.numbersOnly().isLessThan(maxLength: 13)
    }
    func numbersOnly() -> String {
        let numbersOnly = self.trim().components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return numbersOnly
    }

    
    subscript(index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
    
    func formatePhoneNumber() -> String {
        let numbersOnly = self.formateOnlyNumbers()
        var formatedNumbers = String()
        
        for index in 0..<numbersOnly.count {
            let strChar = numbersOnly[numbersOnly.index(numbersOnly.startIndex, offsetBy: index)]
            formatedNumbers.append(strChar)
        }
        return formatedNumbers
    }

}
