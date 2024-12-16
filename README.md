# PubNub Swift Chat SDK

PubNub takes care of the infrastructure and APIs needed for the realtime communication layer of your application. Work on your app's logic and let PubNub handle sending and receiving data across the world in less than 100ms.

This SDK offers a set of handy methods to create your own feature-rich chat or add a chat to your existing application.

It exposes various PubNub APIs with twists:

* Tailored specifically to the chat use case by offering easy-to-use methods that let you do exactly what you want, like startTyping() (a message) or join() (a channel).
* Meant to be easy & intuitive to use as it focuses on features you would most likely build in your chat app, not PubNub APIs and all the technicalities behind them.
* Offers new chat options, like quotes, threads, or read receipts, that let you build a full-fledged app quickly.

## Table Of Contents

* [Requirements](#requirements)
* [Get keys](#get-keys)
* [Set up your project](#set-up-your-project)
* [Configure](#configure)
* [Documentation](#documentation)
* [Support](#support)
* [License](#license)

## Requirements

* iOS 14.0+ / macOS 11.0+ / tvOS 14.0+
* Xcode 15+
* Swift 5+

## Get keys

You will need the publish and subscribe keys to authenticate your app. Get your keys from the [Admin Portal](https://dashboard.pubnub.com/).

## Set up your project

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

1. Create or open your project inside Xcode.
2. Navigate to **File -> Add Package Dependencies**.
3. Search for `https://github.com/pubnub/swift-chat-sdk`
4. From the **Dependency Rule** drop-down list, select **Exact**. In the version input field, type `0.9.2-dev`
5. Click the **Add Package** button.

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

If you **need help** or have a **general question**, contact [support@pubnub.com](mailto:support@pubnub.com).

## License

The PubNub Swift Chat SDK is released under the `PubNub Software Development Kit License`.

[See LICENSE](https://github.com/pubnub/swift-chat-sdk/blob/master/LICENSE) for details.
