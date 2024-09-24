# PubNub Swift Chat SDK

PubNub's Swift Chat SDK provides out-of-the-box chat features like read receipts, unread message counts, and many more, which can be easily integrated into your own UI. It's a simple solution for developers looking to create new chat applications or add chat functionality to existing ones.

* [Requirements](#requirements)
* [Get keys](#get-keys)
* [Set up your project](#set-up-your-project)
* [Configure](#configure)
* [Documentation](#documentation)
* [Support](#support)
* [License](#license)

## Requirements

* iOS 14.0+ (support for other platforms is coming in future releases)
* Xcode 15+
* Swift 5+

## Get keys

You will need the publish and subscribe keys to authenticate your app. Get your keys from the [Admin Portal](https://dashboard.pubnub.com/).

## Set up your project

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

1. Create or open your project inside of Xcode
2. Navigate to File > Add Package Dependencies
3. Search for `https://github.com/pubnub/swift-chat-sdk` and hit the Add Package button
4. Use the `Up to Next Major Version` rule spanning from `1.0.0` < `2.0.0`, and hit the Next button

For more information see Apple's guide on [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

## Configure

1. Import the module named `PubNubSwiftChatSDK` and `PubNubSDK` inside any of your Swift source file:

    ```swift
    import PubNubSDK
    import PubNubSwiftChatSDK // <- Here is our PubNubSwiftChatSDK module import.
    ```

1. Create `PubNubConfiguration` object and `ChatImpl` object:

    ```swift
    let pubNubConfiguration = PubNubConfiguration(
      publishKey: "myPublishKey",
      subscribeKey: "mySubscribeKey",
      userId: "myUniqueUserId"
      // Fill in the necessary parameters for PubNubConfiguration if needed
    )
    let chat = ChatImpl(
      // Fill in the necessary parameters for ChatConfiguration if needed
      chatConfiguration: ChatConfiguration(),
      pubNubConfiguration: pubNubConfiguration
    )
    ```
    
2. Initialize a `chat` object:

    ```swift
    chat.initialize() {
      switch $0 {
        case .success(_):
          print("Chat object initialized")
        case let .failure(error):
          print("Unable to initialize due to error \(error)")
      }    
    }
    ```
    
## Documentation

* [API reference for PubNubSwiftChatSDK](https://www.pubnub.com/docs/chat/swift-chat-sdk/overview)

## Support

If you **need help** or have a **general question**, contact <support@pubnub.com>.

## License

The PubNub Swift Chat SDK is released under the `PubNub Software Development Kit License`.

[See LICENSE](https://github.com/pubnub/swift-chat-sdk/blob/master/LICENSE) for details.
