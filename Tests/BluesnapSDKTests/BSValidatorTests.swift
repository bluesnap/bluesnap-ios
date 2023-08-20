//
//  BSValidatorTests.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 20/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BSValidatorTests: XCTestCase {


    override func setUp() {
        print("----------------------------------------------------")
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testValidateName() {

        let input = BSBaseTextInput()
        let addressDetails = BSBaseAddressDetails()

        XCTAssertEqual(BSValidator.validateName(ignoreIfEmpty: true, input: input, addressDetails: addressDetails), true)

        XCTAssertEqual(BSValidator.validateName(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "")
        XCTAssertEqual(addressDetails.name, "")

        input.setValue("a")
        XCTAssertEqual(BSValidator.validateName(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "a")
        XCTAssertEqual(addressDetails.name, "a")

        input.setValue("ab")
        XCTAssertEqual(BSValidator.validateName(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "ab")
        XCTAssertEqual(addressDetails.name, "ab")

        input.setValue("ab cd")
        XCTAssertEqual(BSValidator.validateName(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), true)
        XCTAssertEqual(input.getValue(), "ab cd")
        XCTAssertEqual(addressDetails.name, "ab cd")

        input.setValue(" ab cd ")
        XCTAssertEqual(BSValidator.validateName(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), true)
        XCTAssertEqual(input.getValue(), "ab cd")
        XCTAssertEqual(addressDetails.name, "ab cd")
    }

    func testValidateEmail() {

        let input = BSBaseTextInput()
        let addressDetails = BSBillingAddressDetails()

        XCTAssertEqual(BSValidator.validateEmail(ignoreIfEmpty: true, input: input, addressDetails: addressDetails), true)

        XCTAssertEqual(BSValidator.validateEmail(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "")
        XCTAssertEqual(addressDetails.email, "")

        input.setValue("aaa")
        XCTAssertEqual(BSValidator.validateEmail(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "aaa")
        XCTAssertEqual(addressDetails.email, "aaa")

        input.setValue("aaa.bbb")
        XCTAssertEqual(BSValidator.validateEmail(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "aaa.bbb")
        XCTAssertEqual(addressDetails.email, "aaa.bbb")

        input.setValue("aaa@bbb")
        XCTAssertEqual(BSValidator.validateEmail(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "aaa@bbb")
        XCTAssertEqual(addressDetails.email, "aaa@bbb")

        input.setValue("aaa@bbb.c")
        XCTAssertEqual(BSValidator.validateEmail(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "aaa@bbb.c")
        XCTAssertEqual(addressDetails.email, "aaa@bbb.c")

        input.setValue("aaa@bbb.com")
        XCTAssertEqual(BSValidator.validateEmail(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), true)
        XCTAssertEqual(input.getValue(), "aaa@bbb.com")
        XCTAssertEqual(addressDetails.email, "aaa@bbb.com")

        input.setValue(" aaa@bbb.com ")
        XCTAssertEqual(BSValidator.validateEmail(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), true)
        XCTAssertEqual(input.getValue(), "aaa@bbb.com")
        XCTAssertEqual(addressDetails.email, "aaa@bbb.com")
    }

    func testValidateAddress() {

        let input = BSBaseTextInput()
        let addressDetails = BSBaseAddressDetails()

        XCTAssertEqual(BSValidator.validateAddress(ignoreIfEmpty: true, input: input, addressDetails: addressDetails), true)

        XCTAssertEqual(BSValidator.validateAddress(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "")
        XCTAssertEqual(addressDetails.address, "")

        input.setValue("1")
        XCTAssertEqual(BSValidator.validateAddress(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "1")
        XCTAssertEqual(addressDetails.address, "1")

        input.setValue("12 Cdf")
        XCTAssertEqual(BSValidator.validateAddress(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), true)
        XCTAssertEqual(input.getValue(), "12 Cdf")
        XCTAssertEqual(addressDetails.address, "12 Cdf")

        input.setValue("  12 Cdf  ")
        XCTAssertEqual(BSValidator.validateAddress(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), true)
        XCTAssertEqual(input.getValue(), "12 Cdf")
        XCTAssertEqual(addressDetails.address, "12 Cdf")
    }

    func testValidateCity() {

        let input = BSBaseTextInput()
        let addressDetails = BSBaseAddressDetails()

        XCTAssertEqual(BSValidator.validateCity(ignoreIfEmpty: true, input: input, addressDetails: addressDetails), true)

        XCTAssertEqual(BSValidator.validateCity(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "")
        XCTAssertEqual(addressDetails.city, "")

        input.setValue("2")
        XCTAssertEqual(BSValidator.validateCity(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "2")
        XCTAssertEqual(addressDetails.city, "2")

        input.setValue("12 Cdf")
        XCTAssertEqual(BSValidator.validateCity(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), true)
        XCTAssertEqual(input.getValue(), "12 Cdf")
        XCTAssertEqual(addressDetails.city, "12 Cdf")

        input.setValue("  12 Cdf  ")
        XCTAssertEqual(BSValidator.validateCity(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), true)
        XCTAssertEqual(input.getValue(), "12 Cdf")
        XCTAssertEqual(addressDetails.city, "12 Cdf")
    }

    func testValidateCountry() {

        let input = BSBaseTextInput()
        let addressDetails = BSBaseAddressDetails()
        var result: Bool

        addressDetails.country = nil
        result = BSValidator.validateCountry(ignoreIfEmpty: true, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, true)

        addressDetails.country = ""
        result = BSValidator.validateCountry(ignoreIfEmpty: true, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, true)

        addressDetails.country = nil
        result = BSValidator.validateCountry(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, false)

        addressDetails.country = ""
        result = BSValidator.validateCountry(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, false)

        addressDetails.country = "12"
        result = BSValidator.validateCountry(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, false)

        addressDetails.country = "12 Cdf"
        result = BSValidator.validateCountry(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, false)
        
        addressDetails.country = "us"
        result = BSValidator.validateCountry(ignoreIfEmpty: true, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, true)
        
        addressDetails.country = "US"
        result = BSValidator.validateCountry(ignoreIfEmpty: true, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, true)
    }

    func testValidateZip() {

        let input = BSBaseTextInput()
        let addressDetails = BSBaseAddressDetails()

        XCTAssertEqual(BSValidator.validateZip(ignoreIfEmpty: true, input: input, addressDetails: addressDetails), true)

        XCTAssertEqual(BSValidator.validateZip(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "")
        XCTAssertEqual(addressDetails.zip, "")

        input.setValue("12")
        XCTAssertEqual(BSValidator.validateZip(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), false)
        XCTAssertEqual(input.getValue(), "12")
        XCTAssertEqual(addressDetails.zip, "12")

        input.setValue("12 Cdf")
        XCTAssertEqual(BSValidator.validateZip(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), true)
        XCTAssertEqual(input.getValue(), "12 Cdf")
        XCTAssertEqual(addressDetails.zip, "12 Cdf")

        input.setValue("  12 Cdf  ")
        XCTAssertEqual(BSValidator.validateZip(ignoreIfEmpty: false, input: input, addressDetails: addressDetails), true)
        XCTAssertEqual(input.getValue(), "12 Cdf")
        XCTAssertEqual(addressDetails.zip, "12 Cdf")
    }

    func testValidateState() {

        let input = BSBaseTextInput()
        let addressDetails = BSBaseAddressDetails()
        var result: Bool

        addressDetails.state = nil
        result = BSValidator.validateState(ignoreIfEmpty: true, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, true)

        addressDetails.state = ""
        result = BSValidator.validateState(ignoreIfEmpty: true, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, true)
        
        addressDetails.country = "US"
        addressDetails.state = nil
        result = BSValidator.validateState(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, false)
        
        addressDetails.country = "IL"
        addressDetails.state = nil
        result = BSValidator.validateState(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, true)
        
        addressDetails.country = "US"
        addressDetails.state = ""
        result = BSValidator.validateState(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, false)
        
        addressDetails.country = "IL"
        addressDetails.state = ""
        result = BSValidator.validateState(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, true)

        addressDetails.country = "US"
        addressDetails.state = "12"
        result = BSValidator.validateState(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, false)
        
        addressDetails.country = "IL"
        addressDetails.state = "12"
        result = BSValidator.validateState(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, false)
        
        addressDetails.country = "US"
        addressDetails.state = "12 Cdf"
        result = BSValidator.validateState(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, false)

        addressDetails.country = "US"
        addressDetails.state = "AL"
        result = BSValidator.validateState(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, true)
        
        addressDetails.country = "AR"
        addressDetails.state = ""
        result = BSValidator.validateState(ignoreIfEmpty: false, input: input, addressDetails: addressDetails)
        XCTAssertEqual(result, true)
    }

    func testValidateExp() {

        let input = BSCcInputLine()
        XCTAssertEqual(BSValidator.validateExp(input: input), false, "1 validateExp")
        XCTAssertEqual(input.expErrorLabel?.isHidden, false, "1 isHidden")
        XCTAssertEqual(input.expErrorLabel?.text, BSValidator.expInvalidMessage, "1 message")

        input.expTextField.text = "12"
        XCTAssertEqual(BSValidator.validateExp(input: input), false, "2 validateExp")
        XCTAssertEqual(input.expErrorLabel?.isHidden, false, "2 isHidden")
        XCTAssertEqual(input.expErrorLabel?.text, BSValidator.expInvalidMessage, "2 message")

        input.expTextField.text = "1220"
        XCTAssertEqual(BSValidator.validateExp(input: input), false, "3 validateExp")
        XCTAssertEqual(input.expErrorLabel?.isHidden, false, "3 isHidden")
        XCTAssertEqual(input.expErrorLabel?.text, BSValidator.expInvalidMessage, "3 message")

        input.expTextField.text = "12/26"
        XCTAssertEqual(BSValidator.validateExp(input: input), true, "4 validateExp")
        XCTAssertEqual(input.expErrorLabel?.isHidden, true, "4 isHidden")

        input.expTextField.text = "14/26"
        XCTAssertEqual(BSValidator.validateExp(input: input), false, "5 validateExp")
        XCTAssertEqual(input.expErrorLabel?.isHidden, false, "5 isHidden")
        XCTAssertEqual(input.expErrorLabel?.text, BSValidator.expMonthInvalidMessage, "5 message")

        input.expTextField.text = "11/11"
        XCTAssertEqual(BSValidator.validateExp(input: input), false, "6 validateExp")
        XCTAssertEqual(input.expErrorLabel?.isHidden, false, "6 isHidden")
        XCTAssertEqual(input.expErrorLabel?.text, BSValidator.expPastInvalidMessage, "6 message")

        input.expTextField.text = "12/80"
        XCTAssertEqual(BSValidator.validateExp(input: input), false, "7 validateExp")
        XCTAssertEqual(input.expErrorLabel?.isHidden, false, "7 isHidden")
        XCTAssertEqual(input.expErrorLabel?.text, BSValidator.expInvalidMessage, "7 message")
    }

    func testValidateCvv() {

        let input = BSCcInputLine()
        XCTAssertEqual(BSValidator.validateCvv(input: input, cardType: "visa"), false)
        XCTAssertEqual(input.cvvErrorLabel?.isHidden, false)
        XCTAssertEqual(input.cvvErrorLabel?.text, BSValidator.cvvInvalidMessage)

        input.cvvTextField.text = "14"
        XCTAssertEqual(BSValidator.validateCvv(input: input, cardType: "visa"), false)
        XCTAssertEqual(input.cvvErrorLabel?.isHidden, false)
        XCTAssertEqual(input.cvvErrorLabel?.text, BSValidator.cvvInvalidMessage)

        input.cvvTextField.text = "143"
        XCTAssertEqual(BSValidator.validateCvv(input: input, cardType: "visa"), true)
        XCTAssertEqual(input.cvvErrorLabel?.isHidden, true)

        input.cvvTextField.text = "143"
        XCTAssertEqual(BSValidator.validateCvv(input: input, cardType: "VISA"), true)
        XCTAssertEqual(input.cvvErrorLabel?.isHidden, true)

        input.cvvTextField.text = "143"
        XCTAssertEqual(BSValidator.validateCvv(input: input, cardType: "amex"), false)
        XCTAssertEqual(input.cvvErrorLabel?.isHidden, false)
        XCTAssertEqual(input.cvvErrorLabel?.text, BSValidator.cvvInvalidMessage)

        input.cvvTextField.text = "143"
        XCTAssertEqual(BSValidator.validateCvv(input: input, cardType: "AMEX"), false)
        XCTAssertEqual(input.cvvErrorLabel?.isHidden, false)
        XCTAssertEqual(input.cvvErrorLabel?.text, BSValidator.cvvInvalidMessage)

        input.cvvTextField.text = "1434"
        XCTAssertEqual(BSValidator.validateCvv(input: input, cardType: "amex"), true)
        XCTAssertEqual(input.cvvErrorLabel?.isHidden, true)

        input.cvvTextField.text = "1434"
        XCTAssertEqual(BSValidator.validateCvv(input: input, cardType: "AMEX"), true)
        XCTAssertEqual(input.cvvErrorLabel?.isHidden, true)
    }

    func testvalidateCCN() {

        let input = BSCcInputLine()
        XCTAssertEqual(BSValidator.validateCCN(input: input), false)
        XCTAssertEqual(input.errorLabel?.isHidden, false)
        XCTAssertEqual(input.errorLabel?.text, BSValidator.ccnInvalidMessage)

        input.setValue("4111 1111 1111 1111")
        XCTAssertEqual(BSValidator.validateCCN(input: input), true)
        XCTAssertEqual(input.errorLabel?.isHidden, true)

        input.setValue("4111 1111 1111")
        XCTAssertEqual(BSValidator.validateCCN(input: input), false)
        XCTAssertEqual(input.errorLabel?.isHidden, false)
        XCTAssertEqual(input.errorLabel?.text, BSValidator.ccnInvalidMessage)
    }


//    func testPhoneEditingChanged() {
//
//        let input = BSInputLine()
//        BSValidator.phoneEditingChanged(input)
//        XCTAssertEqual(input.getValue(), "")
//
//        input.setValue("1")
//        BSValidator.phoneEditingChanged(input)
//        XCTAssertEqual(input.getValue(), "1")
//
//        input.setValue("123456789 123456789 123456789 555")
//        BSValidator.phoneEditingChanged(input)
//        XCTAssertEqual(input.getValue(), "123456789 123456789 123456789 ")
//    }

    func testEmailEditingChanged() {

        let input = BSBaseTextInput()
        BSValidator.emailEditingChanged(input)
        XCTAssertEqual(input.getValue(), "")

        input.setValue("a")
        BSValidator.emailEditingChanged(input)
        XCTAssertEqual(input.getValue(), "a")

        input.setValue("ab-7/")
        BSValidator.emailEditingChanged(input)
        XCTAssertEqual(input.getValue(), "ab-7")

        input.setValue("ab c")
        BSValidator.emailEditingChanged(input)
        XCTAssertEqual(input.getValue(), "abc")

        input.setValue("aaaa-aaaa-bbbb-bbbb-cccc-cccc-dddd-dddd-eeee-eeee-ffff-ffff-aaaa-aaaa-bbbb-bbbb-cccc-cccc-dddd-dddd-eeee-eeee-ffff-ffff-yyy")
        BSValidator.emailEditingChanged(input)
        XCTAssertEqual(input.getValue(), "aaaa-aaaa-bbbb-bbbb-cccc-cccc-dddd-dddd-eeee-eeee-ffff-ffff-aaaa-aaaa-bbbb-bbbb-cccc-cccc-dddd-dddd-eeee-eeee-ffff-ffff-")
    }

    func testAddressEditingChanged() {

        let input = BSBaseTextInput()
        BSValidator.addressEditingChanged(input)
        XCTAssertEqual(input.getValue(), "")

        input.setValue("a")
        BSValidator.addressEditingChanged(input)
        XCTAssertEqual(input.getValue(), "a")

        input.setValue("ab 90210")
        BSValidator.addressEditingChanged(input)
        XCTAssertEqual(input.getValue(), "ab 90210")

    }

    func testCityEditingChanged() {

        let input = BSBaseTextInput()
        BSValidator.cityEditingChanged(input)
        XCTAssertEqual(input.getValue(), "")

        input.setValue("a")
        BSValidator.cityEditingChanged(input)
        XCTAssertEqual(input.getValue(), "a")

    }

    func testZipEditingChanged() {

        let input = BSBaseTextInput()
        BSValidator.zipEditingChanged(input)
        XCTAssertEqual(input.getValue(), "")

        input.setValue("a")
        BSValidator.zipEditingChanged(input)
        XCTAssertEqual(input.getValue(), "a")

        input.setValue("ab 90210/")
        BSValidator.zipEditingChanged(input)
        XCTAssertEqual(input.getValue(), "ab 90210/")

        input.setValue("aaaa aaaa bbbb bbbb yyy")
        BSValidator.zipEditingChanged(input)
        XCTAssertEqual(input.getValue(), "aaaa aaaa bbbb bbbb ")
    }

    func testCcnEditingChanged() {

        let input = BSCcInputLine()
        BSValidator.ccnEditingChanged(input.textField)
        XCTAssertEqual(input.getValue(), "")

        input.setValue("4111")
        BSValidator.ccnEditingChanged(input.textField)
        XCTAssertEqual(input.getValue(), "4111")

        input.setValue("4111 abcd")
        BSValidator.ccnEditingChanged(input.textField)
        XCTAssertEqual(input.getValue(), "4111")

        input.setValue("41112222")
        BSValidator.ccnEditingChanged(input.textField)
        XCTAssertEqual(input.getValue(), "4111 2222")

        input.setValue("4111   555")
        BSValidator.ccnEditingChanged(input.textField)
        XCTAssertEqual(input.getValue(), "4111 555")

        input.setValue("4111   55556666.777")
        BSValidator.ccnEditingChanged(input.textField)
        XCTAssertEqual(input.getValue(), "4111 5555 6666 777")

        input.setValue("1111 2222 3333 4444 5555 6666")
        BSValidator.ccnEditingChanged(input.textField)
        XCTAssertEqual(input.getValue(), "1111 2222 3333 444455556")
    }

}
