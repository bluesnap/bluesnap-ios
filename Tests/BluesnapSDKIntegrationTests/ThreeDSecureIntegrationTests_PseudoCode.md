# 3D Secure Integration Tests — Pseudo Code

Extracted from Android: `ThreeDSecureIntegrationTest.java`
These tests verify 3DS model serialization/deserialization without UI.

---

## Test Class: ThreeDSecureIntegrationTests
Inherits from the integration test base class.

---

### Test 1: testBS3DSAuthRequestToJson
**Purpose:** Verify that a 3DS auth request serializes correctly to JSON.

```
GIVEN:
    currency = "USD"
    amount = 100.50
    jwt = "test-jwt-token-12345"

WHEN:
    request = BS3DSAuthRequest(currency, amount, jwt)
    json = request.toJson()

THEN:
    ASSERT json is not nil
    ASSERT json["currency"] == "USD"
    ASSERT json["amount"] == "100.5"  (string representation)
    ASSERT json["jwt"] == "test-jwt-token-12345"
```

---

### Test 2: testBS3DSAuthResponseFromJson
**Purpose:** Verify that a 3DS auth response deserializes all fields from JSON.

```
GIVEN:
    json = {
        "enrollmentStatus": "CHALLENGE_REQUIRED",
        "acsUrl": "https://acs.cardinalcommerce.com/challenge",
        "payload": "encoded-challenge-payload",
        "transactionId": "txn-abc-123",
        "threeDSVersion": "2.1.0"
    }

WHEN:
    response = BS3DSAuthResponse.fromJson(json)

THEN:
    ASSERT response is not nil
    ASSERT response.enrollmentStatus == "CHALLENGE_REQUIRED"
    ASSERT response.acsUrl == "https://acs.cardinalcommerce.com/challenge"
    ASSERT response.payload == "encoded-challenge-payload"
    ASSERT response.transactionId == "txn-abc-123"
    ASSERT response.threeDSVersion == "2.1.0"
```

---

### Test 3: testBS3DSAuthResponseFromNullJson
**Purpose:** Verify graceful handling when nil/null JSON is passed.

```
GIVEN:
    json = nil

WHEN:
    response = BS3DSAuthResponse.fromJson(json)

THEN:
    ASSERT response is nil
```

---

### Test 4: testBS3DSAuthResponseWithMissingFields
**Purpose:** Verify that missing fields default to empty string (or nil), not crash.

```
GIVEN:
    json = {
        "enrollmentStatus": "AUTHENTICATION_SUCCEEDED"
    }
    // acsUrl, payload, transactionId, threeDSVersion are all missing

WHEN:
    response = BS3DSAuthResponse.fromJson(json)

THEN:
    ASSERT response is not nil
    ASSERT response.enrollmentStatus == "AUTHENTICATION_SUCCEEDED"
    ASSERT response.acsUrl == "" (or nil, depending on iOS parser behavior)
    ASSERT response.payload == "" (or nil)
    ASSERT response.transactionId == "" (or nil)
    ASSERT response.threeDSVersion == "" (or nil)
```
