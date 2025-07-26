## Payment SDK (iOS, Swift)

&emsp;The Payment SDK is a library that simplifies interaction with the Freedom Pay API. Supports iOS 15 and above.

---
### Table of Contents
- [Installation Instructions](#installation-instructions)
  - [SDK integration](#sdk-integration)
    - [Initialize](#initialize)
      - [Table: `Region`](#table-region)
  - [SDK Configuration](#sdk-configuration)
    - [`SdkConfiguration` Overview](#sdkconfiguration-overview)
      - [Table: `UserConfiguration`](#table-userconfiguration)
      - [Table: `OperationalConfiguration`](#table-operationalconfiguration)
      - [Table: `Language`](#table-language)
      - [Table: `HttpMethod`](#table-httpmethod)
    - [Applying the Configuration](#applying-the-configuration)
  - [Working with the SDK](#working-with-the-sdk)
    - [Get Payment status](#get-payment-status)
    - [Make Clearing Payment](#make-clearing-payment)
    - [Make Cancel Payment](#make-cancel-payment)
    - [Make Revoke Payment](#make-revoke-payment)
    - [Get Added Cards](#get-added-cards)
    - [Remove Added Card](#remove-added-card)
  - [Error Handling and Results](#error-handling-and-results)
    - [`FreedomResult.success<T>`](#freedomresultsuccesst)
    - [`FreedomResult.error`](#freedomresulterror)
    - [Table `ValidationErrorType`](#table-validationerrortype)
  - [Data Structures](#data-structures)
    - [`PaymentResponse` Structure](#paymentresponse-structure)
    - [`Status` Structure](#status-structure)
    - [`RevokedPayment` Structure](#revokedpayment-structure)
    - [`RefundPayment` Structure](#refundpayment-structure)
    - [`ClearingStatus` Structure](#clearingstatus-structure)
    - [`Card` Structure](#card-structure)
    - [`RemovedCard` Structure](#removedcard-structure)
    - [`Currency` Structure](#currency-structure)
  - [Support](#support)
---

### Getting Started

&emsp;Before you begin integrating the **Freedom Payment SDK** into your iOS app, ensure you have the following:
- An iOS app project with a minimum deployment of 15.
- The **Freedom Payment SDK** xcframework file

---

## Installation Instructions

#### Add the SDK to your Podfile

```ruby
platform :ios, '15.0'
use_frameworks! :linkage => :static

target 'YourAppTarget' do
  pod 'FreedomPaymentSdk',
      git: 'https://github.com/freedompay-global/merchant-sdk-ios.git',
      tag: '1.0.0'                       # use the latest released tag
end
```

#### Install the pod and open the workspace
```bash
pod install
open YourApp.xcworkspace
```

#### Disable Xcode’s user-script sandboxing (Xcode 15 +)
Target → Build Settings → Build Options →
ENABLE_USER_SCRIPT_SANDBOXING = NO

#### Import and use the SDK

```swift
import FreedomPaymentSdk
```

---

### SDK integration

#### Initialize

&emsp;To initialize the **Freedom Payment SDK**, call the `create` method of the `FreedomAPI` class. This method requires *three parameters*:
- Your merchant ID
- Your merchant secret key
- The payment region

```swift
let merchantId = "123456"
let secretKey = "123456789ABCDEF"
let region = Region.kZ
let freedomApi = FreedomAPI.create(merchantId: merchantId, secretKey: secretKey, region: region)
```
##### Table: `Region`
| Enum Constant | Description        |
|---------------|--------------------|
| `kz`          | Kazakhstan region. |
| `ru`          | Russia region.     |
| `uz`          | Uzbekistan region. |
| `kg`          | Kyrgyzstan region. |

---
### SDK Configuration

&emsp;The SDK's behavior is controlled through its configuration, which you manage using the `SdkConfiguration` struct. This struct acts as a central container, encapsulating two key components: `UserConfiguration` for customer-specific settings and `OperationalConfiguration` for general operational parameters.

#### `SdkConfiguration` Overview

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

##### Table: `UserConfiguration`
&emsp;This struct holds customer-specific details.

| Property           | Type      | Description                                                                                                                        | Default Value |
|--------------------|-----------|------------------------------------------------------------------------------------------------------------------------------------|---------------|
| `userPhone`        | `String?` | Customer's phone number. If provided, it will be displayed on the payment page. If `nil`, the user will be prompted to enter it.  | `nil`        |
| `userContactEmail` | `String?` | Customer's contact email.                                                                                                          | `nil`        |
| `userEmail`        | `String?` | Customer's email address. If provided, it will be displayed on the payment page. If `nil`, the user will be prompted to enter it. | `nil`        |

##### Table: `OperationalConfiguration`
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

##### Table: `Language`
| Enum Constant | Description                      |
|---------------|----------------------------------|
| `kz`          | SDK uses the `Kazakh` language.  |
| `ru`          | SDK uses the `Russian` language. |
| `en`          | SDK uses the `English` language. |

##### Table: `HttpMethod`
| Enum Constant | Description                      |
|---------------|----------------------------------|
| `GET`         | SDK uses the HTTP `GET` method.  |
| `POST`        | SDK uses the HTTP `POST` method. |

#### Applying the Configuration
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
### Working with the SDK

&emsp;This section details the primary methods available in the SDK for managing payments within your application.

#### Get Payment status
&emsp;To retrieve the current status of a previously initiated payment, use the `getPaymentStatus` method.

&emsp;This method takes these parameters:

| Parameter   | Type                              | Description                                                                                                            | Constraints/Notes |
|-------------|-----------------------------------|------------------------------------------------------------------------------------------------------------------------|-------------------|
| `paymentId` | `Int64`                            | Unique identifier of the payment you want to check.                                                                    |                   |
| `onResult`  | `@escaping (FreedomResult<Status>) -> Void` | Callback function that will be invoked with the result of the payment status. See [`Status`](#status-structure) model. |                   |

&emsp;The process returns an [`FreedomResult<Status>`](#error-handling-and-results) object, which can be either:

- **success**: Contains a `Status` object.
- **error**: Specifies the type of error that occurred.

```swift
freedomApi.getPaymentStatus(paymentId: Int64(123456)) { (result: FreedomResult<Status>) in
    switch result {
    case .success(let status):
        // Payment status retrieved successfully.
        break
    case .error(let error):
        // Failed to retrieve payment status.
        break
    }
}
```

#### Make Clearing Payment
> **NOTE**
> This method is specifically designed for merchants who have **auto-clearing disabled** in their SDK configuration. Auto-clearing can be managed via the `autoClearing` property within the [`OperationalConfiguration`](#table-operationalconfiguration) of your `SdkConfiguration`.


&emsp;Use the `makeClearingPayment` method to explicitly initiate the clearing (final capture) of funds for a previously authorized payment. This method gives you the flexibility to clear an amount that may be different from the original amount specified when the payment was created (e.g., for partial captures).

&emsp;This method takes these parameters:

| Parameter   | Type                                      | Description                                                                                                                                | Constraints/Notes                                                                                                      |
|-------------|-------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| `paymentId` | `Int64`                                    | Unique identifier of the payment you want to clear.                                                                                        |                                                                                                                        |
| `amount`    | `Float?`                                  | Amount to be cleared. If `nil`, the full amount of the original authorized payment will be cleared.                                       | Optional. Defaults to nil. Must be between `0.01` and `99999999.00` if provided. Cannot exceed the authorized amount. |
| `onResult`  | `@escaping (FreedomResult<ClearingStatus>) -> Void` | Callback function that will be invoked with the result of the clearing operation. See [`ClearingStatus`](#clearingstatus-structure) model. |                                                                                                                        |

&emsp;The process returns an [`FreedomResult<ClearingStatus>`](#error-handling-and-results) object, which can be either:
- **Success**: Contains a `ClearingStatus` object.
- **Error**: Specifies the type of error that occurred.

```swift
freedomApi.makeClearingPayment(Int64(123456)) { (result: FreedomResult<ClearingStatus>) in
    switch result {
    case .success(let status):
        // Handle the clearing status.
        break
    case .error(let error):
        // Failed to clear the payment.
        break
    }
}
```

#### Make Cancel Payment
> **NOTE**
> This method is specifically designed for merchants who have **auto-clearing disabled** in their SDK configuration. Auto-clearing can be managed via the `autoClearing` property within the [`OperationalConfiguration`](#table-operationalconfiguration) of your `SdkConfiguration`.


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
    case .success(let response):
        // Cancellation attempt completed successfully.
        break
    case .error(let error):
        // Failed to cancel the payment.
        break
    }
}
```

#### Make Revoke Payment
&emsp;The `makeRevokePayment` method allows you to process a full or partial refund for a completed payment.

&emsp;This method takes these parameters:

| Parameter   | Type                                       | Description                                                                                                                              | Constraints/Notes                                                                                                      |
|-------------|--------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| `paymentId` | `Int64`                                     | Unique identifier of the payment you want to revoke (refund).                                                                            |                                                                                                                        |
| `amount`    | `Float?`                                   | Amount of funds to return. If `nil`, the full amount of the original debited payment will be refunded.                                  | Optional. Defaults to nil. Must be between `0.01` and `99999999.00` if provided. Cannot exceed the authorized amount. |
| `onResult`  | `@escaping (FreedomResult<PaymentResponse>) -> Void` | Callback function that will be invoked with the result of the refund process. See [`PaymentResponse`](#paymentresponse-structure) model. |                                                                                                                        |

&emsp;The process returns an [`FreedomResult<PaymentResponse>`](#error-handling-and-results) object, which can be either:
- **Success**: Contains a `PaymentResponse` object.
- **Error**: Specifies the type of error that occurred.

```swift
freedomApi.makeRevokePayment(Int64(123456)) { (result: FreedomResult<PaymentResponse>) in
    switch result {
    case .success(let response):
        // Refund process completed successfully.
        break
    case .error(let error):
        // Failed to process the refund.
        break
    }
}
```


#### Get Added Cards
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
freedomApi.getAddedCards("user12345") { result in
    switch result {
    case .success(let cards):
        print("Retrieved \(cards.count) cards")
    case .failure(let error):
        print("Failed to retrieve cards: \(error)")
    }
}
```

#### Remove Added Card
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
) { result in
    switch result {
    case .success(let removedCard):
        // Card removal process completed successfully.
        print("Removed: \(removedCard)")

    case .failure(let error):
        // Failed to remove the card.
        print("Error: \(error)")
    }
}
```

### Error Handling and Results
&emsp;All asynchronous operations in the SDK return their outcome encapsulated within a `FreedomResult` sealed interface.

&emsp;The `FreedomResult` interface has two primary states: `success` for successful completion and `error` for any failures.

#### `FreedomResult.success<T>`
- Represents a successful completion of the SDK operation.
- `value: T`: Holds the actual result of the operation. The type `T` will vary depending on the method called (e.g., `Payment`, `[Card]`, `ConfirmPaymentStatus`).

#### `FreedomResult.error`
&emsp;The `error` type is a sealed interface itself, providing distinct types of errors for more precise handling.

- `ValidationError`: Indicates that one or more inputs provided to the SDK method were invalid or did not meet specified constraints (e.g., `amount` out of range, `userId` format mismatch). 
    - `errors: [ValidationErrorType]`: A error detailing all specific validation errors that occurred. See [`ValidationErrorType`](#table-validationerrortype) table.
- `PaymentInitializationFailed`: Indicates a general failure during the initial setup or preparation of a payment, before it reaches the transaction processing stage.
- `Transaction`: Represents an error encountered by the payment gateway during the transaction processing.
    - `errorCode: Int`: A numerical code representing a specific transaction error. You can find an up-to-date reference of error codes [here](https://customer.freedompay.kz/dev/error?lang=en)
    - `errorDescription: String?`: A human-readable description of the transaction error, if available.
- `NetworkError`: Represents errors related to network connectivity or API responses.
    - `protocol`: Indicates an issue with the communication protocol or an unexpected response from the API.
        - `code: Int`: An HTTP status code.
        - `body: String?`: A human-readable description of the protocol error, if available.
    - `connectivity`: Indicates problems related to the device's network connection.
        - `connectionFailed`: The network connection could not be established.
        - `connectionTimeout`: The network request timed out.
        - `integrity`: An issue with the integrity of the network connection.
    - `unknown`: A general network error occurred that does not fall into more specific categories.
- `InfrastructureError`: Represents errors related to the internal state or setup of the SDK.
    - `sdkNotConfigured`: The SDK methods were called before `freedomApi.setConfiguration()` was successfully invoked.
    - `sdkCleared`: The SDK methods were called after the SDK was cleared.
    - `parsingError`: An error occurred while parsing data (e.g., response from the server could not be deserialized).

#### Table `ValidationErrorType`

```swift
enum ValidationErrorType: String, Codable {
    case invalidMerchantID         = "INVALID_MERCHANT_ID"
    case invalidSecretKey          = "INVALID_SECRET_KEY"
    case invalidPaymentAmount      = "INVALID_PAYMENT_AMOUNT"
    case invalidOrderID            = "INVALID_ORDER_ID"
    case invalidUserID             = "INVALID_USER_ID"
    case invalidCardToken          = "INVALID_CARD_TOKEN"
}
```


| Enum Constant            | Description                                                                |
|--------------------------|----------------------------------------------------------------------------|
| `INVALID_MERCHANT_ID`    | Provided merchant ID is invalid or missing.                                |
| `INVALID_SECRET_KEY`     | Provided secret key is invalid or missing.                                 |
| `INVALID_PAYMENT_AMOUNT` | Payment amount is outside the allowed range (`0.01` - `99999999.00`).      |
| `INVALID_ORDER_ID`       | Provided order ID does not meet the specified length constraints.          |
| `INVALID_USER_ID`        | Provided user ID does not meet the specified format or length constraints. |
| `INVALID_CARD_TOKEN`     | Provided card token does not meet the specified length constraints.        |

---

### Data Structures
&emsp;This section provides detailed descriptions of the structs and enums used throughout the SDK, particularly in the results of various method calls.

#### `PaymentResponse` Structure
&emsp;The `PaymentResponse` struct represents a successful payment transaction.

| Property     | Type      | Description                                     |
|--------------|-----------|-------------------------------------------------|
| `status`     | `String`  | Status of the operation.                        |
| `paymentId`  | `Int64`    | Unique identifier for this payment.             |
| `merchantId` | `String`  | ID of the merchant associated with the payment. |
| `orderId`    | `String?` | Order ID provided during payment creation.      |

#### `Status` Structure
&emsp;Provides comprehensive details about the current state of a payment.

| Property          | Type                    | Description                                                             |
|-------------------|-------------------------|-------------------------------------------------------------------------|
| `status`          | `String`                | Status of the operation.                                                |
| `paymentId`       | `Int64`                  | Unique identifier for this payment.                                     |
| `orderId`         | `String?`               | Order ID provided during payment creation.                              |
| `currency`        | `String`                | Currency code of the payment.                                           |
| `amount`          | `Float`                 | Original amount of the payment.                                         |
| `canReject`       | `Bool?`              | Indicates if the payment can still be cancelled.                        |
| `paymentMethod`   | `String?`               | Method used for payment.                                                |
| `paymentStatus`   | `String?`               | Current status of the payment.                                          |
| `clearingAmount`  | `Float?`                | Total amount that has been cleared (captured) for this payment.         |
| `revokedAmount`   | `Float?`                | Total amount that has been cancelled for this payment.                  |
| `refundAmount`    | `Float?`                | Total amount that has been refunded.                                    |
| `cardName`        | `String?`               | Name on the card used for the payment.                                  |
| `cardPan`         | `String?`               | Masked Primary Account Number (PAN) of the card.                        |
| `revokedPayments` | `[RevokedPayment]?` | List of individual cancelled transactions associated with this payment. |
| `refundPayments`  | `[RefundPayment]?`  | List of individual refund transactions associated with this payment.    |
| `reference`       | `Int64?`                 | System-generated reference number for the payment.                      |
| `captured`        | `Bool?`              | Indicates if the funds for the payment have been captured.              |
| `createDate`      | `String`                | Date and time when the payment was created.                             |
| `authCode`        | `Int?`                  | Authorization code for the payment.                                     |

#### `RevokedPayment` Structure
&emsp;Details of an individual cancelled transaction.

| Property        | Type      | Description                      |
|-----------------|-----------|----------------------------------|
| `paymentId`     | `Int64?`   | ID of the cancelled payment.     |
| `paymentStatus` | `String?` | Status of the cancelled payment. |

#### `RefundPayment` Structure
&emsp;Details of an individual refund transaction.

| Property        | Type      | Description                                       |
|-----------------|-----------|---------------------------------------------------|
| `paymentId`     | `Int64?`   | ID of the refund payment.                         |
| `paymentStatus` | `String?` | Status of the refund payment.                     |
| `amount`        | `Float?`  | Amount that was refunded in this transaction.     |
| `paymentDate`    | `String?` | Date and time of the refund.                      |
| `reference`     | `Int64?`   | System-generated reference number for the refund. |

#### `ClearingStatus` Structure
&emsp;Represents the status of a clearing operation.

| Type                         | Description                                                                                               |
|------------------------------|-----------------------------------------------------------------------------------------------------------|
| `success(let amount: Decimal)` | Indicates that the clearing operation was successful. `amount`: The amount that was successfully cleared. |
| `exceedsPaymentAmount`       | Indicates that the requested clearing amount exceeded the originally authorized payment amount.           |
| `failed`                     | Indicates that the clearing operation failed.                                                             |

#### `Card` Structure
&emsp;Represents a single tokenized payment card associated with a user.

| Property             | Type      | Description                                            |
|----------------------|-----------|--------------------------------------------------------|
| `status`             | `String?` | Status of the operation.                               |
| `merchantId`         | `String?` | ID of the merchant.                                    |
| `recurringProfileId` | `String?` | ID assigned to a user's recurring payment profile      |
| `cardToken`          | `String?` | Token used to reference this card for future payments. |
| `cardHash`           | `String?` | Masked Primary Account Number (PAN) of the card.       |
| `createdAt`          | `String?` | Date and time when the card was added.                 |

#### `RemovedCard` Structure
&emsp;Represents the outcome of an attempt to remove a stored card.

| Property     | Type      | Description                                      |
|--------------|-----------|--------------------------------------------------|
| `status`     | `String?` | Status of the operation.                         |
| `merchantId` | `String?` | ID of the merchant.                              |
| `cardHash`   | `String?` | Masked Primary Account Number (PAN) of the card. |
| `deletedAt`  | `String?` | Date and time when the card was deleted.         |

#### `Currency` Structure
&emsp;The `Currency` enum defines all supported currency codes that can be used when specifying payment amounts.
```swift
enum Currency: String {
    KZT,
    RUB,
    USD,
    UZS,
    KGS,
    EUR,
    HKD,
    GBP,
    AED,
    CNY,
    KRW,
    INR,
    THB,
    UAH,
    AMD,
    BYN,
    PLN,
    CZK,
    AZN,
    GEL,
    TJS,
    CAD,
    MDL,
    TRY
}
```

---
### Support
If you have questions or need help, feel free to reach out! 👋
**Email**: support@freedompay.kz

