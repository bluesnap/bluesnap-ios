//
//  BSValidator.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 04/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import NaturalLanguage
import UIKit

public class BSValidator: NSObject {
    
    
    // MARK: Constants
    
    public static let ccnInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_CCN)
    public static let cvvInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_CVV)
    public static let expMonthInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_ExpMonth)
    public static let expPastInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_ExpIsInThePast)
    public static let expInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_EXP)
    public static let nameInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_Name)
    public static let emailInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_Email)
    public static let addressInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_Address)
    public static let cityInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_City)
    public static let countryInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_Country)
    public static let stateInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_State)
    public static let zipCodeInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_ZipCode)
    public static let postalCodeInvalidMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_Invalid_PostalCode)

    static let defaultFieldColor = BSColorCompat.label

    static let errorFieldColor = UIColor.systemRed

    // MARK: private properties
    internal static var cardTypesRegex = [Int: (cardType: String, regexp: String)]()
    
    // MARK: validation functions (check UI field and hide/show errors as necessary)
    
    class func validateName(ignoreIfEmpty: Bool, input: BSBaseTextInput, addressDetails: BSBaseAddressDetails?) -> Bool {
        
        var result : Bool = true
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
        input.setValue(newValue)
        if let addressDetails = addressDetails {
            addressDetails.name = newValue
        }
        if newValue.count == 0 && ignoreIfEmpty {
            // ignore
        } else if !isValidName(newValue) {
            result = false
        }
        if result {
            input.hideError()
        } else {
            input.showError(nameInvalidMessage)
        }
        return result
    }
    
    class func validateEmail(ignoreIfEmpty: Bool, input: BSBaseTextInput, addressDetails: BSBillingAddressDetails?) -> Bool {
        
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
        input.setValue(newValue)
        if let addressDetails = addressDetails {
            addressDetails.email = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.count == 0) {
            // ignore
        } else if (!isValidEmail(newValue)) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
        } else {
            input.showError(emailInvalidMessage)
        }
        return result
    }

//     // no validation yet, this is just a preparation
//    class func validatePhone(ignoreIfEmpty : Bool, input: BSInputLine, addressDetails: BSShippingAddressDetails?) -> Bool {
//
//        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
//        input.setValue(newValue)
//        if let addressDetails = addressDetails {
//            addressDetails.phone = newValue
//        }
//        return true
//    }

    class func validateAddress(ignoreIfEmpty : Bool, input: BSBaseTextInput, addressDetails: BSBaseAddressDetails?) -> Bool {
        
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
        input.setValue(newValue)
        if let addressDetails = addressDetails {
            addressDetails.address = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.count == 0) {
            // ignore
        } else if !isValidAddress(newValue) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
        } else {
            input.showError(addressInvalidMessage)
        }
        return result
    }
    
    class func validateCity(ignoreIfEmpty : Bool, input: BSBaseTextInput, addressDetails: BSBaseAddressDetails?) -> Bool {
        
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
        input.setValue(newValue)
        if let addressDetails = addressDetails {
            addressDetails.city = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.count == 0) {
            // ignore
        } else if !isValidCity(newValue) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
        } else {
            input.showError(cityInvalidMessage)
        }
        return result
    }
    
    class func validateCountry(ignoreIfEmpty : Bool, input: BSBaseTextInput, addressDetails: BSBaseAddressDetails?) -> Bool {
        
        let newValue = addressDetails?.country ?? ""
        var result : Bool = true
        if (ignoreIfEmpty && newValue.count == 0) {
            // ignore
        } else if !isValidCountry(countryCode: newValue) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
        } else {
            input.showError(countryInvalidMessage)
        }
        return result
    }

    class func validateZip(ignoreIfEmpty : Bool, input: BSBaseTextInput, addressDetails: BSBaseAddressDetails?) -> Bool {
        
        var result : Bool = true
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
        input.setValue(newValue)
        if let addressDetails = addressDetails {
            addressDetails.zip = newValue
        }
        if (ignoreIfEmpty && newValue.count == 0) {
            // ignore
        } else if !isValidZip(countryCode: addressDetails?.country ?? "", zip: newValue) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
        } else {
            let errorText = getZipErrorText(countryCode: addressDetails?.country ?? "")
            input.showError(errorText)
        }
        return result
    }

    class func validateState(ignoreIfEmpty : Bool, input: BSBaseTextInput, addressDetails: BSBaseAddressDetails?) -> Bool {
        
        let newValue = addressDetails?.state ?? ""
        var result : Bool = true
        if ((ignoreIfEmpty || input.isHidden) && newValue.count == 0) {
            // ignore
        } else if !isValidCountry(countryCode: addressDetails?.country ?? "") {
            result = false
        } else if !isValidState(countryCode: addressDetails?.country ?? "", stateCode: addressDetails?.state) {
            result = false
        }
        if result {
            input.hideError()
        } else {
            input.showError(stateInvalidMessage)
        }
        return result
    }
    
    class func validateExp(input: BSCcInputLine) -> Bool {
        
        var ok : Bool = true
        var msg : String = expInvalidMessage
        
        let newValue = input.expTextField.text ?? ""
        if let p = newValue.firstIndex(of: "/") {
            let mm = String(newValue[..<p])
            let yy = BSStringUtils.removeNoneDigits(String(newValue[p ..< newValue.endIndex]))
            if (mm.count < 2) {
                ok = false
            } else if !isValidMonth(mm) {
                ok = false
                msg = expMonthInvalidMessage
            } else if (yy.count < 2) {
                ok = false
            } else {
                (ok, msg) = isCcValidExpiration(mm: mm, yy: yy)
            }
        } else {
            ok = false
        }

        if (ok) {
            input.hideExpError()
        } else {
            input.showExpError(msg)
        }
        return ok
    }
    
    class func validateCvv(input: BSCcInputLine, cardType: String) -> Bool {
        
        var result : Bool = true;
        let newValue = input.getCvv() ?? ""
        if newValue.count != getCvvLength(cardType: cardType) {
            result = false
        }
        if result {
            input.hideCvvError()
        } else {
            input.showCvvError(cvvInvalidMessage)
        }
        return result
    }
    
    class func validateCCN(input: BSCcInputLine) -> Bool {
        
        var result : Bool = true;
        let newValue : String! = input.getValue()
        if !isValidCCN(newValue) {
            result = false
        }
        if result {
            input.hideError()
        } else {
            input.showError(ccnInvalidMessage)
        }
        return result
    }

    /**
     Validate the shopper consent to store the credit card details in case it is mandatory.
     The shopper concent is mandatory only in case it is a choose new card as payment method flow (shopper configuration).
     */
    class func validateStoreCard(isShopperRequirements: Bool, isSubscriptionCharge: Bool, isStoreCard: Bool, isExistingCC: Bool) -> Bool {

        return ((isShopperRequirements || isSubscriptionCharge) && !isExistingCC) ? isStoreCard : true
    }
    
    // MARK: field editing changed methods (to limit characters and sizes)
    
    class func nameEditingChanged(_ sender: BSBaseTextInput) {
        
    }

    class func emailEditingChanged(_ sender: BSBaseTextInput) {
        
        var input : String = sender.getValue() ?? ""
        input = BSStringUtils.removeNoneEmailCharacters(input)
        input = BSStringUtils.cutToMaxLength(input, maxLength: 120)
        sender.setValue(input)
    }
    
    class func addressEditingChanged(_ sender: BSBaseTextInput) {
        
    }
    
    class func cityEditingChanged(_ sender: BSBaseTextInput) {
        
    }
    
    class func zipEditingChanged(_ sender: BSBaseTextInput) {
        
        var input : String = sender.getValue() ?? ""
        input = BSStringUtils.cutToMaxLength(input, maxLength: 20)
        sender.setValue(input)
    }
    
    class func ccnEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = BSStringUtils.removeNoneDigits(input)
        input = BSStringUtils.cutToMaxLength(input, maxLength: 21)
        input = formatCCN(input)
        sender.text = input
    }
    
    class func expEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = BSStringUtils.removeNoneDigits(input)
        input = BSStringUtils.cutToMaxLength(input, maxLength: 4)
        input = formatExp(input)
        sender.text = input
    }
    
    class func cvvEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = BSStringUtils.removeNoneDigits(input)
        input = BSStringUtils.cutToMaxLength(input, maxLength: 4)
        sender.text = input
    }

    class func updateState(addressDetails: BSBaseAddressDetails!, stateInputLine: BSBaseTextInput) {
        
        let selectedCountryCode = addressDetails.country ?? ""
        let selectedStateCode = addressDetails.state ?? ""
        var hideState : Bool = true
        stateInputLine.setValue("")
        let countryManager = BSCountryManager.getInstance()
        if countryManager.countryHasStates(countryCode: selectedCountryCode) {
            hideState = false
            if let stateName = countryManager.getStateName(countryCode: selectedCountryCode, stateCode: selectedStateCode){
                stateInputLine.setValue(stateName)
            }
        } else {
            addressDetails.state = nil
        }
        stateInputLine.isHidden = hideState
        stateInputLine.hideError()
    }

    // MARK: Basic validation functions
    
    
    open class func isValidMonth(_ str: String) -> Bool {
        
        let validMonths = ["01","02","03","04","05","06","07","08","09","10","11","12"]
        return validMonths.contains(str)
    }
    
    open class func isCcValidExpiration(mm: String, yy: String) -> (Bool, String) {
        var ok = false
        var msg = expInvalidMessage
        if let month = Int(mm), let year = Int(yy) {
            let calendar = Calendar(identifier: .gregorian)
            var dateComponents = DateComponents()
            let currYear : Int! = getCurrentYear()
            if yy.count < 4 {
                dateComponents.year = year + (currYear / 100)*100
            } else {
                dateComponents.year = year
            }
            dateComponents.month = month
            dateComponents.day = 1
            let expDate = calendar.date(from: dateComponents)!
            if dateComponents.year! > currYear + 10 {
                ok = false
            } else if expDate < Date() {
                ok = false
                msg = expPastInvalidMessage
            } else {
                ok = true
            }
        }
        return (ok, msg)
    }
    
    open class func isValidEmail(_ str: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: str)
    }
    
    open class func isValidCCN(_ str: String) -> Bool {
        
        if str.count < 6 {
            return false
        }
        
        var isOdd : Bool! = true
        var sum : Int! = 0;
        
        for character in str.reversed() {
            if (character == " ") {
                // ignore
            } else if (character >= "0" && character <= "9") {
                var digit : Int! = Int(String(character))!
                isOdd = !isOdd
                if (isOdd == true) {
                    digit = digit * 2
                }
                if digit > 9 {
                    digit = digit - 9
                }
                sum = sum + digit
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }
    
    open class func isValidName(_ str: String) -> Bool {
        
        if let p = str.firstIndex(of: " ") {
            let firstName = str[..<p].trimmingCharacters(in: .whitespaces)
            let lastName = str[p..<str.endIndex].trimmingCharacters(in: .whitespaces)
            if firstName.count < 1 || lastName.count < 1 {
                return false
            }
        } else {
            if #available(iOS 12.0, *) {
                let recognizer = NLLanguageRecognizer()
                recognizer.processString(str)
                guard let languageCode = recognizer.dominantLanguage?.rawValue else { return false }
                if (languageCode.starts(with: "ja") || languageCode.starts(with: "ko") || languageCode.starts(with: "zh")){
                    return true
                } else{
                    return false
                }
            } else {
                return false
            }
        }
        
        return true
    }
    
    open class func isValidCity(_ str: String) -> Bool {
        
        var result : Bool = false
        if (str.count < 2) {
            result = false
        } else {
            result = true
        }
        return result
    }
    
    open class func isValidAddress(_ str: String) -> Bool {
        
        var result : Bool = false
        if (str.count < 2) {
            result = false
        } else {
            result = true
        }
        return result
    }
    
    open class func isValidZip(countryCode: String, zip: String) -> Bool {
        
        var result : Bool = false
        if BSCountryManager.getInstance().countryHasNoZip(countryCode: countryCode) {
            result = true
        } else if (zip.count < 3) {
            result = false
        } else {
            result = true
        }
        return result
    }
    
    open class func isValidState(countryCode: String, stateCode: String?) -> Bool {
        
        var result : Bool = true
        if !isValidCountry(countryCode: countryCode) {
            result = false
        } else if BSCountryManager.getInstance().countryHasStates(countryCode: countryCode) {
            if stateCode == nil || (stateCode?.count != 2) {
                result = false
            } else {
                let stateName = BSCountryManager.getInstance().getStateName(countryCode: countryCode, stateCode: stateCode ?? "")
                result = stateName != nil
            }
        } else if stateCode?.count ?? 0 > 0 {
            result = false
        }
        return result
    }
    
    open class func isValidCountry(countryCode: String?) -> Bool {
        
        var result : Bool = true
        if countryCode == nil || BSCountryManager.getInstance().getCountryName(countryCode: countryCode!) == nil {
            result = false
        }
        return result
    }

    open class func getCvvLength(cardType: String) -> Int {
        var cvvLength = 3
        if cardType.lowercased() == "amex" {
            cvvLength = 4
        }
        return cvvLength
    }

    
    // MARK: formatting functions
    
    class func getCurrentYear() -> Int! {
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        let year = calendar.component(.year, from: date)
        return year
    }
    
    class func getCcLengthByCardType(_ cardType: String) -> Int! {
        
        var maxLength : Int = 16
        if cardType == "amex" {
            maxLength = 15
        } else if cardType == "dinersclub" {
            maxLength = 14
        }
        return maxLength
    }
    
    open class func formatCCN(_ str: String) -> String {
        
        var result: String
        let myLength = str.count
        if (myLength > 4) {
            let idx1 = str.index(str.startIndex, offsetBy: 4)
            result = str[..<idx1] + " "
            if (myLength > 8) {
                let idx2 = str.index(idx1, offsetBy: 4)
                result += str[idx1..<idx2] + " "
                if (myLength > 12) {
                    let idx3 = str.index(idx2, offsetBy: 4)
                    result += str[idx2..<idx3] + " " + str[idx3...]
                } else {
                    result += str[idx2...]
                }
            } else {
                result += str[idx1...]
            }
        } else {
            result = str
        }
        return result
    }
    
    open class func formatExp(_ str: String) -> String {
        
        var result: String
        let myLength = str.count
        if (myLength > 2) {
            let idx1 = str.index(str.startIndex, offsetBy: 2)
            result = str[..<idx1] + "/" + str[idx1...]
        } else {
            result = str
        }
        return result
    }

    open class func getCCTypeByRegex(_ str: String) -> String? {
        
        // remove blanks
        let ccn = BSStringUtils.removeWhitespaces(str)
        
        // Display the card type for the card Regex
        for index in 0...self.cardTypesRegex.count-1 {
            if let _ = ccn.range(of:self.cardTypesRegex[index]!.regexp, options: .regularExpression) {
                return self.cardTypesRegex[index]!.cardType
            }
        }
        return nil
    }

    // MARK: zip texts
    
    open class func getZipPlaceholderText(countryCode: String, forBilling: Bool) -> String {
        
        if countryCode.uppercased() == BSCountryManager.US_COUNTRY_CODE {
            if forBilling {
                return BSLocalizedStrings.getString(BSLocalizedString.Placeholder_Billing_Zip)
            } else {
                return BSLocalizedStrings.getString(BSLocalizedString.Placeholder_Shipping_Zip)
            }
        } else {
            return BSLocalizedStrings.getString(BSLocalizedString.Placeholder_Postal_Code)
        }
    }
    
    open class func getZipErrorText(countryCode: String) -> String {
        
        if countryCode.uppercased() == BSCountryManager.US_COUNTRY_CODE {
            return zipCodeInvalidMessage
        } else {
            return postalCodeInvalidMessage
        }
    }
    
    open class func getZipKeyboardType(countryCode: String) -> UIKeyboardType {
    
        if countryCode.uppercased() == BSCountryManager.US_COUNTRY_CODE {
            return .numberPad
        } else {
            return .numbersAndPunctuation
        }
    }
}

