// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PubNubSwiftChatSDK",
  platforms: [
    .iOS(.v14),
    .macOS(.v11),
    .tvOS(.v14)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "PubNubSwiftChatSDK",
      targets: ["PubNubSwiftChatSDK"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pubnub/kmp-chat", exact: "0.13.4-swift"),
    .package(url: "https://github.com/pubnub/swift", exact: "9.2.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "PubNubSwiftChatSDK",
      dependencies: [
        .product(name: "PubNubSDK", package: "swift"),
        .product(name: "PubNubChat", package: "kmp-chat")
      ],
      resources: [
        .copy("PrivacyInfo.xcprivacy")
      ]
    ),
    .testTarget(
      name: "PubNubSwiftChatSDKTests",
      dependencies: ["PubNubSwiftChatSDK"]
    )
  ]
)
