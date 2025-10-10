//
//  BSStringUtilssTests.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 20/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BSStringUtilsTests: XCTestCase {


    override func setUp() {
        print("----------------------------------------------------")
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testRemoveWhitespaces() {

        XCTAssertEqual(BSStringUtils.removeWhitespaces("aabbcc"), "aabbcc")
        XCTAssertEqual(BSStringUtils.removeWhitespaces(" aabbcc "), "aabbcc")
        XCTAssertEqual(BSStringUtils.removeWhitespaces(" aa bb cc "), "aabbcc")
        XCTAssertEqual(BSStringUtils.removeWhitespaces("aab\tbcc"), "aabbcc")
    }

    func testSplitName() {

        let name1 = BSStringUtils.splitName("")
        XCTAssertEqual(name1?.firstName, "")
        XCTAssertEqual(name1?.lastName, "")

        let name2 = BSStringUtils.splitName("aaa")
        XCTAssertEqual(name2?.firstName, "aaa")
        XCTAssertEqual(name2?.lastName, "")

        let name3 = BSStringUtils.splitName("aa bb")
        XCTAssertEqual(name3?.firstName, "aa")
        XCTAssertEqual(name3?.lastName, "bb")

        let name4 = BSStringUtils.splitName("aa vv bb")
        XCTAssertEqual(name4?.firstName, "aa")
        XCTAssertEqual(name4?.lastName, "vv bb")
    }

    func testLast4() {

        XCTAssertEqual(BSStringUtils.last4("4111 2222 3333 5555"), "5555")
        XCTAssertEqual(BSStringUtils.last4("4111 2222 3333"), "3333")
        XCTAssertEqual(BSStringUtils.last4("4111 2222"), "2222")
        XCTAssertEqual(BSStringUtils.last4("4111"), "4111")
        XCTAssertEqual(BSStringUtils.last4("41"), "")
        XCTAssertEqual(BSStringUtils.last4(""), "")
    }

    func testRemoveNoneAlphaCharacters() {

        XCTAssertEqual(BSStringUtils.removeNoneAlphaCharacters("aAbB!@#$%^&*()-=_+[]{}"), "aAbB")
        XCTAssertEqual(BSStringUtils.removeNoneAlphaCharacters("0123456789Ll"), "Ll")
        XCTAssertEqual(BSStringUtils.removeNoneAlphaCharacters("'\"|\\?/><,`~Rr."), "Rr")
        XCTAssertEqual(BSStringUtils.removeNoneAlphaCharacters("x X"), "x X")
        XCTAssertEqual(BSStringUtils.removeNoneAlphaCharacters(""), "")
    }

    func testRemoveNoneEmailCharacters() {

        XCTAssertEqual(BSStringUtils.removeNoneEmailCharacters("aAbB!@#$%^&*()-=_+[]{}"), "aAbB@-_")
        XCTAssertEqual(BSStringUtils.removeNoneEmailCharacters("0123456789Ll"), "0123456789Ll")
        XCTAssertEqual(BSStringUtils.removeNoneEmailCharacters("'\"|\\?/><,`~Rr."), "Rr.")
        XCTAssertEqual(BSStringUtils.removeNoneEmailCharacters("x X"), "xX")
        XCTAssertEqual(BSStringUtils.removeNoneEmailCharacters(""), "")
    }

    func testRemoveNoneDigits() {

        XCTAssertEqual(BSStringUtils.removeNoneDigits("aAbB!@#$%^&*()-=_+[]{}"), "")
        XCTAssertEqual(BSStringUtils.removeNoneDigits("0123456789Ll"), "0123456789")
        XCTAssertEqual(BSStringUtils.removeNoneDigits("'\"|\\?/><,`~Rr."), "")
        XCTAssertEqual(BSStringUtils.removeNoneDigits("x X"), "")
        XCTAssertEqual(BSStringUtils.removeNoneDigits(""), "")
    }

    func testCutToMaxLength() {

        XCTAssertEqual(BSStringUtils.cutToMaxLength("", maxLength: 3), "")
        XCTAssertEqual(BSStringUtils.cutToMaxLength("ab", maxLength: 3), "ab")
        XCTAssertEqual(BSStringUtils.cutToMaxLength("abc", maxLength: 3), "abc")
        XCTAssertEqual(BSStringUtils.cutToMaxLength("abcd", maxLength: 3), "abc")
        XCTAssertEqual(BSStringUtils.cutToMaxLength("abcddgafgadfg", maxLength: 3), "abc")
    }

    func testStartsWith() {

        XCTAssertEqual(BSStringUtils.startsWith(theString: "", subString: ""), false)
        XCTAssertEqual(BSStringUtils.startsWith(theString: "Abc", subString: "Abc"), true)
        XCTAssertEqual(BSStringUtils.startsWith(theString: "Abc", subString: "Ab"), true)
        XCTAssertEqual(BSStringUtils.startsWith(theString: "Abc", subString: "A"), true)
        XCTAssertEqual(BSStringUtils.startsWith(theString: "Abc", subString: " A"), false)
        XCTAssertEqual(BSStringUtils.startsWith(theString: "Abc", subString: "bc"), false)
        XCTAssertEqual(BSStringUtils.startsWith(theString: "", subString: "sdfa"), false)
    }
}
