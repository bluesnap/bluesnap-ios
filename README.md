# BlueSnap iOS SDK overview
BlueSnap's iOS SDK enables you to easily accept credit card payments directly from your iOS app and then process the payments via BlueSnap's Payment API. Additionally, if you use the Standard Checkout Flow (described below), you can process Apple Pay and PayPal payments as well.
When you use this library, BlueSnap handles most of the PCI compliance burden for you, as the user's payment data is tokenized and sent directly to BlueSnap.

This document will cover the following topics: 
* [Checkout flow options](#checkout-flow-options)
* [Installation](#installation)
* [Usage](#usage)
* [Implementing Standard Checkout Flow Using BlueSnap SDK UI](#implementing-standard-checkout-flow-using-bluesnap-sdk-ui)
* [Implementing Custom Checkout Flow](#implementing-custom-checkout-flow) 
* [Implementing Standard Checkout Flow Using Your Own UI](#implementing-standard-checkout-flow-using-your-own-ui)
* [3D Secure Authentication](#3d-secure-Authentication)
* [Sending the payment for processing](#sending-the-payment-for-processing)
* [Demo app - explained](#demo-app---explained)
* [Reference](#reference)

# Checkout flow options
The BlueSnap iOS SDK provides three elegant checkout flows to choose from. 
## Standard Checkout Flow Using BlueSnap SDK UI
This flow allows you to get up and running quickly with our pre-built checkout UI, enabling you to accept credit cards, Apple Pay, and PayPal payments in your app.
Some of the capabilities include:
* Specifying required user info, such as email or billing address.
* Pre-populating checkout page.
* Specifying a returning user so BlueSnap can pre-populate checkout screen with their payment and shipping/billing info.  
* Launching checkout UI with simple start function.
* Built-in 3D secure authentication.
* Reguler payments, shopper configuration and subscription charges.

To see an image of the Standard Checkout Flow, click [here](https://developers.bluesnap.com/v8976-Basics/docs/ios-sdk#standard-checkout-flow). 

### Subscription cancellation message (Subscriptions UI)
For subscription charges, the SDK displays an informational cancellation message above the "Securely store my card" switch to help you communicate your subscription cancellation policy.

Default behavior:
- When the flow is a subscription (i.e. you use `BSSdkRequestSubscriptionCharge`), the message is shown by default.
- The default text is: "You can cancel subscriptions at any time".

Customization:
- You can control the visibility and customize the text at runtime using the payment screen controller API.
- If you need to override the defaults, obtain a reference to the presented `BSPaymentViewController` after calling `showCheckoutScreen` and use the setters shown below.

Example (after presenting the checkout screen):
```swift
do {
    try BlueSnapSDK.showCheckoutScreen(
        inNavigationController: self.navigationController,
        animated: true,
        sdkRequest: sdkRequest
    )
    // If you want to customize the subscription cancellation message:
    if let paymentVC = self.navigationController?.topViewController as? BSPaymentViewController {
        // Hide or show the message (default is true for subscriptions)
        paymentVC.setShowSubscriptionCancellationMessage(true)
        // Provide your own localized or customized message text
        paymentVC.setSubscriptionCancellationMessageText("Cancel anytime from your account settings.")
    }
} catch {
    // handle error
}
