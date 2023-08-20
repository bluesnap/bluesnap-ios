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

## Custom Checkout Flow
The Custom Checkout Flow enables you to easily accept credit card payments using our flexible credit card UI component, allowing you to have full control over the look and feel of your checkout experience. 
Some of the capabilities include: 
* Flexible and customizable UI element with built-in validations and card-type detection.
* Helper classes to assist you in currency conversions, removing whitespace, and more.
* Simple function that submits sensitive card details directly to BlueSnap's server.
* Built-in 3D secure authentication.
* Reguler payments, shopper configuration and subscription charges.

To see an image of the credit card UI component, click [here](https://developers.bluesnap.com/v8976-Basics/docs/ios-sdk#section-custom-checkout-flow). 

## Standard Checkout Flow Using Your Own UI
This flow allows you to build you own checkout UI. Please note that by using your own UI, you will be required to handle the data-transmission to BlueSnap as well, by using the BlueSnapService class for performing API calls.
Some of the capabilities include:
* Helper classes to assist you in input validations, currency conversions, removing whitespace, and more.
* Simple function that submits sensitive card details directly to BlueSnap's server.
* Easy infrastructure for 3D secure authentication.
* Reguler payments, shopper configuration and subscription charges.

# Installation
> The SDK is written in Swift 5, using Xcode 14.3.1.

## Requirements
* Xcode 10+
* [BlueSnap API credentials](https://support.bluesnap.com/docs/api-credentials)

BluesnapSDK expects a .plist file that contains the BlueSnap API credentials in your product bundles. Please note that it's fine to have just one physical instance of the file and have the rest of the instances be Xcode references.

The .plist file must be called `credentials.plist` and it must contain 2 strings in the root of the plist, `BsAPIUser` and `BsAPIPassword` (the order in which they appear in the plist does not matter).

## CocoaPods (Optional, CocoaPods 1.1.0+)
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate BluesnapSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'BluesnapSDK', '~> <git tag/branch name>' 
    pod 'BluesnapSDK/DataCollector', '~> <git tag/branch name>'

end
```

Then, run the following command:

```bash
$ pod install
```
> Use the .xcworkspace file to open your project in Xcode.

## SPM (Optional)

To integrate BluesnapSDK into your Xcode project using SPM, open your project in Xcode and add the package by opening the SPM dialog via File -> Add Package Dependencies. After the SPM dialog window opens up, enter the repo's URL in the search bar and then click Add Package. **Important:** When Xcode prompts you to select the packages you want to import, you **MUST** select the `KountWrapper` package as well, regardless of whether or not you are using Kount in your project. Due to SPM limitations, `KountWrapper` is a direct dependency of `BluesnapSDK` in this instance, and both must come together.

## Disable landscape mode
Landscape mode is not supported in our UI, so in order to make sure the screen does not rotate with the device, you need to add this code to your application's AppDelegate.swift file:

    // MARK: Prevent auto-rotate
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.portrait.rawValue)
    }

## Apple Pay (optional)
In the Standard Checkout Flow, Apple Pay is available for you to offer in your app. You will need to create a new Apple Pay Certificate, Apple Merchant ID, and configure Apple Pay in Xcode. Detailed instructions are available in our [Apple Pay Guide](https://developers.bluesnap.com/docs/apple-pay#section-implementing-apple-pay-in-your-website-or-ios-app). 

The SDK will activate the Apple Pay UI, and colelct payment details from the shopper. It will then collect the pkpayment token and  will pass it encrypted to Bluesnap Servers. You are not required to handle the applepay token yourself in your mobile app or in your server, just finish the transaction using the server to server call as ususal.
Please note that example app will not be able to complete the demonstrated server to server call when running on simulator. This requires a physical device.



## PayPal (optional)
In the Standard Checkout Flow, you have the option to accept PayPal payments in your app. Follow these steps: 

1. Make sure you have a PayPal Business or Premier account. If you do not yet have a PayPal account, you can sign up for one on the PayPal website.

2. Connect your PayPal account to BlueSnap. Detailed instructions are available [here](https://support.bluesnap.com/docs/connecting-paypal-and-bluesnap). 

# Usage
This section will cover the following topics: 
* [Generating a token for the transaction](#generating-a-token-for-the-transaction)
* [Initializing the SDK](#initializing-the-sdk)

## Generating a token for the transaction
For each transaction, you'll need to generate a Hosted Payment Fields token on your server and pass it to the SDK.

To do this, initiate a server-to-server POST request with your API credentials and send it to the relevant URL for the Sandbox or Production environment:
* **Sandbox:** `https://sandbox.bluesnap.com/services/2/payment-fields-tokens`
* **Production:** `https://ws.bluesnap.com/services/2/payment-fields-tokens`

> **Specifying a returning user** <br>
>To specify a returning user and have BlueSnap pre-populate the checkout page with their information, include the parameter `shopperId` in the URL query string. For example: `https://sandbox.bluesnap.com/services/2/payment-fields-tokens?shopperId=20848977`

 A successful response will contain the token in Location header. For more information, see [Creating a Hosted Payment Fields Token](http://developers.bluesnap.com/v4.0/docs/create-hosted-payment-fields-token). 

## Initializing the SDK
Create a `BSToken` instance using your token string.

```swift
fileprivate var bsToken : BSToken?
bsToken = BSToken(tokenStr: "c3d011abe0ba877be0d903a2f0e4ca4ecc0376e042e07bdec2090610e92730b5_")
```

Initialize your token and any additional functionality (such as Apple Pay or fraud prevention) in the SDK by calling the [`initBluesnap`](#initbluesnap) function of the `BlueSnapSDK` class. See [initBluesnap](#initbluesnap) for a complete list of the function's parameters. **Note:** For each purchase, you'll need to call `initBluesnap` with a new token. 

→ If you're using the Standard Checkout Flow, then continue on to the next section. <br>
→ If you're using the Custom Checkout Flow, then jump down to [Implementing Custom Checkout Flow](#implementing-custom-checkout-flow). 

# Implementing Standard Checkout Flow Using BlueSnap SDK UI
This section will cover the following topics: 
* [Defining your checkout settings](#defining-your-checkout-settings)
* [Launching checkout UI](#launching-checkout-ui)

## Defining your checkout settings
The [`showCheckoutScreen`](#showcheckoutscreen) function of the `BlueSnapSDK` class is the main entry point for the SDK and should be called after `initBluesnap`. When called, this function launches the checkout UI for the user based on the parameters you provide. For example, you can display tax amounts and subtotals, specify which fields to require from the user, and pre-populate the checkout page with information you've already collected.

This function takes the parameters listed below. We'll go over setting `sdkRequest` in this section. 

| Parameter | Description |
| ------------- | ------------- |
| `inNavigationController`  | Your `ViewController`'s `navigationController` (to be able to navigate back).  |
| `animated` | Boolean that indicates if page transitions are animated. If `true`, wipe transition is used. If `false`, no animation is used - pages replace one another at once. |
| `sdkRequest` | Object that holds price information, required checkout fields, and initial user data. |

See the [Reference](#showcheckoutscreen) section below for more information on `showCheckoutScreen`. 

### Defining sdkRequest
`sdkRequest` (an instance of `BSSdkRequest`) holds your checkout settings, such as price details, required user fields, and user data you've already collected, as well as holds your callback functions to complete the purchase and to update tax rates. 

```swift
fileprivate var sdkRequest: BSSdkRequest! = BSSdkRequest(...)
```

BSSdkRequest constructor parameters:

| Parameter      | Description   |
| ------------- | ------------- |
| Parameters for specifying required checkout fields: |
| `withEmail`   | Boolean that determines if email is required. Default value is `true` - email is required. |
| `fullBilling` | Boolean that determines if full billing details are required. Default value is `false` - full billing details are not required. |
| `withShipping` | Boolean that determines if shipping details are required. If `true`, shipping details (i.e. name, address, etc.) are required. Default value is `false` - shipping details are not required. |
| Parameter that defines purchase amount and currency: |
| `priceDetails` | Instance of `BSPriceDetails` that holds the price details (see [Defining priceDetails](#defining-pricedetails)) |
| Parameters that allow you to pre-populate the checkout page (if you have user's data that you've already collected): |
| `billingDetails` | Instance of `BSBillingAddressDetails` (see [Pre-populating the checkout page](#pre-populating-the-checkout-page-optional)). |
| `shippingDetails` | Instance of `BSShippingAddressDetails` (see [Pre-populating the checkout page](#pre-populating-the-checkout-page-optional)). |
| Callback functions: |
| `purchaseFunc` | Callback function that handles the purchase (see [Defining your purchase callback function](#defining-your-purchase-callback-function)).|
| `updateTaxFunc` | Optional. Callback function that handles tax rate updates (see [Handling tax updates](#handling-tax-updates-optional)). |
| `allowCurrencyChange` | Optional. Will allow the shopper to change currency on pay with credit card screen (default is true). |
| `hideStoreCardSwitch` | Optional. Allows to hide the Securely store my card Switch (default is false). |
| `activate3DS` | Optional. Require a 3D Secure Authentication from the shopper while paying with credit card (default is false). |
| `applePayCustomizePayLine` | Optional. Your own customized pay line for the ApplePay pop-up. see [Apple Guidlines](https://developer.apple.com/design/human-interface-guidelines/apple-pay/overview/checkout-and-payment/#customize-the-payment-sheet). (default is "PAY [MERCHANT_NAME]") |

#### Defining priceDetails
`priceDetails` (an instance of `BSPriceDetails`) is a property of `sdkRequest` that contains properties for amount, tax amount, and [currency](https://developers.bluesnap.com/docs/currency-codes). Set these properties to intialize the price details of the checkout page. 

```swift
sdkRequest.priceDetails = BSPriceDetails(amount: 25.00, taxAmount: 1.52, currency: "USD")
```
> If you’re accepting PayPal payments, please note: PayPal will be available only if `currency` is set to a currency supported by your [PayPal configuration](https://support.bluesnap.com/docs/connecting-paypal-and-bluesnap#section-4-synchronize-your-currency-balances). 

#### Pre-populating the checkout page (optional)
The following properties of `sdkRequest` allow you to pass information that you've already collected about the user in order to pre-populate the checkout page.

| Property      | Description   |
| ------------- | ------------- |
| `billingDetails` | An instance of `BSBillingAddressDetails` that contains properties for name, address, city, country, state, and email. |
| `shippingDetails` | An instance of `BSShippingAddressDetails` that contains properties for name, address, and so on. |

In ViewController.swift of the demo app, take a look at the `setInitialShopperDetails` function to see an example of setting these properties with user data.

#### Handling tax updates (optional)
If you choose to collect shipping details (i.e. `withShipping` is set to `true`), then you may want to update tax rates whenever the user changes their shipping location. Supply a callback function to handle tax updates to the `updateTaxFunc` property of `sdkRequest`. Your function will be called whenever the user changes their shipping country or state. To see an example, check out `updateTax` in the demo app. 

#### Defining your purchase callback function
`purchaseFunc` is a member of `sdkRequest` that takes a callback function to be invoked after the user hits “Pay” and their data is successfully submitted to BlueSnap (and associated with your token). `purchaseFunc` will be invoked with one of the following class instances (if and only if data submission to BlueSnap was successful): 

* If the result is a `BSApplePaySdkResult` instance, it will contain details about the amount, tax, and currency. Note that billing/shipping info is not collected, as it’s not needed to complete the purchase.  

* If the result is a `BSCcSdkResult` or `BSExistingCcSdkResult` instance, it will contain details about the amount, tax, currency, shipping/billing information, 3D Secure authentication result, and non-sensitive credit card details (card type, last 4 digits, issuing country). 

* If the result is a `BSPayPalSdkResult`, then the transaction has already been completed! There is no need to send the transaction for processing from your server.  

The following logic should apply within `purchaseFunc` : 
1. Detect the specific payment method the user selected. 

2. If the user selected PayPal, no further action is required - transaction is complete. Show success message.

3. If the user selected Apple Pay or credit card, update your server with the order details and the token. Unless you need to keep the non-secure CC details, there is really no difference in handling Credit card or Apple Pay. You just need the token to finalize the transaction.

4. From your server, [complete the purchase](#sending-the-payment-for-processing) with your token. 

5. After receiving BlueSnap's response, update the client and display an appropriate message to the user. 

The function `completePurchase` in the demo app shows this logic.
```swift
private func completePurchase(purchaseDetails: BSBaseSdkResult!) {

    if let paypalPurchaseDetails = purchaseDetails as? BSPayPalSdkResult {
        // user chose PayPal
        // show success message
        return // no need to complete purchase via BlueSnap API
    }

    // handle Apple-Pay or Credit card:
    // send order details & bsToken to server...
    // ...receive response

    // depending on response, show success/fail message
}
```

> **Notes**: 
> * `purchaseFunc` will be called only if the user's details were successfully submitted to BlueSnap. It will not be called in case of an error. 
>
> * It's very important to send the payment for processing from your server. 

## Launching checkout UI
Now that you've set `showCheckoutScreen`'s parameters, it's time to launch the checkout UI for the user. 
```swift
    BlueSnapSDK.showCheckoutScreen(
        inNavigationController: self.navigationController,
        animated: true,
        sdkRequest: sdkRequest
    )
```
And you're ready to go! Accepting Apple Pay, credit card, and PayPal payments will be a breeze.

## Configure shopper flow
BlueSnap SDK offers an easy flow to collect a shopper's information and selected payment method. This flow will be used in apps where you wish to save the shopper's payment details upon registration, and use it later in a quick and easy fashion. This flow can be run only for an existing shopper (you can easily create the shopper using BlueSnap API). If the shopper chooses a Credit card, we collect the billing details and store them on BlueSnap servers, so that the (later) charge will not require the shopper to type any information. If the shopper chooses Google Pay or PayPal, we simply keep this preference, so that in the next step (Create Payment flow), the shopper will automatically get the ApplePay pop-up or the PayPal page.

In order to run this flow you will need to create an `BSSdkRequestShopperRequirements` instance instead of `sdkRequest` and to launch the `showChoosePaymentScreen` instead of `showCheckoutScreen`. In `purchaseFunc` you won't need to do any farther action since this phase is only about saving details.

## Pay with selected payment method flow
BlueSnap SDK offers an easy flow to create a transaction using an existing shopper's selected payment method. This is where you quickly complete the payment with the shopper’s chosen payment method. This flow can be run only for an existing shopper that HAS valid chosen payment details. If (in the previous step: Configure shopper flow) the shopper chose a credit card, you will get the response immediately; if the shopper chose ApplePay or PayPal, they will now do the payment flow. In both cases, the result is the same as in the the regular Checkout flow: The BSBaseSdkResult returns some (non secure) information.

In order to run this flow you will need to create an `sdkRequest` instance and to launch the `showCreatePaymentScreen` instead of `showCheckoutScreen`. In `purchaseFunc` you will need to complete the transaction, exectly like in the regular checkout flow- mainly all you need to do now is let your app server do an API call to BlueSnap, sending just the token, and the transaction will be completed. In case of PayPal, you don't even have to do that, since PayPal flow already completes the transaction. 

> **Important**: For each new purchase, you need to generate a new token, call `initBluesnap` with your token and any additional parameters, and then call `showCheckoutScreen` (in this order). 

# Implementing Custom Checkout Flow
This section will cover the following topics: 
* [Configuring BSCcInputLine](#configuring-bsccinputline)
* [Setting up BSCcInputLineDelegate](#setting-up-bsccinputlinedelegate)
* [Setting up your submit action](#setting-up-your-submit-action)

## Configuring BSCcInputLine
[`BSCcInputLine`](#bsccinputline) is a UIView that holds the user's sensitive credit card data - credit card number, expiration date, and CVV. In addition to supplying an elegant user experience, it handles input validations, and submits the secured data to BlueSnap. Simply place a UIView in your storyboard and set its class to `BSCcInputLine`.

> **Notes**: 
> * In addition to card details, be sure to collect the user information marked as **Required** on [this page](https://developers.bluesnap.com/v8976-JSON/docs/card-holder-info).
> * If you would like to build your own UI fields for credit card number, expiration date, and CVV, BlueSnap provides you with a function called [`submitTokenizedDetails`](#submittokenizeddetails) to submit the user's card data directly to BlueSnap. Visit the [Reference](#submittokenizeddetails) section to learn more.

## Setting up BSCcInputLineDelegate
If you're using `BSCcInputLine` to collect the user's data, in your `ViewController` you'll need to implement `BSCcInputLineDelegate`, which has 6 methods:

| Method      | Description   |
| ------------- | ------------- |
| `startEditCreditCard()` | Called just before the user enters the open state of CC field to edit it (in the UI, BlueSnap uses this stage to hide other fields). |
| `endEditCreditCard()` | Called after the user exits the CC field and it is the closed state to show last 4 digits of CC number (in the UI, BlueSnap uses this stage to un-hide the other fields). |
| `willCheckCreditCard()` | Called just before submitting the CC number to BlueSnap for validation (this action is asynchronous; in the UI, BlueSnap does nothing at this stage). |
| `didCheckCreditCard(creditCard: BSCreditCard, error: BSErrors)` | Called when BlueSnap gets the CC number validation response; if the error is empty, you will get the CC type, issuing country, and last 4 digits of CC number inside `creditCard` (in the UI, BlueSnap uses this stage to change the icon for the credit card type). Errors are shown by the component, you do not need to handle them. |
| `didSubmitCreditCard(creditCard: BSCreditCard, error: BSErrors)`* | Called when the response for the token submission is received (in the UI, BlueSnap uses this stage to close the window and callback the success action) – errors are shown by the component, you need not handle them. |
| `showAlert(_ message: String)` | Called when there is an unexpected error (not a validation error). |

*Within `didSubmitCreditCard`, you'll do the following: 
1. Detect if the user's card data was successfully submitted to BlueSnap (i.e. error is `nil`). 

2. If error is `nil`, you'll get the CC type, issuing country, and last 4 digits of CC number within `creditCard`. Update your server. 

3. From your server, you'll [send the payment for processing](#sending-the-payment-for-processing) using your token.

4. After you receive BlueSnap's response, you'll update the client and display an appropriate message to your user (i.e. "Congratulations, your payment was successful!" or "Oops, please try again.").

## Setting up your submit action
On your submit action (i.e. when the user submits their payment during checkout), you should call `BSCcInputLine`'s `validate` function to make sure the data is correct. If the validation was successful (i.e. `validate` returns `true`), then call `BSCcInputLine`'s `submitPaymentFields()` function, which will call the `didSubmitCreditCard` callback with the results of the submission. 

Another option is to call `checkCreditCard(ccn: String)`, which first validates and then submits the details, calling the delegate `didSubmitCreditCard` after a successful submit.

# Implementing Standard Checkout Flow Using Your Own UI
This section will cover the following topics: 
* [Collect all payment info](#collect-all-payment-info)
* [Generate a BSTokenizeRequest instance](#generate-a-bstokenizerequest-instance)
* [Submit details into BlueSnap server](#submit-details-into-bluesnap-server)
* [Handle 3D Secure authentication](#handle-3d-secure-authentication)

You need to create UI layout files and activities on your own. Please use the entities and methods provide business logic as described below:

## Collect all payment info
Use your own UI to collect all payment info from the shopper. You can use [Helper classes](#helper-classes) for input validations, currency conversions, removing whitespace, and more.

## Generate a BSTokenizeRequest instance
* in case of a credit card purchase

A BSTokenizeRequest instance is required to pass the purchase details to the BlueSnap server. The object includes the following properties:
* [paymentDetails](#paymentdetails-propertie) - The shopper's credit card information
* billingDetails - The shopper's billing information
* shippingDetails - The shopper's shipping information

### paymentDetails propertie
If you are submitting a new credit card (for either a new or an existing shopper), you should crate an  `BSTokenizeNewCCDetails`  and store all of its properties.

If you are submitting an existing card (for an existing shopper and a credit card that was previously submitted and stored), you should crate an  `BSTokenizeExistingCCDetails`  and store all of its properties.

## Submit details into BlueSnap server
Use [submitTokenizedDetails](#submitTokenizedDetails) of BlueSnapSDK to submit the shopper's details.

## Handle 3D Secure Authentication
BlueSnap SDK integrates Cardinal SDK to provide a full handling of 3D secure authentication. 

Use [authenticationWith3DS](#authenticationWith3DS) of BlueSnapSDK to invoke the authentication .


# Sending the payment for processing
If the shopper purchased via PayPal, then the transaction has successfully been submitted and no further action is required.

If the shopper purchased via credit card, you will need to create a transaction using a server-to-server API call to BlueSnap's Payment API with the Hosted Payment Field token you initialized in the SDK. You should do this after the shopper has completed checkout and has left the SDK checkout screen. Visit the [API documentation](https://developers.bluesnap.com/v8976-Basics/docs/completing-tokenized-payments) to see how.

In case of a Subscription checkout, you should create a subscription using a server to server API call, This is also covered in the [API documentation](https://developers.bluesnap.com/v8976-Basics/docs/completing-tokenized-payments). 

**Note:** In the Standard Checkout Flow, this is when `purchaseFunc` is called. In the Custom Checkout Flow, this is when `didSubmitCreditCard` is called (if you're using the `BSCcInputLine` field) or `completion` is called (if you're using your own input fields). 

DemoTransactions.swift of demo app shows an example of an Auth Capture request. Please note that these calls are for demonstration purposes only - the transaction should be sent from your server.

# 3D Secure Authentication
The SDK includes an integrated Cardinal SDK for 3DS Authentication.

If you are using BlueSnap SDK UI: If you choose to activate this service and the shopper chooses credit card as a payment method, the 3DS authentication result will be passed as part of the SdkResult when `purchaseFunc` of the `sdkRequest` is called. You can access it like this:
```swift
    let threeDSResult = (purchaseDetails as? BSCcSdkResult)?.threeDSAuthenticationResult
```
If you're using your own UI: Cardinal result will be available in the callback function of `authenticationWith3DS`.

If 3DS Authentication was successful, the result will be one of the following:
* `AUTHENTICATION_SUCCEEDED` = 3D Secure authentication was successful because the shopper entered their credentials correctly or the issuer authenticated the transaction without requiring shopper identity verification.
* `AUTHENTICATION_BYPASSED` = 3D Secure authentication was bypassed due to the merchant's configuration.

If 3DS Authentication was **not** successful, the result will be one of the following errors:
* `AUTHENTICATION_UNAVAILABLE` = 3D Secure authentication is unavailable for this card.
* `AUTHENTICATION_FAILED` = Card authentication failed in cardinal challenge.
* `THREE_DS_ERROR` = Either a Cardinal internal error or a server error occurred.
* `CARD_NOT_SUPPORTED` = No attempt to run 3D Secure challenge was done due to unsupported 3DS version.
* `AUTHENTICATION_CANCELED` (only possible when using your own UI) = The shopper canceled the challenge or pressed the 'back' button in Cardinal activity.

In that case, you can decide whether you want to proceed with the transaction without 3DS Authentication or not. **Please note** that you will be able to proceed with the transaction only If the option **Process failed 3DS transactions** is enabled in **Settings > Fraud Settings** in the BlueSnap Console.

# Demo app - explained
The demo app shows how to use the basic functionality of the Standard Checkout Flow, including the various stages you need to implement (everything is in class `ViewController`).

## Demo app credentials
The Demo app requires Sandbox API credentials to simulate the merchant server operation, you can get your Sandbox API credentials from the Bluesnap Sandbox dashboard.
The Credentials are injected to Configuration.swift using environment variables, Alternatively you can put them directly there for demo purposes.
You can either put the environment variables in your shell, or write them in Configuration.swift
The Credentials will be printed to the demo app log.
> **note**  
To make Xcode pass the environment variable to the build process you need to set this explicitly using the following command line:
>
> defaults write com.apple.dt.Xcode UseSanitizedBuildSystemEnvironment -bool NO

The environment variables are configured in info.plist in the demo app, see ${BS_API_USER} ${BS_API_PASSWORD}

While this approach is fine for the demo app it should not be used in real life cases. do not leave your API credentials in your app code.

 
 The basic steps include:

1. Getting a token from BlueSnap's server. Please note that you need to do this from your server. In the demo app, we create a token from the BlueSnap Sandbox environment with dummy credentials. According to the toggle in the UI, we either create a token with a shopper ID (for returning user flow) or without the shopper ID (for new user flow).

2. Calling `BlueSnapSDK.initBluesnap` to initialize the token and any additional settings, such as fraud detection or a token expiration callback function, in the SDK. 

3. Initializing the input to the checkout flow by creating an instance of `BSSdkRequest` and filling the parts you may know already of the user (by setting `shippingDetails` & `billingDetails`), supplying your callback for tax calculations, and specifying the fields you wish to require from the user (by setting `withShipping`, `fullBilling`, & `withEmail`). 

4. Defining the `purchaseFunc` callback to call your application's server to complete the purchase (see [Defining your purchase callback function](#defining-your-purchase-callback-function) for the logic of this function).

5. Calling `BlueSnapSDK.showCheckoutScreen` to launch the checkout UI for the user. 

> **Note**: The demo app shows how to take advantage of our currency screen, which allows the user to change the currency selection during checkout, by calling [`BlueSnapSDK.showCurrencyList`](#showcurrencylist) with its associated parameters. <br>
 > **Important**: All transaction calls are for demonstration purposes only. These calls should be made from your server. 

# Reference
This section will cover the following topics: 
* [Data structures](#data-structures)
* [Main functionality - BlueSnapSDK class](#main-functionality---bluesnapsdk-class)
* [Handling token expiration](#handling-token-expiration)
* [Helper classes](#helper-classes)
* [Custom UI controls](#custom-ui-controls)

## Data structures
In the BlueSnap iOS SDK project, the `Model` group contains the data structures used throughout.
 
### BSToken (in BSToken.swift)
`BSToken` is the simplest one. It contains the token you received from BlueSnap, so that the SDK can call BlueSnap API with it.

    public class BSToken {
        internal var tokenStr: String! = ""
        internal var serverUrl: String! = ""
        public init(tokenStr : String!) {
            ...
        }
        public func getTokenStr() -> String! {
            return self.tokenStr
        }    
        public func getServerUrl() -> String! {
            return self.serverUrl
        }
    }

The SDK holds a function for obtaining a token from our Sandbox environment for quick testing purposes.

### BSSdkRequest (in BSPurchaseModelData.swift)
This class allows you to initialize your checkout settings, such as price details, required user fields, and user data you've already collected.

For more information on the properties of `BSSdkRequest`, see [Defining sdkRequest](#defining-sdkrequest). 
 
    @objc public class BSSdkRequest : NSObject {
        public var withEmail: Bool = true
        public var withShipping: Bool = false
        public var fullBilling : Bool = false

        public var priceDetails: BSPriceDetails! = BSPriceDetails(amount: 0, taxAmount: 0, currency: nil)
        
        public var billingDetails : BSBillingAddressDetails?
        public var shippingDetails : BSShippingAddressDetails?
        public var purchaseFunc: (BSBaseSdkResult!) -> Void
        public var updateTaxFunc: ((_ shippingCountry: String, _ shippingState: String?, _ priceDetails: BSPriceDetails) -> Void)?
        
        public init(
                withEmail: Bool,
                withShipping: Bool,
                fullBilling: Bool,
                priceDetails: BSPriceDetails!,
                billingDetails: BSBillingAddressDetails?,
                shippingDetails: BSShippingAddressDetails?,
                purchaseFunc: @escaping (BSBaseSdkResult!) -> Void,
                updateTaxFunc: ((_ shippingCountry: String, _ shippingState: String?, _ priceDetails: BSPriceDetails) -> Void)?) {
                ...
        }
    }

### BSPriceDetails (in BSPurchaseDataModel.swift)
This class contains the price details that are both input and output for the purchase, such as amount, tax amount, and currency. 

    @objc public class BSPriceDetails : NSObject, NSCopying {
        
        public var amount : Double! = 0.0
        public var taxAmount : Double! = 0.0
        public var currency : String! = "USD"
        
        public init(amount : Double!, taxAmount : Double!, currency : String?) {
            super.init()
            self.amount = amount
            self.taxAmount = taxAmount
            self.currency = currency ?? "USD"
        }
        
        public func copy(with zone: NSZone? = nil) -> Any {
            let copy = BSPriceDetails(amount: amount, taxAmount: taxAmount, currency: currency)
            return copy
        }
        
        public func changeCurrencyAndConvertAmounts(newCurrency: BSCurrency!) {
            ...
        }
    }

### BSBaseAddressDetails, BSBillingAddressDetails, BSShippingAddressDetails (in BSAddress.swift)

These classes hold the user's bill and shipping details. 
Optional/Mandatory:
* Email will be collected only if `withEmail` is set to `true` in `BSInitialData`. 
* State is mandatory only if the country has state (USA, Canada and Brazil).
* Zip is always mandatory except for countries that have no postal/zip code.
* If you choose not to use the full billing option, name, country and zip are required, and email is optional.
* For full billing details, everything is mandatory. 
* For shipping details, all fields are mandatory except phone which is optional.

```
public class BSBaseAddressDetails {

    public init() {}

    public var name : String! = ""
    public var address : String?
    public var city : String?
    public var zip : String?
    public var country : String?
    public var state : String?

    public func getSplitName() -> (firstName: String, lastName: String)? {
        return BSStringUtils.splitName(name)
    }
}

public class BSBillingAddressDetails : BSBaseAddressDetails {

    public override init() { super.init() }
    public var email : String?
}

public class BSShippingAddressDetails : BSBaseAddressDetails {

    public override init() { super.init() }
    public var phone : String?
}
```

### BSPaymentType (in BSPurchaseDataModel.swift)
This enum differentiates between the payment method the user chose. It will contain cases for credit card, Apple Pay, and PayPal. 
```
public enum BSPaymentType {
    case CreditCard = "CC"
    case ApplePay = "APPLE_PAY"
    case PayPal = "PAYPAL"
}
```
### BSBaseSdkResult (in BSPurchaseDataModel.swift)
The central data structure is this class (and its derived classes), which holds user data that is the purchase details collected by the SDK. This is an abbreviated version of the class:

    public class BSBaseSdkResult : NSObject {
        
        var fraudSessionId: String?
        var priceDetails: BSPriceDetails!
            
        internal init(sdkRequest: BSSdkRequest) {
            ...
        }
    
    // Returns the fraud session ID used in KountInit()
        public func getFraudSessionId() -> String? {
            return fraudSessionId;
        }
        
        /*
        Set amounts will reset the currency and amounts, including the original amounts.
        */
        public func setAmountsAndCurrency(amount: Double!, taxAmount: Double?, currency: String) {
        ...
        }
         
        // MARK: getters and setters
        
        public func getAmount() -> Double! {
            return priceDetails.amount
        }
        
        public func getTaxAmount() -> Double! {
            return priceDetails.taxAmount
        }
        
        public func getCurrency() -> String! {
            return priceDetails.currency
        }
    }

### BSCcSdkResult (in BSCcPayment.swift)
This class inherits from `BSBaseSdkResult`, and it holds the data collected in the flow for a new Credit Card.

    public class BSCcSdkResult : BSBaseSdkResult {
        
        public var creditCard: BSCreditCard = BSCreditCard()
        public var billingDetails : BSBillingAddressDetails! = BSBillingAddressDetails()
        public var shippingDetails : BSShippingAddressDetails?
        public var threeDSAuthenticationResult: String!
        
        public override init(sdkRequest: BSSdkRequest) {
            ...
        }
    ...
    }

### BSExistingCcSdkResult (in BSCcPayment.swift)
This class inherits from `BSCcSdkResult` and it holds the data collected during checkout when a returning user selects an existing credit card. The data it holds is the same as the parent class.

    public class BSExistingCcPaymentRequest : BSCcPaymentRequest, NSCopying {
            
        ...
    }
    
### BSCreditCard (in BSCcPayment.swift)
This class contains the user's non-sensitive CC details for the purchase, including CC type, last four digits of CC number, and issuing country. 

    @objc public class BSCreditCard : NSObject, NSCopying {
        
        // these fields are output - result of submitting the CC details to BlueSnap
        public var ccType : String?
        public var last4Digits : String?
        public var ccIssuingCountry : String?
            public var expirationMonth: String?
            public var expirationYear: String?
        ...
    }

### BSApplePaySdkResult (in BSApplePayPayment.swift)
This class inherits from `BSBaseSdkResult`, and it holds the data collected in the ApplePay flow (which is currently nothing).

    public class BSApplePaySdkResult: BSBaseSdkResult {
        
        public override init(sdkRequest: sdkRequest) {
            ...
        }
    }

### BSPayPalSdkResult (in BSPayPalPayment.swift)
This class inherits from `BSBaseSdkResult`, and it holds the data collected in the PayPal flow, which is only the invoice ID.

    public class BSPayPalSdkResult: BSBaseSdkResult {
        
        public var payPalInvoiceId : String?
        
        override public init(sdkRequest: sdkRequest) {
        ...
        }
    }

## Main functionality - BlueSnapSDK class
The `BlueSnapSDK` class holds the main functionality for the SDK. In this section, we'll go through each function contained in this class. 

### initBluesnap
This is the first function you need to call to initialize your token, fraud prevention, Apple Pay, and more in the SDK. **Note:** The token expires after 60 minutes or after the transaction is complete (whichever comes first). 

Signature:

    open class func initBluesnap(
            bsToken : BSToken!,
            generateTokenFunc: @escaping (_ completion: @escaping (BSToken?, BSErrors?) -> Void) -> Void,
            initKount: Bool,
            fraudSessionId: String?,
            applePayMerchantIdentifier: String?,
        merchantStoreCurrency : String?,
            completion: @escaping (BSErrors?)->Void) {


| Parameter | Description |
| ------------- | ------------- |
| `bsToken`  | Your `BSToken` instance (see [Generating a token for the transaction](#generating-a-token-for-the-transaction)).  |
| `generateTokenFunc` | This function sets the callback function that creates a new token when the current one is expired. (see [Handling token expiration](#handling-token-expiration)).  |
| `initKount` | Pass `true` to initialize the Kount device data collection for fraud. We recommend setting this to `true`. |
| `fraudSessionId` | Optional. Unique ID (up to 32 characters) for the session. If empty, BlueSnap generates one for you. |
| `applePayMerchantIdentifier` | Optional. Merchant identifier for Apple Pay. |
| `merchantStoreCurrency` | Base currency code for currency rate calculations. |
| completion | Callback function to be called when the init process is done. At this time, you can call the other functions in the SDK. |

> **Notes**
> * `initBluesnap` is asynchronous and may take a few seconds. Its `completion` parameter is a callback function you supply, which will be called when the init is done. Make sure you do not start the checkout flow before this happens.<br>
> * Tokens expire after 60 minutes or after using the token to process a payment, whichever comes first. Therefore, you'll need to generate a new one for each purchase. This will be handled automatically for you when you supply the callback function in the `generateTokenFunc` parameter (see [Handling token expiration](#handling-token-expiration)).

#### Initializing fraud prevention
Pass `initKount: true` when calling `initBluesnap` to initialize the fraud prevention capabilities of the SDK. Data about the user's device will be collected for fraud profiling. You may pass the `fraudSessionId` if you have one. Otherwise, you can pass `nil` (empty) to have BlueSnap generate one for you. See the [Developer Docs](https://developers.bluesnap.com/docs/fraud-prevention#section-device-data-checks) for more info.

#### Configuring Apple Pay (optional)
Set your [Apple Pay Merchant ID](#apple-pay-optional) by passing the parameter `applePayMerchantIdentifier` when calling `initBluesnap`

### setBsToken
This function is used for [handling token expiration](#handling-token-expiration). Call it to set your token in the SDK (after receiving a new token from BlueSnap). **Note:** To initialize your token at the beginning of the flow, call `initBluesnap`.

Signature:

    open class func setBsToken(bsToken: BSToken!)
 
The token expires after 60 minutes or after the transaction is complete (whichever comes first). 


### showCheckoutScreen
This is the main function for the Standard Checkout Flow (you'll call it after calling `initBluesnap` has completed). Once you call `showCheckoutScreen`, the SDK starts the checkout flow for the user.

Signature:

    open class func showCheckoutScreen(
        inNavigationController: UINavigationController!,
        animated: Bool,
        sdkRequest : BSSdkRequest!)

Parameters:

| Parameter | Description |
| ------------- | ------------- |
| `inNavigationController`  | Your `ViewController`'s `navigationController` (to be able to navigate back).  |
| `animated` | Boolean that indicates if page transitions are animated. If `true`, wipe transition is used. If `false`, no animation is used - pages replace one another at once. |
| `sdkRequest` | Object that holds price information, required checkout fields, and initial user data. |

#### BSSdkRequestSubscriptionCharge (Subscriptions flow)
This is an Extention to the BSSdkRequest that enables subscription support, use This Object in case of a subscription flow.
The constructor for this object allows you to instantiate a Sdk Request without Price Details which is suitable for this flow.

 

### submitTokenizedDetails
This function is relevant if you're collecting the user's data using your own input fields. 
When called, `submitTokenizedDetails` submits the user's data to BlueSnap, where it will be associated with your token. 
> **Important:** Do not send raw credit card data to your server. Use this function from the client-side to submit sensitive data directly to BlueSnap.  

Signature:

    open class func submitTokenizedDetails(tokenizeRequest: BSTokenizeRequest, completion: @escaping ([String:String], BSErrors?) -> Void)
    
Parameters: 

| Parameter      | Description   |
| ------------- | ------------- |
| `tokenizeRequest` | Class `BSTokenizeRequest` contains properties for the user's data. Fill in the properties you wish to submit to BlueSnap to be tokenized. See BSTokenizeRequest.swift for full class details. |
| `completion` | Callback function that is invoked with non-sensitive credit card details (if submission was a success), or error details (if submission errored). |

Your `completion` callback should do the following: 
1. Detect if the user's card data was successfully submitted to BlueSnap (if `BSErrors` is `nil`).
2. If submission was successful, you can proceed with [Handle 3D Secure Authentication](#handle-3d-secure-authentication) **or** continue straight to the next steps without 3DS authentication:
3. Update your server with the transaction details. From your server, you'll [Send the payment for processing](#sending-the-payment-for-processing) using your token. 
4. After receiving BlueSnap's response, you'll update the client and display an appropriate message to the user. 

### authenticationWith3DS
This function is relevant if you're integrating 3D Secure Authentication using your own UI. 
`authenticationWith3DS` handles all data-transmission to BlueSnap and Cardinal servers.

Signature:

    open class func authenticationWith3DS(currency: String, amount: String, creditCardNumber: String? = nil, _ completion: @escaping (String, BSErrors?) -> Void)
    
Parameters: 

| Parameter      | Description   |
| ------------- | ------------- |
| `currency` | String that holds the shopper's selected currency |
| `amount` | String that holds the purchase amount |
| `creditCardNumber` | String that holds the shopper's credit card number. Required only for a new credit card. |
| `completion` | Callback function to call once the authentication is done; will receive string that is the authentication result, and optional error. |

In case the card's 3DS version is supported and the shopper identity verification is required: a Cardinal activity will be lunched and the shopper will be asked to enter the authentication code.

Once the 3D Secure flow is done, your completion callback will be called.

Your `completion` callback should do the following: 
1. Handle the 3DS authentication result. For 3DS result options see [3D Secure Authentication](#3d-secure-authentication)
2. In case there was a server error (`THREE_DS_ERROR`), the error description willl be available in the `completion` callback as `BSErrors` parameter.
2. If you choose to proceed with the transaction, follow the next steps:
3. Update your server with the transaction details. From your server, you'll [Send the payment for processing](#sending-the-payment-for-processing) using your token. 
4. After receiving BlueSnap's response, you'll update the client and display an appropriate message to the user. 


### createSandboxTestToken
Returns a token for BlueSnap Sandbox environment, which is useful for testing purposes.
In your real app, the token should be generated from your server and passed to the app so that the app will not expose your API credentials.
The completion function will be called once BlueSnap gets a result from the server. It will either receive either a token or an error.

Signature:

    open class func createSandboxTestToken(completion: @escaping (BSToken?, BSErrors?) -> Void)
    
### createSandboxTestTokenWithShopperId
Similiar to `createSandboxTestToken`, except here you supply a shopper ID to enable the returning user flow.

Signature:

    open class func createSandboxTestTokenWithShopperId(shopperId: Int?, completion: @escaping (BSToken?, BSErrors?) -> Void) 

## Handling token expiration
You'll handle token expiration by supplying the SDK with a callback function to be invoked when the token expires. You'll supply this function to the SDK as part of the `BlueSnapSDK.initBluesnap` call within the `generateTokenFunc` parameter (see [initBluesnap](#initbluesnap) for complete list of parameters).

Your callback function should have the following signature. In the demo app, this function is called `generateAndSetBsToken`. 

    func generateAndSetBsToken(completion: @escaping (_ token: BSToken?, _ error: BSErrors?)->Void)

Your function should do the following to resolve the token expiration. 
1. Call your server to generate a new BlueSnap token.
2. Initialize the token in the SDK by calling `BlueSnapSDK.setBsToken`.
3. Call the completion function passed as a parameter. If this is not done, the original action will not be able to complete successfully with the new token.


## Helper Classes
These helper classes provide additional functionality you can take advantage of, such as string valiations and currency conversions. 
 
### String Utils and Validations
#### BSStringUtils (in BSStringUtils.swift)
This string provide string helper functions like removeWhitespaces, removeNoneDigits, etc. 

#### BSValidator (in BSValidator.swift)
This class provides validation functions like isValidEmail, getCcLengthByCardType, formatCCN, getCCTypeByRegex, etc. to help you format credit card information, and validate user details. 

### Handling currencies and rates
These currency structures and methods assist you in performing currency conversions during checkout. Use the function `changeCurrencyAndConvertAmounts`of `BSPriceDetails`.

#### Currency Data Structures
We have 2 data structures (see BSCurrencyModel.swift):     `BSCurrency` holds a single currency and  `BSCurrencies` holds all the currencies.

```
public class BSCurrency {
    internal var name : String!
    internal var code : String!
    internal var rate: Double!
    ...
    public func getName() -> String! {
        return self.name
    }
    public func getCode() -> String! {
        return self.code
    }
    public func getRate() -> Double! {
        return self.rate
    }
}

public class BSCurrencies {
    ...
    public func getCurrencyByCode(code : String!) -> BSCurrency? {
        ...
    }
    public func getCurrencyIndex(code : String) -> Int? {
        ...
    }
    public func getCurrencyRateByCurrencyCode(code : String!) -> Double? {
        ...
    }
}
```
#### Currency Functionality (in BlueSnapSDK class):
##### getCurrencyRates
This function returns a list of currencies and their rates. The values are fetched when calling BlueSnapSDK.initBlesnap().

Signature:

    open class func getCurrencyRates() -> BSCurrencies?
 
##### showCurrencyList
If you're using the Standard Checkout Flow, you can use this function to take advantage of our currency selection screen, allowing the user to select a new currency to pay in. To see an example of calling this function, see ViewController.swift of the demo app. 

Signature:

    open class func showCurrencyList(
        inNavigationController: UINavigationController!,
        animated: Bool,
        selectedCurrencyCode : String!,
        updateFunc: @escaping (BSCurrency?, BSCurrency?)->Void,
        errorFunc: @escaping()->Void
    )

Parameters:

| Parameter      | Description   |
| ------------- | ------------- |
| `inNavigationController` | Your ViewController's navigationController (to be able to navigate back). |
| `animated` | Determines how to navigate to new screen. If `true`, then transition is animated.  |
| `selectedCurrencyCode` | 3 character [currency code](https://developers.bluesnap.com/docs/currency-codes) |
| `updateFunc` | Callback function that will be invoked each time a new value is selected. <br> See the function `updateViewWithNewCurrency` from demo app to see how to update checkout details according to new currency. |
| `errorFunc` | Callback function that will be invoked if we fail to get the currencies. |
  
## Custom UI Controls
If you want to build your own UI, you may find our custom controls useful, in themselves or to inherit from them and adjust to your own functionality.

There are a lot of comments inside the code, explaining how to use them and what each function does.

All 3 are @IBDesignable UIViews, so you can easily check them out: simply drag a UIView into your Storyboard, change the class name to one of these below, and start playing with the inspectable properties.

### BSBaseTextInput
BSBaseTextInput is a UIView that holds a text field and optional image; you can customize almost every part of it. It is less useful in itself, seeing it?s a base class for the following 2 controls.

### BSInputLine
BSInputLine is a UIView that holds a label, text field and optional image; you can customize almost every part of it.

### BSCcInputLine
BSCcInputLine is a UIView that holds the credit card fields (Cc number, expiration date and CVV). Besides a cool look and feel, it also handles its own validations and submits the secured data to the BlueSnap, so that your application does not have to handle it.
