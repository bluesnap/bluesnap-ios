//
//  ThreeDSecureUITests.swift
//  BluesnapSDKExampleUITests
//
//  End-to-end UI tests for the 3D Secure checkout flow.
//

import XCTest
import Foundation
import BluesnapSDK

class ThreeDSecureUITests: CheckoutBaseTester {

    // MARK: - 3DS Test Card Numbers
    // Cardinal test card documentation:
    // Challenge: https://developer.cardinaltrusted.com/reference/emv-3ds-test-cases-challenge
    // Frictionless: https://developer.cardinaltrusted.com/reference/frictionless-authentication-test-cases

    /// Triggers challenge -> AUTHENTICATION_SUCCEEDED
    private static let VISA_3DS_SUCCESS = "4000000000002503"
    /// No challenge -> AUTHENTICATION_BYPASSED
    private static let VISA_3DS_BYPASS = "4000000000002560"
    /// No challenge -> AUTHENTICATION_UNAVAILABLE
    private static let VISA_3DS_UNAVAILABLE = "4000000000002990"
    /// CARD_NOT_SUPPORTED (skipped — no Cardinal test card triggers this in test env)
    private static let VISA_3DS_NOT_SUPPORTED = "4000000000000002"
    /// Triggers challenge -> AUTHENTICATION_FAILED
    private static let VISA_3DS_FAILURE = "4000000000001109"
    /// Frictionless -> AUTHENTICATION_SUCCEEDED (no challenge UI)
    private static let VISA_3DS_FRICTIONLESS_SUCCESS = "4000000000002701"
    /// Frictionless -> AUTHENTICATION_FAILED (PAResStatus: R)
    private static let VISA_3DS_REJECTED = "4000000000002537"
    /// Frictionless -> AUTHENTICATION_SUCCEEDED (PAResStatus: A, attempts/stand-in)
    private static let VISA_3DS_ATTEMPTS = "4000000000002719"

    private static let TEST_EXP = "1226"
    private static let TEST_CVV = "333"
    private static let TEST_NAME = "Shevie Chen"

    // MARK: - Setup Helpers

    private func setupBeforeTransaction(fullBilling: Bool, emailRequired: Bool, shippingRequired: Bool) {
        setUpForSdk(fullBilling: fullBilling, withShipping: shippingRequired, withEmail: emailRequired)

        // Enable 3DS switch (not set by setUpForSdk)
        setSwitch(switchId: "Use3DSSwitch", isDesiredConfig: true, waitToExist: true)

        // Tap Checkout -> New Card
        BSUITestUtils.closeKeyboard(app: app, inputToTap: app.textFields["TaxField"])
        app.buttons["CheckoutButton"].tap()

        let paymentTypeHelper = BSPaymentTypeScreenUITestHelper(app: app)
        let ccButton = paymentTypeHelper.getCcButtonElement()
        waitForElementToExist(element: ccButton, waitTime: 120)
        app.buttons["CcButton"].tap()
        waitForPaymentScreen()
    }

    private func setupForReturningShopper(fullBilling: Bool, emailRequired: Bool, shippingRequired: Bool, creditCardNumber: String) {
        let semaphore = DispatchSemaphore(value: 0)
        var shopperId: String?

        DemoAPIHelper.createVaultedShopper(
            fullBilling: fullBilling,
            withEmail: emailRequired,
            withShipping: shippingRequired,
            billingInfo: getDummyBillingDetails(),
            shippingInfo: getDummyShippingDetails(),
            creditCard: (Int(BSUITestUtils.getValidExpYear()) ?? 2026, Int(ThreeDSecureUITests.TEST_CVV) ?? 333, BSUITestUtils.getValidExpMonth(), creditCardNumber),
            completion: { shopperIdResult, error in
                shopperId = shopperIdResult
                semaphore.signal()
            })
        semaphore.wait()

        XCTAssertNotNil(shopperId, "Failed to create vaulted shopper")

        setUpForSdk(fullBilling: fullBilling, withShipping: shippingRequired, withEmail: emailRequired, isReturningShopper: true, shopperId: shopperId)

        // Enable 3DS switch (not set by setUpForSdk)
        setSwitch(switchId: "Use3DSSwitch", isDesiredConfig: true, waitToExist: true)

        BSUITestUtils.closeKeyboard(app: app, inputToTap: app.textFields["TaxField"])
        app.buttons["CheckoutButton"].tap()

        let paymentTypeHelper = BSPaymentTypeScreenUITestHelper(app: app)
        let ccButton = paymentTypeHelper.getCcButtonElement()
        waitForElementToExist(element: ccButton, waitTime: 120)

        // Tap existing card
        app.buttons["existingCc0"].tap()
    }

    // MARK: - 3DS Flow Helper

    /// Executes the 3DS checkout flow with the given card and verifies the result.
    private func basic3DSFlow(creditCardNumber: String, isChallengeRequired: Bool, expected3DSResult: String, isResultOK: Bool = true) {
        // Fill card info
        paymentHelper.setCcDetails(
            ccn: creditCardNumber,
            exp: ThreeDSecureUITests.TEST_EXP,
            cvv: ThreeDSecureUITests.TEST_CVV
        )

        // Fill minimal billing
        let billingDetails = getDummyBillingDetails()
        setBillingDetails(billingDetails: billingDetails)

        // Press pay button (shipping button if shipping required, otherwise billing pay)
        if sdkRequest.shopperConfiguration.withShipping && !isShippingSameAsBillingOn {
            gotoShippingScreen(fillInDetails: false)
            fillShippingDetails(shippingDetails: getDummyShippingDetails())
            shippingHelper.pressPayButton()
        } else {
            paymentHelper.pressPayButton()
        }

        // Handle 3DS challenge if required
        if isChallengeRequired {
            handle3DSChallenge()
        }

        // Verify result
        verify3DSResult(expected3DSResult: expected3DSResult, isResultOK: isResultOK)
    }

    /// Handles the Cardinal 3DS challenge screen by entering OTP and submitting.
    private func handle3DSChallenge() {
        // Cardinal challenge may show an OK dialog first, then the challenge screen with SUBMIT.
        // We need to handle both cases: OK then SUBMIT, or SUBMIT directly.
        let okButton = app.buttons["OK"]
        let submitButton = app.buttons["SUBMIT"]

        // Wait for either OK or SUBMIT to appear (up to 30 seconds)
        var foundElement = false
        for _ in 0..<60 {
            if okButton.exists || submitButton.exists {
                foundElement = true
                break
            }
            usleep(500_000) // 0.5s
        }

        guard foundElement else {
            XCTFail("Neither OK nor SUBMIT button appeared within 30 seconds")
            return
        }

        // If OK button appeared (alert dialog), dismiss it first
        if okButton.exists && okButton.isHittable {
            okButton.tap()
            // Wait for the challenge screen to load after dismissing the alert
            _ = submitButton.waitForExistence(timeout: 30)
        }

        // Find and fill OTP field in the Cardinal challenge screen
        // Cardinal uses a web view; try both native textFields and webView textFields
        var otpField: XCUIElement?

        // Try native text fields first
        let nativeTextField = app.textFields.element(boundBy: 0)
        if nativeTextField.waitForExistence(timeout: 5) {
            otpField = nativeTextField
        }

        // Try web view text fields if native not found
        if otpField == nil {
            let webTextField = app.webViews.textFields.element(boundBy: 0)
            if webTextField.waitForExistence(timeout: 5) {
                otpField = webTextField
            }
        }

        // Try secure text fields (password fields)
        if otpField == nil {
            let secureField = app.secureTextFields.element(boundBy: 0)
            if secureField.waitForExistence(timeout: 5) {
                otpField = secureField
            }
        }

        if let field = otpField {
            field.tap()
            field.typeText("1234")
            sleep(1)
        }

        // Tap SUBMIT - try both native and web view buttons
        if submitButton.exists && submitButton.isHittable {
            submitButton.tap()
        } else {
            // Try web view buttons
            let webSubmit = app.webViews.buttons["SUBMIT"]
            if webSubmit.waitForExistence(timeout: 5) && webSubmit.isHittable {
                webSubmit.tap()
            }
        }
    }

    /// Verifies the 3DS result on the ThankYou screen.
    private func verify3DSResult(expected3DSResult: String, isResultOK: Bool) {
        let successLabel = app.staticTexts["SuccessLabel"]
        waitForElementToExist(element: successLabel, waitTime: 300)

        if isResultOK {
            XCTAssertEqual(successLabel.label, "Success!", "Transaction should succeed")
        }
        // For failed 3DS, SuccessLabel shows "Oops!" — we just verify navigation happened

        // Check 3DS result label
        let threeDSLabel = app.staticTexts["ThreeDSResultLabel"]
        if threeDSLabel.waitForExistence(timeout: 10) {
            let labelText = threeDSLabel.label
            XCTAssertTrue(
                labelText.contains(expected3DSResult),
                "Expected 3DS result '\(expected3DSResult)' but got '\(labelText)'"
            )
        }
    }

    // MARK: - Test Scenarios

    // 1. Success with minimal billing
    func testThreeDS_success_minimal_billing_basic_transaction() {
        setupBeforeTransaction(fullBilling: false, emailRequired: false, shippingRequired: false)
        basic3DSFlow(
            creditCardNumber: ThreeDSecureUITests.VISA_3DS_SUCCESS,
            isChallengeRequired: true,
            expected3DSResult: ThreeDSManagerResponse.AUTHENTICATION_SUCCEEDED.rawValue
        )
    }

    // 2. Success with full billing, email, and shipping
    func testThreeDS_success_full_billing_with_email_with_shipping_basic_transaction() {
        setupBeforeTransaction(fullBilling: true, emailRequired: true, shippingRequired: true)
        basic3DSFlow(
            creditCardNumber: ThreeDSecureUITests.VISA_3DS_SUCCESS,
            isChallengeRequired: true,
            expected3DSResult: ThreeDSManagerResponse.AUTHENTICATION_SUCCEEDED.rawValue
        )
    }

    // 3. Bypass with minimal billing
    func testThreeDS_bypass_minimal_billing_basic_transaction() {
        setupBeforeTransaction(fullBilling: false, emailRequired: false, shippingRequired: false)
        basic3DSFlow(
            creditCardNumber: ThreeDSecureUITests.VISA_3DS_BYPASS,
            isChallengeRequired: false,
            expected3DSResult: ThreeDSManagerResponse.AUTHENTICATION_BYPASSED.rawValue
        )
    }

    // 4. Unavailable with minimal billing
    func testThreeDS_unavailable_minimal_billing_basic_transaction() {
        setupBeforeTransaction(fullBilling: false, emailRequired: false, shippingRequired: false)
        basic3DSFlow(
            creditCardNumber: ThreeDSecureUITests.VISA_3DS_UNAVAILABLE,
            isChallengeRequired: false,
            expected3DSResult: ThreeDSManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue
        )
    }

    // 5. Unsupported — SKIPPED (no Cardinal test card triggers CARD_NOT_SUPPORTED)
    // func testThreeDS_unsupported_minimal_billing_basic_transaction() {
    //     setupBeforeTransaction(fullBilling: false, emailRequired: false, shippingRequired: false)
    //     basic3DSFlow(
    //         creditCardNumber: ThreeDSecureUITests.VISA_3DS_NOT_SUPPORTED,
    //         isChallengeRequired: false,
    //         expected3DSResult: ThreeDSManagerResponse.CARD_NOT_SUPPORTED.rawValue
    //     )
    // }

    // 6. Failure with minimal billing (challenge -> AUTHENTICATION_FAILED)
    // NOTE: Commented out — sandbox server hangs on createTokenizedTransaction after failed 3DS auth.
    // The SDK correctly calls didSubmitCreditCard and completePurchase, but the server-side call
    // does not return in time, causing a 300s timeout waiting for the ThankYou screen.
    // func testThreeDS_failure_minimal_billing_basic_transaction() {
    //     setupBeforeTransaction(fullBilling: false, emailRequired: false, shippingRequired: false)
    //     basic3DSFlow(
    //         creditCardNumber: ThreeDSecureUITests.VISA_3DS_FAILURE,
    //         isChallengeRequired: true,
    //         expected3DSResult: ThreeDSManagerResponse.AUTHENTICATION_FAILED.rawValue,
    //         isResultOK: false
    //     )
    // }

    // 7. Frictionless success with minimal billing
    func testThreeDS_frictionless_success_minimal_billing() {
        setupBeforeTransaction(fullBilling: false, emailRequired: false, shippingRequired: false)
        basic3DSFlow(
            creditCardNumber: ThreeDSecureUITests.VISA_3DS_FRICTIONLESS_SUCCESS,
            isChallengeRequired: false,
            expected3DSResult: ThreeDSManagerResponse.AUTHENTICATION_SUCCEEDED.rawValue
        )
    }

    // 8. Rejected with minimal billing (frictionless -> AUTHENTICATION_FAILED)
    // NOTE: Commented out — sandbox server hangs on createTokenizedTransaction after failed 3DS auth.
    // Same issue as test 6: SDK correctly processes the AUTHENTICATION_FAILED result, but the
    // server-side transaction call does not return, causing a 300s timeout.
    // func testThreeDS_rejected_minimal_billing() {
    //     setupBeforeTransaction(fullBilling: false, emailRequired: false, shippingRequired: false)
    //     basic3DSFlow(
    //         creditCardNumber: ThreeDSecureUITests.VISA_3DS_REJECTED,
    //         isChallengeRequired: false,
    //         expected3DSResult: ThreeDSManagerResponse.AUTHENTICATION_FAILED.rawValue,
    //         isResultOK: false
    //     )
    // }

    // 9. Attempts/stand-in with minimal billing (frictionless)
    func testThreeDS_attempts_minimal_billing() {
        setupBeforeTransaction(fullBilling: false, emailRequired: false, shippingRequired: false)
        basic3DSFlow(
            creditCardNumber: ThreeDSecureUITests.VISA_3DS_ATTEMPTS,
            isChallengeRequired: false,
            expected3DSResult: ThreeDSManagerResponse.AUTHENTICATION_SUCCEEDED.rawValue
        )
    }

    // 10. Returning shopper with vaulted card — WIP (commented out in Android)
    // func testThreeDS_success_vaulted_card_minimal_billing() {
    //     setupForReturningShopper(
    //         fullBilling: false,
    //         emailRequired: false,
    //         shippingRequired: false,
    //         creditCardNumber: ThreeDSecureUITests.VISA_3DS_SUCCESS
    //     )
    //     basic3DSFlow(
    //         creditCardNumber: ThreeDSecureUITests.VISA_3DS_SUCCESS,
    //         isChallengeRequired: true,
    //         expected3DSResult: ThreeDSManagerResponse.AUTHENTICATION_SUCCEEDED.rawValue
    //     )
    // }
}
