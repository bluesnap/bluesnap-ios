# 3D Secure UI Tests — Pseudo Code

Extracted from Android: `ThreeDSecureUITests.java`
These are end-to-end UI tests that exercise the full 3DS checkout flow.

---

## Test Class: ThreeDSecureUITests
Inherits from the checkout UI test base (e.g., CheckoutBaseTester).

### Properties
- device: XCUIApplication reference
- shopperCheckoutRequirements: test configuration for billing/email/shipping

---

## Helper: setupBeforeTransaction(fullBilling, emailRequired, shippingRequired)
```
SET shopperCheckoutRequirements with (fullBilling, emailRequired, shippingRequired)
CALL checkoutSetup(threeDSEnabled: true)
TAP "New Card" button to start new card entry
```

## Helper: setupForReturningShopper(fullBilling, emailRequired, shippingRequired, creditCard)
```
CREATE vaulted shopper via test API using creditCard
SET shopperCheckoutRequirements with (fullBilling, emailRequired, shippingRequired)
CALL returningShopperSetUp(shopperCheckoutRequirements, threeDSEnabled: true)
TAP first card in the existing cards list
```

## Helper: basic3DSFlow(creditCard, isChallengeRequired, expected3DSResult, isResultOK = true)
```
FILL card info fields using creditCard test data (number, exp, CVV, name)

TAP "Buy Now" button
    — use shipping button if shipping required, otherwise billing button

IF isChallengeRequired:
    WAIT up to 30 seconds for either:
        - "OK" dialog button, OR
        - "SUBMIT" button (Cardinal challenge screen)

    IF "OK" button appeared first:
        TAP "OK" button
        WAIT for "SUBMIT" button to appear

    FIND OTP input field (Cardinal's code entry field)
    TAP OTP field to focus
    TYPE "1234" into OTP field
    WAIT 1 second
    TAP "SUBMIT" button

VERIFY purchase result:
    ASSERT 3DS result matches expected3DSResult
    ASSERT transaction outcome matches isResultOK
```

---

## Test Scenarios

### 1. threeDS_success_minimal_billing_basic_transaction
```
SETUP: setupBeforeTransaction(fullBilling: false, email: false, shipping: false)
RUN:   basic3DSFlow(
           card: VISA_3DS_SUCCESS,
           challengeRequired: true,
           expected: AUTHENTICATION_SUCCEEDED)
```

### 2. threeDS_success_full_billing_with_email_with_shipping_basic_transaction
```
SETUP: setupBeforeTransaction(fullBilling: true, email: true, shipping: true)
RUN:   basic3DSFlow(
           card: VISA_3DS_SUCCESS,
           challengeRequired: true,
           expected: AUTHENTICATION_SUCCEEDED)
```

### 3. threeDS_bypass_minimal_billing_basic_transaction
```
SETUP: setupBeforeTransaction(fullBilling: false, email: false, shipping: false)
RUN:   basic3DSFlow(
           card: VISA_3DS_BYPASS,
           challengeRequired: false,
           expected: AUTHENTICATION_BYPASSED)
```

### 4. threeDS_unavailable_minimal_billing_basic_transaction
```
SETUP: setupBeforeTransaction(fullBilling: false, email: false, shipping: false)
RUN:   basic3DSFlow(
           card: VISA_3DS_UNAVAILABLE,
           challengeRequired: false,
           expected: AUTHENTICATION_UNAVAILABLE)
```

### 5. threeDS_unsupported_minimal_billing_basic_transaction [SKIPPED]
**Note:** No Cardinal test card triggers CARD_NOT_SUPPORTED — requires 3DS 1.x card which test env doesn't provide.
```
SETUP: setupBeforeTransaction(fullBilling: false, email: false, shipping: false)
RUN:   basic3DSFlow(
           card: VISA_3DS_NOT_SUPPORTED,
           challengeRequired: false,
           expected: CARD_NOT_SUPPORTED)
```

### 6. threeDS_failure_minimal_billing_basic_transaction
```
SETUP: setupBeforeTransaction(fullBilling: false, email: false, shipping: false)
RUN:   basic3DSFlow(
           card: VISA_3DS_FAILURE,
           challengeRequired: true,
           expected: AUTHENTICATION_FAILED,
           isResultOK: false)
```

### 7. threeDS_frictionless_success_minimal_billing
**Frictionless:** No challenge UI shown; Cardinal resolves success automatically.
```
SETUP: setupBeforeTransaction(fullBilling: false, email: false, shipping: false)
RUN:   basic3DSFlow(
           card: VISA_3DS_FRICTIONLESS_SUCCESS,
           challengeRequired: false,
           expected: AUTHENTICATION_SUCCEEDED)
```

### 8. threeDS_rejected_minimal_billing
**Rejected:** Issuer explicitly rejects authentication (PAResStatus: R). Frictionless flow.
```
SETUP: setupBeforeTransaction(fullBilling: false, email: false, shipping: false)
RUN:   basic3DSFlow(
           card: VISA_3DS_REJECTED,
           challengeRequired: false,
           expected: AUTHENTICATION_FAILED,
           isResultOK: false)
```

### 9. threeDS_attempts_minimal_billing
**Attempts/Stand-in:** Issuer didn't respond, attempt recorded (PAResStatus: A). Frictionless flow.
```
SETUP: setupBeforeTransaction(fullBilling: false, email: false, shipping: false)
RUN:   basic3DSFlow(
           card: VISA_3DS_ATTEMPTS,
           challengeRequired: false,
           expected: AUTHENTICATION_SUCCEEDED)
```

### 10. threeDS_success_vaulted_card_minimal_billing [WIP — commented out in Android]
```
SETUP: setupForReturningShopper(
           fullBilling: false, email: false, shipping: false,
           card: VISA_3DS_SUCCESS)
RUN:   basic3DSFlow(
           card: VISA_3DS_SUCCESS,
           challengeRequired: true,
           expected: AUTHENTICATION_SUCCEEDED)
```

---

## Test Card Reference (from Android)
| Alias | Description |
|-------|-------------|
| VISA_3DS_SUCCESS | Triggers challenge → success |
| VISA_3DS_BYPASS | Authentication bypassed |
| VISA_3DS_UNAVAILABLE | Authentication unavailable |
| VISA_3DS_NOT_SUPPORTED | Card not supported for 3DS |
| VISA_3DS_FAILURE | Triggers challenge → failure |
| VISA_3DS_FRICTIONLESS_SUCCESS | Frictionless success (card: 4000000000002701) |
| VISA_3DS_REJECTED | Issuer rejected (card: 4000000000002537) |
| VISA_3DS_ATTEMPTS | Attempts/stand-in (card: 4000000000002719) |

## ThreeDSManagerResponse Values
- AUTHENTICATION_SUCCEEDED
- AUTHENTICATION_BYPASSED
- AUTHENTICATION_UNAVAILABLE
- AUTHENTICATION_FAILED
- CARD_NOT_SUPPORTED
