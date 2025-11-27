// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FreedomPaymentSdk",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FreedomPaymentSdk",
            targets: ["FreedomPaymentSdk"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "FreedomPaymentSdk",
            path: "Binary/FreedomPaymentSdk.xcframework"
        )
    ]
)