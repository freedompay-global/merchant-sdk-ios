// swift-tools-version: 5.9
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
        ),
    ],
    targets: [
        .binaryTarget(
            name: "FreedomPaymentSdk",
            url: "https://github.com/freedompay-global/merchant-sdk-ios/releases/download/1.0.1/FreedomPaymentSdk.xcframework.zip",
            checksum: "457a7dbe7fd574852a1842b3756841b18d71e11c4e6b0047c486c8d1c30947e9"
        )
    ]
)
