//
//  BSStringUtils.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 19/06/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

public class BSStringUtils: NSObject {
       
    open class func removeWhitespaces(_ str : String) -> String {
        return str.components(separatedBy: .whitespaces).joined()
    }
    
    open class func splitName(_ str: String) -> (firstName: String, lastName: String)? {
        
        if let p = str.firstIndex(of: " ") {
            let firstName = str[..<p].trimmingCharacters(in: .whitespaces)
            let lastName = str[p..<str.endIndex].trimmingCharacters(in: .whitespaces)
            return (firstName, lastName)
        } else {
            return (str, "")
        }
    }
    
    open class func last4(_ str: String) -> String {
        
        let digits = removeNoneDigits(str)
        if digits.count >= 4 {
            let p = digits.index(digits.endIndex, offsetBy: -4)
            return String(digits[p..<digits.endIndex])
        } else {
            return ""
        }
    }
    
    open class func removeNoneAlphaCharacters(_ str: String) -> String {
        
        var result : String = "";
        for character in str {
            if (character == " ") || (character >= "a" && character <= "z") || (character >= "A" && character <= "Z") {
                result.append(character)
            }
        }
        return result
    }
    
    open class func removeNoneEmailCharacters(_ str: String) -> String {
        
        var result : String = "";
        for character in str {
            if (character == "-") ||
                (character == "_") ||
                (character == ".") ||
                (character == "@") ||
                (character >= "0" && character <= "9") ||
                (character >= "a" && character <= "z") ||
                (character >= "A" && character <= "Z") {
                result.append(character)
            }
        }
        return result
    }
    
    open class func removeNoneDigits(_ str: String) -> String {
        
        var result : String = "";
        for character in str {
            if (character >= "0" && character <= "9") {
                result.append(character)
            }
        }
        return result
    }
    
    open class func cutToMaxLength(_ str: String, maxLength: Int) -> String {
        if (str.count < maxLength) {
            return str
        } else {
            let idx = str.index(str.startIndex, offsetBy: maxLength)
            return String(str[..<idx])
        }
    }
    
    open class func startsWith(theString: String, subString: String) -> Bool {
        
        guard let range = theString.range(of: subString, options: [.anchored]) else {
            return false
        }
        
        return range.lowerBound == theString.startIndex
    }

}
