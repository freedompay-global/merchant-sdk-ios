# iOS Merchant SDK


&emsp;The Payment SDK is a library that simplifies interaction with the Freedom Pay API. Supports iOS 15 and above.

---
# Table of Contents
:::note[]
- [Getting Started](#getting-started)
- [Installation Instructions](#installation-instructions)
- [SDK integration](#sdk-integration)
- [Integrating the PaymentView (Optional)](#integrating-the-paymentview-optional)
  - [Connecting `PaymentView`](#connecting-paymentview)
  - [Tracking Loading Progress (Optional)](#tracking-loading-progress-optional)
- [SDK Configuration](#sdk-configuration)
  - [`SdkConfiguration` Overview](#sdkconfiguration-overview)
  - [Applying the Configuration](#applying-the-configuration)
- [Working with the SDK](#working-with-the-sdk)
  - [Create Payment page/frame](#create-payment-pageframe)
  - [Get Payment status](#get-payment-status)
  - [Make Clearing Payment](#make-clearing-payment)
  - [Make Cancel Payment](#make-cancel-payment)
  - [Make Revoke Payment](#make-revoke-payment)
  - [Add New Card](#add-new-card)
  - [Get Added Cards](#get-added-cards)
  - [Remove Added Card](#remove-added-card)
  - [Create Card Payment](#create-card-payment)
  - [Confirm Card Payment](#confirm-card-payment)
  - [Confirm Direct Payment](#confirm-direct-payment)
- [Apple Pay Integration](#apple-pay-integration)
  - [1. Apple Developer Account Setup](#1-apple-developer-account-setup)
  - [2. Create a Payment Processing Certificate](#2-create-a-payment-processing-certificate)
  - [3. Enable Apple Pay in Your App ID](#3-enable-apple-pay-in-your-app-id)
  - [4. Xcode setup](#4-xcode-setup)
  - [5. Creating an Apple Pay Transaction](#5-creating-an-apple-pay-transaction)
  - [6. Confirming an Apple Pay Transaction](#6-confirming-an-apple-pay-transaction)
- [Error Handling and Results](#error-handling-and-results)
  - [`FreedomResult.success<T>`](#freedomresultsuccesst)
  - [`FreedomResult.error`](#freedomresulterror)
- [Data Structures](#data-structures)
- [Support](#support)
---

# Getting Started

&emsp;Before you begin integrating the **Freedom Payment SDK** into your iOS app, ensure you have the following:
- An iOS app project with a minimum deployment target of iOS 15.0
- Xcode 12.0 or later

---

# Installation Instructions

### Swift Package Manager

#### Option 1: Add via Xcode

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the repository URL: `https://github.com/freedompay-global/merchant-sdk-ios.git`
4. Select the version or branch you want to use
5. Click **Add Package**

#### Option 2: Add via Package.swift
Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/freedompay-global/merchant-sdk-ios.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["FreedomPaymentSdk"]
    )
]
```

## Import and use the SDK

```swift
import FreedomPaymentSdk
```

---

# SDK integration

## Initialize

&emsp;To initialize the **Freedom Payment SDK**, call the `create` method of the `FreedomAPI` class. This method requires *three parameters*:
- Your merchant ID
- Your merchant secret key
- The payment region

```swift
let merchantId = "123456"
let secretKey = "123456789ABCDEF"
let region = Region.kz
let freedomApi = FreedomAPI.create(merchantId: merchantId, secretKey: secretKey, region: region)
```
### Table: `Region`
| Enum Constant | Description        |
|---------------|--------------------|
| `kz`          | Kazakhstan region. |
| `uz`          | Uzbekistan region. |
| `kg`          | Kyrgyzstan region. |

---

# Integrating the PaymentView (Optional)

## Connecting `PaymentView`
&emsp;Pass the instance of your PaymentView to the SDK:
```swift
let paymentView = PaymentView()
freedomApi.setPaymentView(paymentView)
```

## Tracking Loading Progress (Optional)

&emsp;To track the loading progress of the payment page, use the `onLoadingStateChanged` listener:
```swift
paymentView.onLoadingStateChanged { isLoading in
    // Handle loading state changes (e.g., show/hide a progress indicator)
}
```

---

# SDK Configuration

&emsp;The SDK's behavior is controlled through its configuration, which you manage using the `SdkConfiguration` struct. This struct acts as a central container, encapsulating two key components: `UserConfiguration` for customer-specific settings and `OperationalConfiguration` for general operational parameters.

## `SdkConfiguration` Overview

The `SdkConfiguration` is passed to the SDK via `freedomApi.setConfiguration()`.

```swift
public struct SdkConfiguration(
    public init(
        userConfiguration: UserConfiguration = UserConfiguration(),
        operationalConfiguration: OperationalConfiguration = OperationalConfiguration()
    ) {
        self.userConfiguration = userConfiguration
        self.operationalConfiguration = operationalConfiguration
    }
)
```

### Table: `UserConfiguration`
&emsp;This struct holds customer-specific details.

| Property           | Type      | Description                                                                                                                        | Default Value |
|--------------------|-----------|------------------------------------------------------------------------------------------------------------------------------------|---------------|
| `userPhone`        | `String?` | Customer's phone number. If provided, it will be displayed on the payment page. If `nil`, the user will be prompted to enter it.  | `nil`        |
| `userContactEmail` | `String?` | Customer's contact email.                                                                                                          | `nil`        |
| `userEmail`        | `String?` | Customer's email address. If provided, it will be displayed on the payment page. If `nil`, the user will be prompted to enter it. | `nil`        |

### Table: `OperationalConfiguration`
&emsp;This struct contains general operational settings for the SDK.

| Property        | Type          | Description                                                                                                                                                    | Default Value                                                                   |
|-----------------|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| `testingMode`   | `Bool`    | Enables or disables test mode.                                                                                                                                 | `nil`                                                                          |
| `language`      | `Language`   | Sets the language of the payment page. See [`Language`](#table-language) enum for available options.                                                           | `.RU`                                                                          |
| `lifetime`      | `Int`         | Duration, in seconds, for which the payment page remains valid for completing a payment.                                                                       | `300`                                                                          |
| `autoClearing`  | `Bool?`    | Activates automatic clearing of payments.                                                                                                                      | `nil`                                                                          |
| `checkUrl`      | `String?`     | URL to which the payment check will be sent.                                                                                                                   | `nil`                                                                          |
| `resultUrl`     | `String?`     | URL to which the payment result will be sent.                                                                                                                  | `nil`                                                                          |
| `requestMethod` | `HttpMethod?` | HTTP method used for requests to `checkUrl` or `resultUrl`. See [`HttpMethod`](#table-httpmethod) enum. Defaults to `GET` if `checkUrl` or `resultUrl` is set. | `HttpMethod.GET` (if `checkUrl` or `resultUrl` is not `nil`, otherwise `nil`) |

### Table: `Language`
| Enum Constant | Description                      |
|---------------|----------------------------------|
| `kz`          | SDK uses the `Kazakh` language.  |
| `ru`          | SDK uses the `Russian` language. |
| `en`          | SDK uses the `English` language. |

### Table: `HttpMethod`
| Enum Constant | Description                      |
|---------------|----------------------------------|
| `GET`         | SDK uses the HTTP `GET` method.  |
| `POST`        | SDK uses the HTTP `POST` method. |

## Applying the Configuration
&emsp;To apply your desired SDK configuration, create an instance of `SdkConfiguration` and pass it to the `freedomApi.setConfiguration()` method:

```swift
let userConfig = UserConfiguration(userPhone: "+123123123123", userEmail: "test@test.test")
let operationalConfig = OperationalConfiguration(
    testingMode: true,
    language: .RU,
    autoClearing: false,
    checkUrl: "https://test.check.url/",
    resultUrl: "https://test.result.url/"
)
let sdkConfiguration = SdkConfiguration(
    userConfiguration: userConfig,
    operationalConfiguration: operationalConfig)
freedomApi.setConfiguration(sdkConfiguration)
```

---
# Working with the SDK

&emsp;This section details the primary methods available in the SDK for managing payments within your application.

## Create Payment page/frame
&emsp;To initiate a new payment transaction and display the payment page, call the `createPaymentPage` or `createPaymentFrame` method on your `FreedomAPI` instance. This method handles the presentation of the payment page/frame within the previously configured `PaymentView`.

:::warning[]
These methods require that a `PaymentView` has been set using [`freedomApi.setPaymentView()`](#integrating-the-paymentview-optional) prior to calling them.
:::

&emsp;These methods accept several parameters to define the payment details:

| Parameter        | Type                                       | Description                                                                                                                                   |
|------------------|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| `paymentRequest` | `StandardPaymentRequest`                   | Essential details required to initiate a new payment. See [`StandardPaymentRequest`](#standardpaymentrequest-structure) model.                |
| `onResult`       | `(FreedomResult<PaymentResponse>) -> Void` | Callback function that will be invoked upon the completion of the payment process. See [`PaymentResponse`](#paymentresponse-structure) model. |

&emsp;The process returns an [`FreedomResult<PaymentResponse>`](#error-handling-and-results) object, which can be either:
- **Success**: Contains a `PaymentResponse` object.
- **Error**: Specifies the type of error that occurred.

```swift
val paymentRequest = StandardPaymentRequest(
    amount: 123.45,
    currency: Currency.KZT, // Using the provided Currency enum
    description: "Monthly Subscription",
    userId: "user12345",
    orderId: "SUB-2025-001",
)

freedomApi.createPaymentPage(paymentRequest: paymentRequest) { (result: FreedomResult<PaymentResponse>) in
    switch (result) {
        case .success:
            // Payment page processed successfully.
        case .error:
            // An error occurred during the payment process.
        }
    }
}
```

## Get Payment status
&emsp;To retrieve the current status of a previously initiated payment, use the `getPaymentStatus` method.

&emsp;This method takes these parameters:

| Parameter   | Type                              | Description                                                                                                            | Constraints/Notes |
|-------------|-----------------------------------|------------------------------------------------------------------------------------------------------------------------|-------------------|
| `paymentId` | `Int64`                            | Unique identifier of the payment you want to check.                                                                    |                   |
| `includeLastTransactionInfo` | `Bool?`           | Optional. When true, includes details of the most recent transaction in the response.                                  |                   |
| `onResult`  | `@escaping (FreedomResult<Status>) -> Void` | Callback function that will be invoked with the result of the payment status. See [`Status`](#status-structure) model. |                   |

&emsp;The process returns an [`FreedomResult<Status>`](#error-handling-and-results) object, which can be either:

- **success**: Contains a `Status` object.
- **error**: Specifies the type of error that occurred.

```swift
freedomApi.getPaymentStatus(Int64(123456), includeLastTransactionInfo: true) { (result: FreedomResult<Status>) in
    switch result {
    case .success:
        // Payment status retrieved successfully.
    case .error:
        // Failed to retrieve payment status.
    }
}
```

## Make Clearing Payment
:::info[]
This method is specifically designed for merchants who have **auto-clearing disabled** in their SDK configuration. Auto-clearing can be managed via the `autoClearing` property within the [`OperationalConfiguration`](#table-operationalconfiguration) of your `SdkConfiguration`.
:::

&emsp;Use the `makeClearingPayment` method to explicitly initiate the clearing (final capture) of funds for a previously authorized payment. This method gives you the flexibility to clear an amount that may be different from the original amount specified when the payment was created (e.g., for partial captures).

&emsp;This method takes these parameters:

| Parameter   | Type                                      | Description                                                                                                                                | Constraints/Notes                                                                                                      |
|-------------|-------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| `paymentId` | `Int64`                                    | Unique identifier of the payment you want to clear.                                                                                        |                                                                                                                        |
| `amount`    | `Decimal?`                                  | Amount to be cleared. If `nil`, the full amount of the original authorized payment will be cleared.                                       | Optional. Defaults to nil. Must be between `0.01` and `99999999.00` if provided. Cannot exceed the authorized amount. |
| `onResult`  | `@escaping (FreedomResult<ClearingStatus>) -> Void` | Callback function that will be invoked with the result of the clearing operation. See [`ClearingStatus`](#clearingstatus-structure) model. |                                                                                                                        |

&emsp;The process returns an [`FreedomResult<ClearingStatus>`](#error-handling-and-results) object, which can be either:
- **Success**: Contains a `ClearingStatus` object.
- **Error**: Specifies the type of error that occurred.

```swift
freedomApi.makeClearingPayment(Int64(123456)) { (result: FreedomResult<ClearingStatus>) in
    switch result {
    case .success:
        // Handle the clearing status.
    case .error:
        // Failed to clear the payment.
    }
}
```

## Make Cancel Payment
:::info[]
This method is specifically designed for merchants who have **auto-clearing disabled** in their SDK configuration. Auto-clearing can be managed via the `autoClearing` property within the [`OperationalConfiguration`](#table-operationalconfiguration) of your `SdkConfiguration`.
:::

&emsp;Use the `makeCancelPayment` method to reverse an authorized payment, effectively unblocking the amount on the customer's card. This ensures that the funds will not be charged.

&emsp;This method takes these parameters:

| Parameter   | Type                                       | Description                                                                                                                                    | Constraints/Notes |
|-------------|--------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|-------------------|
| `paymentId` | `Int64`                                     | Unique identifier of the payment you want to cancel.                                                                                           |                   |
| `onResult`  | `@escaping (FreedomResult<PaymentResponse>) -> Void` | Callback function that will be invoked with the result of the cancellation attempt. See [`PaymentResponse`](#paymentresponse-structure) model. |                   |

&emsp;The process returns an [`FreedomResult<PaymentResponse>`](#error-handling-and-results) object, which can be either:
- **Success**: Contains a `PaymentResponse` object.
- **Error**: Specifies the type of error that occurred.

```swift
freedomApi.makeCancelPayment(Int64(123456)) { (result: FreedomResult<PaymentResponse>) in
    switch result {
    case .success:
        // Cancellation attempt completed successfully.
    case .error:
        // Failed to cancel the payment.
    }
}
```

## Make Revoke Payment
&emsp;The `makeRevokePayment` method allows you to process a full or partial refund for a completed payment.

&emsp;This method takes these parameters:

| Parameter   | Type                                       | Description                                                                                                                              | Constraints/Notes                                                                                                      |
|-------------|--------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| `paymentId` | `Int64`                                     | Unique identifier of the payment you want to revoke (refund).                                                                            |                                                                                                                        |
| `amount`    | `Decimal?`                                   | Amount of funds to return. If `nil`, the full amount of the original debited payment will be refunded.                                  | Optional. Defaults to nil. Must be between `0.01` and `99999999.00` if provided. Cannot exceed the authorized amount. |
| `onResult`  | `@escaping (FreedomResult<PaymentResponse>) -> Void` | Callback function that will be invoked with the result of the refund process. See [`PaymentResponse`](#paymentresponse-structure) model. |                                                                                                                        |

&emsp;The process returns an [`FreedomResult<PaymentResponse>`](#error-handling-and-results) object, which can be either:
- **Success**: Contains a `PaymentResponse` object.
- **Error**: Specifies the type of error that occurred.

```swift
freedomApi.makeRevokePayment(Int64(123456)) { (result: FreedomResult<PaymentResponse>) in
    switch result {
    case .success:
        // Refund process completed successfully.
    case .error:
        // Failed to process the refund.
    }
}
```
## Add New Card
&emsp;The `addNewCard` method facilitates the secure tokenization and addition of a new payment card to a customer's profile. This process allows future payments to be made without requiring the customer to re-enter their card details.

> **WARNING**
> This method requires that a `PaymentView` has been set using [`freedomApi.setPaymentView()`](#integrating-the-paymentview-optional) prior to calling it, as it will display a web-based form within the `PaymentView` for the customer to securely enter their card details.

&emsp;This method takes these parameters:

| Parameter  | Type                                       | Description                                                                                                                                         | Constraints/Notes                                                        |
|------------|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `userId`   | `String`                                   | Identifier for a user to associate this new card with.                                                                                              | Must contain 1-50 characters. Also, must match regex `^[a-zA-Z0-9_-]+$`. |
| `orderId`  | `String?`                                  | Unique identifier for this order within your system.                                                                                                | Optional. Defaults to null. Must contain 1-50 characters.                |
| `onResult` | `(FreedomResult<PaymentResponse>) -> Void` | Callback function that will be invoked upon the completion of the card addition process. See [`PaymentResponse`](#paymentresponse-structure) model. |                                                                          |

&emsp;The process returns an [`FreedomResult<PaymentResponse>`](#error-handling-and-results) object, which can be either:
- **Success**: Contains a `PaymentResponse` object.
- **Error**: Specifies the type of error that occurred.


```swift
freedomApi.addNewCard(
    userId: "user12345",
    orderId: "CARDADD-SESSION-XYZ" // Optional tracking ID
) { (result: Freedomresult<PaymentResponse) in
    switch result {
        case .success:
            // Card addition process completed successfully.
        case .error:
    }
}
```

## Get Added Cards
&emsp;The `getAddedCards` method allows you to retrieve a array of payment cards that have been previously added and tokenized for a specific user. 

&emsp;This method takes these parameters:

| Parameter  | Type                                  | Description                                                                                                                      | Constraints/Notes                                                        |
|------------|---------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `userId`   | `String`                              | Identifier of the user whose added cards you wish to retrieve.                                                                   | Must contain 1-50 characters. Also, must match regex `^[a-zA-Z0-9_-]+$`. |
| `onResult`  | `@escaping (FreedomResult<[Card]>) -> Void` | Callback function that will be invoked upon the completion of the card retrieval operation. See [`Card`](#card-structure) model. |                                                                          |

&emsp;The process returns an [`FreedomResult<[Card]>`](#error-handling-and-results) object, which can be either:
- **success**: Contains an array of `Card` objects.
- **error**: Specifies the type of error that occurred.

```swift
freedomApi.getAddedCards("user12345") { (result: FreedomResult<[Card]>) in
    switch result {
    case .success:
        // List of added cards retrieved successfully.
    case .error:
        // Failed to retrieve added cards.
    }
}
```

## Remove Added Card
&emsp;`removeAddedCard` method allows you to securely remove a previously tokenized payment card associated with a specific user.

&emsp;This method takes these parameters:

| Parameter   | Type                                   | Description                                                                                                                                                                      | Constraints/Notes                                                        |
|-------------|----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `userId`    | `String`                               | Identifier of the user from whom the card will be removed.                                                                                                                       | Must contain 1-50 characters. Also, must match regex `^[a-zA-Z0-9_-]+$`. |
| `cardToken` | `String`                               | Unique token of the card to be removed. This token is obtained when the card is added (via [`addNewCard`](#add-new-card) or retrieved using [`getAddedCards`](#get-added-cards). | Must contain 1 or more characters.                                       |
| `onResult`  | `@escaping (FreedomResult<RemovedCard>) -> Void` | Callback function that will be invoked upon the completion of the card removal operation. See [`RemovedCard`](#removedcard-structure) model.                                     |                                                                          |

&emsp;The process returns an [`FreedomResult<RemovedCard>`](#error-handling-and-results) object, which can be either:
- **success**: Contains a `RemovedCard` object.
- **error**: Specifies the type of error that occurred.

```swift
freedomApi.removeAddedCard(
    userId: "user12345",
    cardToken: "card-token-123abc"
) { (result: FreedomResult<RemovedCard) in
    switch result {
    case .success:
        // Card removal process completed successfully.
    case .error:
        // Failed to remove the card.
    }
}
```

## Create Card Payment
&emsp;The `createCardPayment` method is used to initiate a payment using a previously tokenized (saved) card.

:::info[]
A payment initiated with `createCardPayment` is a two-stage process. After successfully calling this method, the created payment must be confirmed using either the [`confirmCardPayment`](#confirm-card-payment) or [`confirmDirectPayment`](#confirm-direct-payment) method to finalize the transaction.
:::

&emsp;This method takes these parameters:

| Parameter        | Type                                       | Description                                                                                                                                                     |
|------------------|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `paymentRequest` | `TokenizedPaymentRequest`                  | Essential details required to initiate a new payment with previously tokenized card. See [`TokenizedPaymentRequest`](#tokenizedpaymentrequest-structure) model. |
| `onResult`       | `(FreedomResult<PaymentResponse>) -> Void` | Callback function that will be invoked with the result of the payment initiation. See [`PaymentResponse`](#paymentresponse-structure) model.                    |

&emsp;The process returns an [`FreedomResult<PaymentResponse>`](#error-handling-and-results) object, which can be either:
- **Success**: Contains a `PaymentResponse` object.
- **Error**: Specifies the type of error that occurred.

```swift
let paymentRequest = TokenizedPaymentRequest(
    amount: someAmount,
    currency: Currency.KZT,
    description: "Monthly Subscription",
    cardToken: "card-token-123abc",
    userId: "user12345",
    orderId: "SUB-2025-001",
    extraParams: nil
)
freedomApi.createCardPayment(paymentRequest) { (result: FreedomResult<PaymentResponse>) in
    switch result {
        case .success:
            // Payment initiation completed successfully.
        case .error:
            // Failed to initiate payment with SDK.
    }
}
```

## Confirm Card Payment
&emsp;The `confirmCardPayment` method is used to finalize a payment that was previously initiated with a saved card using [`createCardPayment`](#create-card-payment).

:::warning[]
This method requires that a `PaymentView` has been set using [`freedomApi.setPaymentView()`](#integrating-the-paymentview-optional) prior to calling it, as it will display a web-based form within the `PaymentView` for CVC entry and 3DS authentication.
:::

&emsp;This method takes these parameters:

| Parameter   | Type                                       | Description                                                                                                                                   |
|-------------|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| `paymentId` | `Int64`                                     | Unique identifier of the payment to confirm. This paymentId is obtained from the [`createCardPayment`](#create-card-payment) method.          |
| `onResult`  | `(FreedomResult<PaymentResponse>) -> Void` | Callback function that will be invoked upon the completion of the payment process. See [`PaymentResponse`](#paymentresponse-structure) model. |                                                                          |

&emsp;The process returns an [`FreedomResult<PaymentResponse>`](#error-handling-and-results) object, which can be either:
- **Success**: Contains a `PaymentResponse` object.
- **Error**: Specifies the type of error that occurred.

```swift
freedomApi.confirmCardPayment(123456) { (result: FreedomResult<PaymentResponse>) in
    switch result {
        case .success:
            // Card payment successfully confirmed.
        case .error:
            // Failed to confirm payment.
    }
}
```

## Confirm Direct Payment
&emsp;The `confirmDirectPayment` method is used to finalize a payment that was previously initiated with a saved card using [`createCardPayment`](#create-card-payment).

&emsp;This method takes these parameters:

| Parameter   | Type                                       | Description                                                                                                                               |
|-------------|--------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `paymentId` | `Int64`                                     | Unique identifier of the payment to confirm. This paymentId is obtained from the [`createCardPayment`](#create-card-payment) method.      |
| `onResult`  | `(FreedomResult<PaymentResponse>) -> Void` | Callback function that will be invoked with the result of the payment process. See [`PaymentResponse`](#paymentresponse-structure) model. |

&emsp;The process returns an [`FreedomResult<PaymentResponse>`](#error-handling-and-results) object, which can be either:
- **Success**: Contains a `PaymentResponse` object.
- **Error**: Specifies the type of error that occurred.

```kotlin
freedomApi.confirmDirectPayment(paymentId) { (result: FreedomResult<PaymentResponse>) in
    switch (result) {
        case .success:
            // Direct payment successfully confirmed.
        case .error:
            // Failed to confirm direct payment.
    }
}
```
---
# Apple Pay Integration

These methods facilitate integrating Apple Pay into your application through the SDK. Our SDK's methods bridge your Apple Pay implementation with our payment gateway, handling the transaction processing.

## 1. Apple Developer Account Setup

Before you write any code, you must configure your Apple Developer account to handle Apple Pay transactions.

1. Log in to your **Apple Developer account**.

2. Navigate to **Certificates, Identifiers & Profiles > Identifiers**.

3. Click the "+" button to add a new identifier.

4. Select Merchant IDs and click Continue.

5. Provide a descriptive name and **a unique identifier string** (e.g., `merchant.com.yourdomain.appname`).

6. Click **Register**.

## 2. Create a Payment Processing Certificate

This certificate is used to encrypt payment data, ensuring that sensitive customer information is transmitted securely.

1. Within the **Merchant ID** you just created, locate the **Apple Pay Payment Processing Certificate** section and click **Create Certificate**.

2. You will be prompted to create a Certificate Signing Request (CSR) from your Mac:
   - Open **Keychain Access**
   - Go to **Keychain Access > Certificate Assistant > Request a Certificate From a Certificate Authority**.

3. Enter your email address and a common name for the key. Select **Saved to disk** and click **Continue**.

4. Back in the Developer portal, upload the generated CSR file.

5. Apple will then issue a payment processing certificate. Download it and add it to your Keychain.

## 3. Enable Apple Pay in Your App ID

You need to associate your Merchant ID with your application's App ID.

1. Go to **Certificates, Identifiers & Profiles > Identifiers** and select your app's App ID.

2. Under the **Capabilities** tab, find **Apple Pay** and check the box to enable it.

3. Select the Merchant ID you created earlier to link it to your app.

## 4. Xcode setup

1.  **Add the Apple Pay Capability to your Xcode Project:** In your project settings, go to the **Signing & Capabilities** tab and click the **"+"** button to add the **Apple Pay** capability. Select the Merchant ID you created.
2. **Add** `PassKit` **to your code:**
```Swift
import PassKit
```
3.  **Display the Apple Pay Button:** Use `PKPaymentButton` to display the official Apple Pay button: 
```Swift
 override func viewDidLoad() {
    super.viewDidLoad()
    
    let applePayButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
    
    applePayButton.addTarget(self, action: #selector(applePayButtonTapped), for: .touchUpInside)
    
    applePayButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(applePayButton)
    
    NSLayoutConstraint.activate([
        applePayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        applePayButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        applePayButton.widthAnchor.constraint(equalToConstant: 200), 
        applePayButton.heightAnchor.constraint(equalToConstant: 50)  
    ])
}

@objc func applePayButtonTapped() {}
```
4.  **Create a Payment Request:** When the user taps the button, create a `PKPaymentRequest`. This object will contain details about the payment, such as:
    - `merchantIdentifier`: Your Merchant ID.
    - `countryCode`: The two-letter country code.
    - `currencyCode`: The three-letter currency code.
    - `supportedNetworks`: The payment networks you support (e.g., Visa, Mastercard).
    - `merchantCapabilities`: The 3D Secure capabilities your app supports.
    - `paymentSummaryItems`: An array of `PKPaymentSummaryItem` objects that detail the cost of the items, shipping, and tax.
```Swift
func createPaymentRequest() -> PKPaymentRequest {
    let paymentRequest = PKPaymentRequest()
    paymentRequest.merchantIdentifier = "merchant.com.yourdomain.appname"
    paymentRequest.countryCode = "US" 
    paymentRequest.currencyCode = "USD" 
    paymentRequest.supportedNetworks = [.visa, .masterCard]
    paymentRequest.merchantCapabilities = .threeDSecure
    let item = PKPaymentSummaryItem(label: "T-Shirt", amount: NSDecimalNumber(string: "20.00"))
    let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "2.19"))
    let shipping = PKPaymentSummaryItem(label: "Shipping", amount: NSDecimalNumber(string: "4.99"))
    let total = PKPaymentSummaryItem(label: "Your Company Name", amount: NSDecimalNumber(string: "27.18"))
    
    paymentRequest.paymentSummaryItems = [item, tax, shipping, total]
    return paymentRequest
}
```
5.  **Present the Payment Sheet:** Use a   `PKPaymentAuthorizationViewController` to present the payment sheet to the user. Conform to `PKPaymentAuthorizationViewControllerDelegate` delegate to handle results.
```Swift
@objc func applePayButtonTapped() {
    let paymentRequest = createPaymentRequest()
    guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
        print("Error: Unable to present Apple Pay sheet.")
        return
    }
    paymentVC.delegate = self
    self.present(paymentVC, animated: true, completion: nil)
}
```
6.  **Handle the Payment Token:** Upon successful authorization by the user (via Face ID, Touch ID, or passcode), the `PKPaymentAuthorizationViewControllerDelegate` will receive a `PKPayment` object containing an encrypted payment token.
```Swift
extension PaymentViewController: PKPaymentAuthorizationViewControllerDelegate {
    // Called when user authorizes payment
    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    // Called when Apple Pay sheet is dismissed
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
```
## 5. Creating an Apple Pay Transaction
&emsp;The `createApplePayment` method is the first step in processing a payment via Apple Pay using the SDK. This method initiates a Apple Pay payment.

&emsp;This method takes these parameters:

| Parameter        | Type                                     | Description                                                                                                                                     |
|------------------|------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| `paymentRequest` | `StandardPaymentRequest`                 | Essential details required to initiate a new payment. See [`StandardPaymentRequest`](#standardpaymentrequest-structure) model.                  |
| `onResult`       | `@escaping (FreedomResult<ApplePayment>) -> Void` | Callback function that will be invoked with the result of the Apple payment initiation. See [`ApplePayment`](#applepayment-structure) model. |

&emsp;The process returns an [`FreedomResult<ApplePayment>`](#error-handling-and-results) object, which can be either:
- **Success**: Contains a `ApplePayment` object.
- **Error**: Specifies the type of error that occurred.

```Swift
func createApplePayment() {
    let standardPaymentRequest = StandardPaymentRequest(
        amount: Decimal(10.0),
        currency: .KZT,
        description: "some description",
        userId: "123",
        orderId: "456",
        extraParams: nil)
    freedomApi.createApplePayment(
        paymentRequest: standardPaymentRequest
    ) { result in
        switch result {
        case .success(let applePayment):
            self.paymentId = applePayment.paymentId
        case .error(let error):
            print("Apple Payment failed: \(error)")
        }
    }
}
```
## 6. Confirming an Apple Pay Transaction
&emsp;The `confirmApplePayment` method is the final step in processing a Apple Pay transaction with the SDK. After you have successfully obtained the Apple Pay token from the **PassKit** (e.g., from `PKPayment` from `PKPaymentAuthorizationController`), you pass this token along with the `paymentId` received from [`createApplePayment`](#5-creating-an-apple-pay-transaction) to this method to finalize the transaction.

&emsp;This method takes these parameters:

| Parameter  | Type                                       | Description                                                                                                                                                           |
|------------|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `paymentId`  | `String`                            | Payment previously obtained from a successful call to [`createApplePayment`](#5-creating-an-apple-pay-transaction). See [`ApplePayment`](#applepayment-structure) model. |
| `tokenData`    | `Data`                                   | Encrypted payment token received from the **PassKit**. This token contains the sensitive card data securely.                                                       |
| `onResult` | `@escaping (FreedomResult<PaymentResponse>) -> Void` | Callback function that will be invoked with the final result of the Apple Pay transaction confirmation. See [`PaymentResponse`](#paymentresponse-structure) model.   |

&emsp;The process returns an [`FreedomResult<PaymentResponse>`](#error-handling-and-results) object, which can be either:
- **.success**: Contains a `PaymentResponse` object.
- **.error**: Specifies the type of error that occurred.

```Swift
func paymentAuthorizationController(
    _ controller: PKPaymentAuthorizationController,
    didAuthorizePayment payment: PKPayment,
    handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
) {
    freedomApi.confirmApplePayment(
        paymentId: paymentId,
        tokenData: payment.token.paymentData
    ) { result in
        switch result {
        case .success(let paymentResponse):
            print("Payment ID: \(paymentResponse.paymentId)")
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        case .error(let error):
            print("Apple Payment Confirmation failed: \(error)")
            completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
        }
    }
}
```
---
# Error Handling and Results
&emsp;All asynchronous operations in the SDK return their outcome encapsulated within a `FreedomResult` sealed interface.

&emsp;The `FreedomResult` interface has two primary states: `success` for successful completion and `error` for any failures.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/freedompay-global/merchant-sdk-android/refs/heads/main/documentation-assets/FreedomResult(Dark).png"">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/freedompay-global/merchant-sdk-android/refs/heads/main/documentation-assets/FreedomResult(Light).png"">
  <img alt="Mind Map of Freedom Result" src="https://raw.githubusercontent.com/freedompay-global/merchant-sdk-android/refs/heads/main/documentation-assets/FreedomResult(Light).png" width="100%">
</picture>


## `FreedomResult.success<T>`
- Represents a successful completion of the SDK operation.
- `value: T`: Holds the actual result of the operation. The type `T` will vary depending on the method called (e.g., `Payment`, `[Card]`, `ConfirmPaymentStatus`).

## `FreedomResult.error`
&emsp;The `error` type is a sealed interface itself, providing distinct types of errors for more precise handling.

### 1. `ValidationError`
&emsp;Indicates that one or more inputs provided to the SDK method were invalid or did not meet specified constraints (e.g., `amount` out of range, `userId` format mismatch).
- `errors: List<ValidationErrorType>`: A list detailing all specific validation errors that occurred. For a comprehensive list of types, refer to the [`ValidationErrorType`](#validationerrortype-structure) table.

### 2. `PaymentInitializationFailed`
&emsp;Indicates a general failure during the initial setup or preparation of a payment, before it reaches the transaction processing stage.

### 3. `Transaction`
&emsp;Represents an error encountered by the payment gateway during the transaction processing (e.g., card declines, insufficient funds, 3D Secure failures).

- `errorCode: Int`: A numerical code representing a specific transaction error. You can find an up-to-date reference of error codes [here](https://customer.freedompay.kz/dev/error?lang=en).
- `errorDescription: String?`: A human-readable description of the transaction error, if available.

### 4. `NetworkError`
&emsp;Represents errors related to network connectivity or API responses. This is a sealed interface with several specific network error types:

- `Protocol`: Indicates an issue with the communication protocol or an unexpected response from the API.
  - `code: Int`: An HTTP status code or an internal protocol error code.
  - `body: String?`: The raw response body or a human-readable description of the protocol error, if available.

- `Connectivity`: Indicates problems related to the device's network connection. This sealed interface includes the following specific errors:
  - `ConnectionFailed`: The network connection could not be established.
  - `ConnectionTimeout`: The network request timed out.
  - `Integrity`: An issue with the integrity of the network connection (e.g., SSL/TLS certificate issues).
- `Unknown`: A general network error occurred that does not fall into more specific categories.

### 5. `InfrastructureError`
&emsp;Represents errors related to the internal state, configuration, or core components of the SDK. This is a sealed interface with several specific infrastructure error types:

- `SdkNotConfigured`: The SDK methods were called before `freedomApi.setConfiguration()` was successfully invoked.
- `SdkCleared`: The SDK methods were called after the SDK's internal state was cleared, preventing further operations.
- `ParsingError`: An error occurred while parsing data (e.g., a response from the server could not be deserialized).
- `WebView`: Errors specifically related to the internal `WebView` component used for displaying payment pages or frames. This sealed interface includes the following specific errors:
  - `PaymentViewIsNotInitialized`: A method requiring `PaymentView` was called, but `freedomApi.setPaymentView()` has not been called or the view is not ready.
  - `Failed`: A general error occurred during the payment process within the `WebView`, without a more specific cause.

---

# Data Structures
&emsp;This section provides detailed descriptions of the structs and enums used throughout the SDK, particularly in the results of various method calls.

## `StandardPaymentRequest` Structure
&emsp;The `StandardPaymentRequest` data class encapsulates the essential details required to initiate a new payment transaction.

| Parameter     | Type                               | Description                                                                                | Constraints/Notes                                                                                    |
|---------------|------------------------------------|--------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| `amount`      | `Decimal`                            | Total amount of the payment.                                                               | Must be between `0.01` and `99999999.00`.                                                            |
| `currency`    | `Currency?`                        | Currency of the payment. See [`Currency`](#currency-structure) enum for available options. | Optional. Defaults to null.                                                                          |
| `description` | `String`                           | Description of the payment.                                                                |                                                                                                      |
| `userId`      | `String?`                          | Identifier for the user making the payment.                                                | Optional. Defaults to null. Must contain 1-50 characters. Also, must match regex `^[a-zA-Z0-9_-]+$`. |
| `orderId`     | `String?`                          | Unique identifier for this payment order within your system.                               | Optional. Defaults to null. Must contain 1-50 characters.                                            |
| `extraParams` | `[String: String]?`         | Optional map of additional key-value pairs to pass custom data with the payment.           | Optional. Defaults to null.                                                                          |

## `TokenizedPaymentRequest` Structure
&emsp;The `TokenizedPaymentRequest` data class is used to create payments with a previously saved and tokenized card, requiring the card's unique token along with standard payment details.

| Parameter     | Type                                                 | Description                                                                                                                                                                    | Constraints/Notes                                                        |
|---------------|------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `amount`      | `Decimal`                                              | Total amount of the payment to be charged to the saved card..                                                                                                                  | Must be between `0.01` and `99999999.00`.                                |
| `currency`    | `Currency?`                                          | Currency of the payment. See [`Currency`](#currency-structure) enum for available options.                                                                                     | Optional. Defaults to null.                                              |
| `description` | `String`                                             | Description of the payment.                                                                                                                                                    |                                                                          |
| `cardToken`   | `String`                                             | Unique token representing the saved card that will be used for this payment. This token is obtained from [`addNewCard`](#add-new-card) or [`getAddedCards`](#get-added-cards). | Must contain 1 or more characters.                                       |
| `userId`      | `String`                                             | Identifier for the user making the payment.                                                                                                                                    | Must contain 1-50 characters. Also, must match regex `^[a-zA-Z0-9_-]+$`. |
| `orderId`     | `String`                                             | Unique identifier for this payment order within your system.                                                                                                                   | Must contain 1-50 characters.                                            |
| `extraParams` | `[String: String]?`                           | Optional map of additional key-value pairs to pass custom data with the payment.                                                                                               | Optional. Defaults to null.                                              |


## `PaymentResponse` Structure
&emsp;The `PaymentResponse` struct represents a successful payment transaction.

| Property     | Type                      | Description                                     |
|--------------|---------------------------|-------------------------------------------------|
| `status`     | `PaymentResponse.Status`  | Status of the operation.                        |
| `paymentId`  | `Int64`                   | Unique identifier for this payment.             |
| `merchantId` | `String`                  | ID of the merchant associated with the payment. |
| `orderId`    | `String?`                 | Order ID provided during payment creation.      |

### `PaymentResponse.Status`

| Property                                           | Type        | Description                                                                                             |
|----------------------------------------------------|-------------|---------------------------------------------------------------------------------------------------------|
| `New`                                              | enum case | Payment has been created but no processing has started yet.                                             |
| `Waiting`                                          | enum caset | Payment is pending further action or confirmation.                                                      |
| `Processing`                                       | enum case | Payment is actively being handled by the system or provider.                                            |
| `Incomplete`                                       | enum case | Indicates that the payment was initiated but did not reach a final state within the allotted time.      |
| `Success`                                          | enum case | Payment was completed successfully and funds have been confirmed.                                       |
| `Unknown(let value: String)`                       | enum case with associated values  | Status value is not recognized by the SDK, possibly due to a new or unexpected status from the backend. |
| `Error(let code: String, let description: String)` | enum case with associated values | Payment failed, with an error code and description available for diagnosis.                             |

```Swift
switch paymentResponse.status {
case .new:
    // Payment has been created but no processing has started yet.
case .waiting:
    // Payment is pending further action or confirmation.
case .processing:
    // Payment is actively being handled by the system or provider.
case .incomplete:
    // Indicates that the payment was initiated but did not reach a final state within the allotted time.
case .success:
    // Payment was completed successfully and funds have been confirmed.
case .error(let code, let description):
    // Payment failed, with an error code
case .unknown(_):
    // Status value is not recognized by the SDK, possibly due to a new or unexpected status from the backend.
}
```

## `Status` Structure
&emsp;Provides comprehensive details about the current state of a payment.

| Property            | Type                    | Description                                                             |
|---------------------|-------------------------|-------------------------------------------------------------------------|
| `status`            | `String`                | Status of the operation.                                                |
| `paymentId`         | `Int64`                  | Unique identifier for this payment.                                     |
| `orderId`           | `String?`               | Order ID provided during payment creation.                              |
| `currency`          | `String`                | Currency code of the payment.                                           |
| `amount`            | `Decimal`                 | Original amount of the payment.                                         |
| `canReject`         | `Bool?`              | Indicates if the payment can still be cancelled.                        |
| `paymentMethod`     | `String?`               | Method used for payment.                                                |
| `paymentStatus`     | `String?`               | Current status of the payment.                                          |
| `clearingAmount`    | `Decimal?`                | Total amount that has been cleared (captured) for this payment.         |
| `revokedAmount`     | `Decimal?`                | Total amount that has been cancelled for this payment.                  |
| `refundAmount`      | `Decimal?`                | Total amount that has been refunded.                                    |
| `cardName`          | `String?`               | Name on the card used for the payment.                                  |
| `cardPan`           | `String?`               | Masked Primary Account Number (PAN) of the card.                        |
| `revokedPayments`   | `[RevokedPayment]?` | List of individual cancelled transactions associated with this payment. |
| `refundPayments`    | `[RefundPayment]?`  | List of individual refund transactions associated with this payment.    |
| `reference`         | `Int64?`                 | System-generated reference number for the payment.                      |
| `captured`          | `Bool?`              | Indicates if the funds for the payment have been captured.              |
| `createDate`        | `String`                | Date and time when the payment was created.                             |
| `authCode`          | `Int?`                  | Authorization code for the payment.                                     |
| `failureCode`       | `String?`               | Code indicating why the payment failed                                  |
| `failureDescription`| `String?`             | Human-readable reason for the payment failure                           |
| `lastTransactionInfo`| `LastTransactionInfo?`  | Details of the most recent transaction associated with this payment. |

## `RevokedPayment` Structure
&emsp;Details of an individual cancelled transaction.

| Property        | Type      | Description                      |
|-----------------|-----------|----------------------------------|
| `paymentId`     | `Int64?`   | ID of the cancelled payment.     |
| `paymentStatus` | `String?` | Status of the cancelled payment. |

## `RefundPayment` Structure
&emsp;Details of an individual refund transaction.

| Property        | Type      | Description                                       |
|-----------------|-----------|---------------------------------------------------|
| `paymentId`     | `Int64?`   | ID of the refund payment.                         |
| `paymentStatus` | `String?` | Status of the refund payment.                     |
| `amount`        | `Decimal?`  | Amount that was refunded in this transaction.     |
| `paymentDate`    | `String?` | Date and time of the refund.                      |
| `reference`     | `Int64?`   | System-generated reference number for the refund. |

## `LastTransactionInfo` Structure
&emsp;Details of the most recent transaction associated with this payment

| Property             | Type      | Description                                        |
|----------------------|-----------|----------------------------------------------------|
| `status`             | `String`  | Status of the last transaction.                    |
| `failureCode`        | `String?` | Code indicating why the transaction failed.        |
| `failureDescription` | `String?` | Human-readable reason for the transaction failure. |

## `ClearingStatus` Structure
&emsp;Represents the status of a clearing operation.

| Type                         | Description                                                                                               |
|------------------------------|-----------------------------------------------------------------------------------------------------------|
| `success(let amount: Decimal)` | Indicates that the clearing operation was successful. `amount`: The amount that was successfully cleared. |
| `exceedsPaymentAmount`       | Indicates that the requested clearing amount exceeded the originally authorized payment amount.           |
| `failed`                     | Indicates that the clearing operation failed.                                                             |

## `Card` Structure
&emsp;Represents a single tokenized payment card associated with a user.

| Property             | Type      | Description                                            |
|----------------------|-----------|--------------------------------------------------------|
| `status`             | `String?` | Status of the operation.                               |
| `merchantId`         | `String?` | ID of the merchant.                                    |
| `recurringProfileId` | `String?` | ID assigned to a user's recurring payment profile      |
| `cardToken`          | `String?` | Token used to reference this card for future payments. |
| `cardHash`           | `String?` | Masked Primary Account Number (PAN) of the card.       |
| `createdAt`          | `String?` | Date and time when the card was added.                 |

## `RemovedCard` Structure
&emsp;Represents the outcome of an attempt to remove a stored card.

| Property     | Type      | Description                                      |
|--------------|-----------|--------------------------------------------------|
| `status`     | `String?` | Status of the operation.                         |
| `merchantId` | `String?` | ID of the merchant.                              |
| `cardHash`   | `String?` | Masked Primary Account Number (PAN) of the card. |
| `deletedAt`  | `String?` | Date and time when the card was deleted.         |

## `ValidationErrorType` Structure

| Enum Constant            | Description                                                                |
|--------------------------|----------------------------------------------------------------------------|
| `INVALID_MERCHANT_ID`    | Provided merchant ID is invalid or missing.                                |
| `INVALID_SECRET_KEY`     | Provided secret key is invalid or missing.                                 |
| `INVALID_PAYMENT_AMOUNT` | Payment amount is outside the allowed range (`0.01` - `99999999.00`).      |
| `INVALID_ORDER_ID`       | Provided order ID does not meet the specified length constraints.          |
| `INVALID_USER_ID`        | Provided user ID does not meet the specified format or length constraints. |
| `INVALID_CARD_TOKEN`     | Provided card token does not meet the specified length constraints.        |

## `ApplePayment` Structure
&emsp;The response received after initiating a Apple Pay transaction.

| Property    | Type     | Description                                                 |
|-------------|----------|-------------------------------------------------------------|
| `paymentId` | `String` | Unique identifier for the initiated Apple Pay transaction. |

## `Currency` Structure
&emsp;The `Currency` enum defines all supported currency codes that can be used when specifying payment amounts.

| Enum Constant | Description                  |
|---------------|------------------------------|
| `KZT`         | Kazakhstani tenge.           |
| `RUB`         | Russian ruble.               |
| `USD`         | US dollar.                   |
| `UZS`         | Uzbek sum.                   |
| `KGS`         | Kyrgyzstani som.             |
| `EUR`         | Euro.                        |
| `HKD`         | Hong Kong dollar.            |
| `GBP`         | British pound.               |
| `AED`         | United Arab Emirates dirham. |
| `CNY`         | Chinese yuan.                |
| `KRW`         | South Korean won.            |
| `INR`         | Indian rupee.                |
| `THB`         | Thai baht.                   |
| `UAH`         | Ukrainian hryvnia.           |
| `AMD`         | Armenian dram.               |
| `BYN`         | Belarusian ruble.            |
| `PLN`         | Polish złoty.                |
| `CZK`         | Czech koruna.                |
| `AZN`         | Azerbaijani manat.           |
| `GEL`         | Georgian lari.               |
| `TJS`         | Tajikistani somoni.          |
| `CAD`         | Canadian dollar.             |
| `MDL`         | Moldovan leu.                |
| `TRY`         | Turkish lira.                |

---
# Support
If you have questions or need help, feel free to reach out! 👋
**Email**: support@freedompay.kz
