//
//  ThreeDSecureIntegrationTests.swift
//  BluesnapSDKIntegrationTests
//
//  Tests for 3DS model serialization/deserialization without UI.
//

import XCTest

@testable import BluesnapSDK

class ThreeDSecureIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - BS3DSAuthRequest Tests

    func testBS3DSAuthRequestToJson() {
        let request = BS3DSAuthRequest(currencyCode: "USD", amount: "100.5", jwt: "test-jwt-token-12345")
        let json = request.toJson()

        XCTAssertNotNil(json, "JSON should not be nil")
        XCTAssertEqual(json!["currency"] as? String, "USD", "currency should be USD")
        XCTAssertEqual(json!["amount"] as? String, "100.5", "amount should be 100.5")
        XCTAssertEqual(json!["jwt"] as? String, "test-jwt-token-12345", "jwt should match")
    }

    // MARK: - BS3DSAuthResponse Tests

    func testBS3DSAuthResponseFromJson() {
        let jsonDict: [String: Any] = [
            "enrollmentStatus": "CHALLENGE_REQUIRED",
            "acsUrl": "https://acs.cardinalcommerce.com/challenge",
            "payload": "encoded-challenge-payload",
            "transactionId": "txn-abc-123",
            "threeDSVersion": "2.1.0"
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
            XCTFail("Failed to serialize test JSON")
            return
        }

        let (response, error) = BS3DSAuthResponse.parseJson(data: data)

        XCTAssertNil(error, "Error should be nil")
        XCTAssertNotNil(response, "Response should not be nil")
        XCTAssertEqual(response?.enrollmentStatus, "CHALLENGE_REQUIRED")
        XCTAssertEqual(response?.acsUrl, "https://acs.cardinalcommerce.com/challenge")
        XCTAssertEqual(response?.payload, "encoded-challenge-payload")
        XCTAssertEqual(response?.transactionId, "txn-abc-123")
        XCTAssertEqual(response?.threeDSVersion, "2.1.0")
    }

    func testBS3DSAuthResponseFromEmptyData() {
        // Pass empty Data() instead of nil, since parseJson force-unwraps data!
        let (response, error) = BS3DSAuthResponse.parseJson(data: Data())

        XCTAssertNil(response, "Response should be nil for empty data")
        XCTAssertNotNil(error, "Error should not be nil for empty data")
    }

    func testBS3DSAuthResponseWithMissingFields() {
        let jsonDict: [String: Any] = [
            "enrollmentStatus": "AUTHENTICATION_SUCCEEDED"
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
            XCTFail("Failed to serialize test JSON")
            return
        }

        let (response, error) = BS3DSAuthResponse.parseJson(data: data)

        XCTAssertNil(error, "Error should be nil")
        XCTAssertNotNil(response, "Response should not be nil")
        XCTAssertEqual(response?.enrollmentStatus, "AUTHENTICATION_SUCCEEDED")
        XCTAssertNil(response?.acsUrl, "acsUrl should be nil when missing")
        XCTAssertNil(response?.payload, "payload should be nil when missing")
        XCTAssertNil(response?.transactionId, "transactionId should be nil when missing")
        XCTAssertNil(response?.threeDSVersion, "threeDSVersion should be nil when missing")
    }
}
