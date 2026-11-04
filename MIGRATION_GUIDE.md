# Migration Guide

## Migrating from versions < 1.1.0

### Apple Pay
- Use `FreedomAPI.payWithApplePay()` instead of `FreedomAPI.createApplePayment()` and `FreedomAPI.confirmApplePayment()`.
  - Apple Pay payments now take a single SDK call. You no longer create a payment before showing the Apple Pay sheet. Launch Apple Pay directly, then pass the received token to `payWithApplePay()`.
  - `payWithApplePay()` takes the same `StandardPaymentRequest` you previously passed to `createApplePayment()`, together with the Apple Pay token.
  - The result type is unchanged: `FreedomResult<PaymentResponse>`.
  ```swift
  // before
  @objc func applePayButtonTapped() {
      freedomApi.createApplePayment(paymentRequest: paymentRequest) { result in
          switch result {
          case .success(let applePayment):
              self.paymentId = applePayment.paymentId
              // Present the Apple Pay sheet.
          case .error:
              // Handle error.
              break
          }
      }
  }

  // in the PassKit authorization delegate
  freedomApi.confirmApplePayment(
      paymentId: paymentId,
      tokenData: payment.token.paymentData
  ) { result: FreedomResult<PaymentResponse> in /* handle result */ }

  // after
  @objc func applePayButtonTapped() {
      // Present the Apple Pay sheet directly.
  }

  // in the PassKit authorization delegate
  freedomApi.payWithApplePay(
      paymentRequest: paymentRequest,
      tokenData: payment.token.paymentData
  ) { result: FreedomResult<PaymentResponse> in /* handle result */ }
  ```
- `ApplePayment` is no longer needed in this flow. It was only used to pass the payment from `createApplePayment()` to `confirmApplePayment()`. The legacy methods and model are still available in the current iOS SDK.
- `payWithApplePay()` requires a `PaymentView`. Call `freedomApi.setPaymentView()` before paying. If the bank requires 3-D Secure, the SDK shows the bank's page in the `PaymentView` and hides it once the payment gets a final status. Without a `PaymentView`, the call returns `.infrastructureError(.webView(.paymentViewIsNotInitialized))`.
  ```swift
  // after
  freedomApi.setPaymentView(paymentView)
  ```
- The user can cancel 3-D Secure with the view's left-edge swipe. The SDK then returns the latest known payment status.
- `payWithApplePay()` accepts an optional `force3ds` parameter (defaults to `false`). Set it to `true` to require 3-D Secure for the payment.
  ```swift
  // after
  freedomApi.payWithApplePay(
      paymentRequest: paymentRequest,
      tokenData: payment.token.paymentData,
      force3ds: true
  ) { result in /* handle result */ }
  ```
- A declined payment is now returned as `FreedomResult.success` with `PaymentResponse.status` set to `.error`. Check `status` instead of relying on `FreedomResult.error` alone.
  ```swift
  // after
  switch result {
  case .success(let response):
      switch response.status {
      case .success:
          /* payment completed */
          break
      case .error(let code, let description):
          /* declined: code, description */
          break
      default:
          /* not final yet: check later with getPaymentStatus() */
          break
      }
  case .error:
      /* handle error */
      break
  }
  ```
- If `payWithApplePay()` returns `FreedomResult.error(.networkError(...))`, the payment may still have been made. Check its status on your backend by `orderId` before letting the user pay again. We recommend always setting `orderId` in `StandardPaymentRequest`.

See [Paying with Apple Pay](README.md#5-paying-with-apple-pay) for the full integration.
