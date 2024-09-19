// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PubNubSwiftChatSDK",
  platforms: [.iOS(.v14)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "PubNubSwiftChatSDK",
      targets: ["PubNubSwiftChatSDK"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/jguz-pubnub/kmp-chat", from: "1.0.0"),
    .package(url: "https://github.com/pubnub/swift", branch: "feat/kmp2")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "PubNubSwiftChatSDK",
      dependencies: [
        .product(name: "PubNubSDK", package: "swift"),
        .product(name: "PubNubChat", package: "kmp-chat")
      ]
    ),
    .testTarget(
      name: "PubNubSwiftChatSDKTests",
      dependencies: ["PubNubSwiftChatSDK"]
    )
  ]
)
