//
//  ChatConfiguration.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat
import PubNubSDK

// MARK: - CustomPayloads

/// Function that lets Chat SDK send your custom payload structure.
public typealias GetMessagePublishBody = (EventContent.TextMessageContent, String, DefaultGetMessagePublishBody) -> [String: Any]
/// Default handler producing a `Dictionary` from the given `EventContent.TextMessageContent`.
public typealias DefaultGetMessagePublishBody = (EventContent.TextMessageContent) -> [String: Any]
/// Function that lets Chat SDK receive your custom payload structure.
public typealias GetMessageResponseBody = ((JSONCodable, String, DefaultGetMessageResponseBody) -> EventContent.TextMessageContent?)
/// Default handler producing a `Dictionary` object from the given `JSONCodable`.
public typealias DefaultGetMessageResponseBody = (JSONCodable) -> EventContent.TextMessageContent?

typealias KotlinGetMessagePublishBody = (PubNubChat.EventContent.TextMessageContent, String, KotlinDefaultGetMessagePublishBody) -> [String: Any]
typealias KotlinDefaultGetMessagePublishBody = (PubNubChat.EventContent.TextMessageContent) -> [String: Any]
typealias KotlinGetMessageResponseBody = (JsonElement, String, KotlinDefaultGetMessageResponseBody) -> PubNubChat.EventContent.TextMessageContent?
typealias KotlinDefaultGetMessageResponseBody = (JsonElement) -> PubNubChat.EventContent.TextMessageContent?

/// Represents a class capable of performing custom payload transformations.
public class CustomPayloads {
  /// Function that lets Chat SDK send your custom payload structure. The function will take an `EventContent.TextMessageContent` object and channel id as input, and should
  /// produce a `Dictionary` representing the message content, which will be sent as the message payload into PubNub. If you wish to bypass the custom mapping (e.g. for certain channels),
  /// you can fall back to the default by calling the third parameter - ``DefaultGetMessagePublishBody`` and returning its result
  var getMessagePublishBody: GetMessagePublishBody?
  /// Function that lets Chat SDK receive your custom payload structure. Use it to let Chat SDK translate your custom message payload into the default Chat SDK message format.
  /// The function will take a `JSONCodable` object and channel id as input, and should produce `EventContent.TextMessageContent` representing the message content.
  /// If you wish to bypass the custom mapping (e.g. for certain channels), you can fall back to the default by calling the third parameter - `DefaultGetMessageResponseBody` and returning its result
  /// Define `getMessagePublishBody` whenever you use `getMessageResponseBody`
  var getMessageResponseBody: GetMessageResponseBody?
  /// A type of action to add to your Message object whenever a published message is edited
  var editMessageActionName: String?
  /// A type of action to add to your Message object whenever a published message is edited
  var deleteMessageActionName: String?
  /// A type of action to add to your Message object whenever a reaction is added
  var reactionsActionName: String?

  /// Creates a new ``CustomPayloads`` object.
  ///
  /// - Parameters:
  ///   - getMessagePublishBody: Function that lets Chat SDK send your custom payload structure
  ///   - getMessageResponseBody: Function that lets Chat SDK receive your custom payload structure
  ///   - editMessageActionName: If present, overrides the default action type to be added to your Message object whenever a published message is edited
  ///   - deleteMessageActionName: If present, overrides the default action type to be added to your Message object whenever a published message is deleted
  ///   - reactionsActionName: If present, overrides the default action type to be added to your Message object whenever a reaction is added
  public init(
    getMessagePublishBody: GetMessagePublishBody? = nil,
    getMessageResponseBody: GetMessageResponseBody? = nil,
    editMessageActionName: String? = nil,
    deleteMessageActionName: String? = nil,
    reactionsActionName: String? = nil
  ) {
    self.getMessagePublishBody = getMessagePublishBody
    self.getMessageResponseBody = getMessageResponseBody
    self.editMessageActionName = editMessageActionName
    self.deleteMessageActionName = deleteMessageActionName
    self.reactionsActionName = reactionsActionName
  }

  func transform() -> PubNubChat.CustomPayloads {
    var kmpGetMessagePublishBody: KotlinGetMessagePublishBody?
    var kmpGetMessageResponseBody: KotlinGetMessageResponseBody?

    if let thisGetMessagePublishBody = getMessagePublishBody {
      kmpGetMessagePublishBody = { textContent, channelId, _ in
        let thisDefaultBodyHandler: DefaultGetMessagePublishBody = {
          ConstantsKt.defaultGetMessagePublishBody(m: $0.transform())
        }
        let result = thisGetMessagePublishBody(
          textContent.transform(),
          channelId,
          thisDefaultBodyHandler
        )
        return result
      }
    }

    if let thisGetMessageResponseBody = getMessageResponseBody {
      kmpGetMessageResponseBody = { element, channelId, _ in
        let thisDefaultHandler: DefaultGetMessageResponseBody = { _ in
          ConstantsKt.defaultGetMessageResponseBody(message: element)?.transform()
        }
        if let value = element.value as? KMPAnyJSON {
          return thisGetMessageResponseBody(
            value.value,
            channelId,
            thisDefaultHandler
          )?.transform()
        }
        return nil
      }
    }

    return PubNubChat.CustomPayloads(
      getMessagePublishBody: kmpGetMessagePublishBody,
      getMessageResponseBody: kmpGetMessageResponseBody,
      editMessageActionName: editMessageActionName,
      deleteMessageActionName: deleteMessageActionName,
      reactionsActionName: reactionsActionName
    )
  }
}

// MARK: - LogLevel

/// Represents the severity level of logs that will be printed.
public enum LogLevel {
  /// Turn off logging
  case off
  /// Only print errors
  case error
  /// Print warnings and errors
  case warn
  /// Print warnings, errors and info messages
  case info
  /// Print warnings, errors, info messages and debugging information
  case debug
  /// The most verbose logging - print all other types of logs and more
  case verbose

  func transform() -> PubNubChat.LogLevel {
    switch self {
    case .off:
      .off
    case .error:
      .error
    case .warn:
      .warn
    case .info:
      .info
    case .debug:
      .debug
    case .verbose:
      .verbose
    }
  }
}

// MARK: - ChatConfiguration

/// Defines a set of options for chat configuration.
public struct ChatConfiguration {
  /// Specifies if any Chat SDK-related errors should be logged
  public var logLevel: LogLevel
  /// Specifies the default timeout after which the typing indicator automatically stops when no typing signals are received
  public var typingTimeout: Int
  /// Specifies how often the user global presence in the app should be updated. Requires `storeUserActivityTimestamps`
  /// to be set to true. The minimum possible value is 60 seconds. If you try to set it to a lower value, you'll get the storeUserActivityInterval must be at least 60000ms error
  public var storeUserActivityInterval: Int
  /// Specifies if you want to track the user's global presence in your chat app. The user's activity is tracked through ``User/lastActiveTimestamp``
  public var storeUserActivityTimestamps: Bool
  /// List of parameters you must set if you want to enable sending/receiving mobile push notifications for phone devices, either through Apple Push Notification service (APNS) or Firebase Cloud Messaging (FCM)
  public var pushNotificationsConfig: PushNotificationsConfig
  /// The so-called "exponential backoff" which multiplicatively decreases the rate at which messages are published on channels. It's bound to the `rateLimitPerChannel` parameter and is meant
  /// to prevent message spamming caused by excessive retries. The default value of 2 means that if you set `rateLimitPerChannel` for direct channels to 1 second and try to send
  /// three messages on such a channel type within the span of one second, the second message will be published
  /// one second after the first one (just like the `rateLimitPerChannel` value states), but the third one will be published two seconds after the second one, meaning the publishing time is multiplied by 2.
  public var rateLimitFactor: Int
  /// Client-side limit that states the rate at which messages can be published on a given channel type. Its purpose is to prevent message spamming in your chat app.
  public var rateLimitPerChannel: [ChannelType: Int64]
  /// Property that lets you define your custom message payload to be sent and/or received by Chat SDK on one or all channels, whenever it differs from the default `message.text` Chat SDK payload.
  /// It also lets you configure your own message actions whenever a message is edited or deleted
  public var customPayloads: CustomPayloads?
  /// Enable automatic syncing of the ``MutedUsersManagerInterface`` data with App Context, using the current `userId` as the key.
  ///
  ///  Specifically, the data is saved in the `custom` object of the following User in App Context:
  ///
  /// ```
  /// PN_PRIV.{userId}.mute.1
  /// ```
  ///
  /// where `{userId}` is the current PubNubConfiguration's `userId`
  ///
  /// If using Access Manager, the access token must be configured with the appropriate rights to subscribe to that
  /// channel, and get, update, and delete the App Context User with that id.
  ///
  /// Due to App Context size limits, the number of muted users is limited to around 200 and will result in sync errors
  /// when the limit is exceeded. The list will not sync until its size is reduced.
  ///
  public var syncMutedUsers: Bool

  /// Creates a new ``ChatConfiguration`` object
  ///
  /// - Parameters:
  ///   - logLevel: The severity level of logs
  ///   - typingTimeout: The default timeout after which the typing indicator automatically stops when no typing signals are received
  ///   - storeUserActivityInterval: Specifies how often the user global presence in the app should be updated
  ///   - storeUserActivityTimestamps: Specifies if you want to track the user's global presence in your chat app
  ///   - pushNotificationsConfig: List of parameters to enable sending/receiving mobile push notifications
  ///   - rateLimitFactor: The so-called "exponential backoff" which multiplicatively decreases the rate at which messages are published on channels
  ///   - rateLimitPerChannel: Client-side limit that states the rate at which messages can be published on a given channel type
  ///   - customPayloads: Custom message payload to be sent and/or received by Chat SDK
  ///   - syncMutedUsers: A boolean value that controls syncing of muted users
  public init(
    logLevel: LogLevel = .off,
    typingTimeout: Int = 5,
    storeUserActivityInterval: Int = 600,
    storeUserActivityTimestamps: Bool = false,
    pushNotificationsConfig: PushNotificationsConfig = .init(),
    rateLimitFactor: Int = 2,
    rateLimitPerChannel: [ChannelType: Int64] = ChannelType.allCases.reduce(into: [ChannelType: Int64]()) { res, type in res[type] = 0 },
    customPayloads: CustomPayloads? = nil,
    syncMutedUsers: Bool = false
  ) {
    self.logLevel = logLevel
    self.typingTimeout = typingTimeout
    self.storeUserActivityInterval = storeUserActivityInterval
    self.storeUserActivityTimestamps = storeUserActivityTimestamps
    self.pushNotificationsConfig = pushNotificationsConfig
    self.rateLimitFactor = rateLimitFactor
    self.rateLimitPerChannel = rateLimitPerChannel
    self.customPayloads = customPayloads
    self.syncMutedUsers = syncMutedUsers
  }

  func transform() -> any PubNubChat.ChatConfiguration {
    ChatConfigurationKt.ChatConfiguration(
      logLevel: logLevel.transform(),
      typingTimeout: KotlinDurationUtils.companion.toSeconds(interval: Int32(typingTimeout)),
      storeUserActivityInterval: KotlinDurationUtils.companion.toSeconds(interval: Int32(storeUserActivityInterval)),
      storeUserActivityTimestamps: storeUserActivityTimestamps,
      pushNotifications: PubNubChat.PushNotificationsConfig(
        sendPushes: pushNotificationsConfig.sendPushes,
        deviceToken: pushNotificationsConfig.deviceToken,
        deviceGateway: pushNotificationsConfig.deviceGateway.transform(),
        apnsTopic: pushNotificationsConfig.apnsTopic,
        apnsEnvironment: pushNotificationsConfig.apnsEnvironment.transform()
      ),
      rateLimitFactor: Int32(rateLimitFactor),
      rateLimitPerChannel: rateLimitPerChannel.transform(),
      customPayloads: customPayloads?.transform(),
      syncMutedUsers: syncMutedUsers
    )
  }
}

// MARK: - PushNotificationsConfig

/// Defines the list of parameters you must set if you want to enable sending/receiving mobile push notifications for phone devices,
/// either through Apple Push Notification service (APNS) or Firebase Cloud Messaging (FCM).
public struct PushNotificationsConfig {
  /// The main option for enabling sending notifications. It must be set to `true` if you want a particular client (whether a mobile device, web browser, or server) to send
  /// push notifications to mobile devices.
  ///
  /// These push notifications are messages with a provider-specific payload that the Chat SDK automatically attaches  to every message.
  /// Chat SDK includes a default payload setup for ``deviceGateway`` in every message sent to the registered channels.
  public var sendPushes: Bool
  /// Refers to the unique identifier assigned to a specific mobile device by a platform's push notification service.
  ///
  /// - If using **Firebase Cloud Messaging (FCM)**, assign the **raw FCM token**, which is already of `String` type.
  /// - If using **Apple Push Notification Service (APNS)**, assign the **hex-encoded device token**.
  ///
  /// - Note: You can easily convert the `Data` token to hexadecimal String using the `hexEncodedString()` extension method provided in the `PubNubSDK` module.
  public var deviceToken: String?
  /// Option for receiving push notifications on Android (FCM) or iOS (APNS or APNS2) devices
  public var deviceGateway: PubNub.PushService
  /// An Apple specific-option for sending and receiving notifications. Refer to [documentation](https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns)
  public var apnsTopic: String?
  /// Option for receiving notifications on iOS devices. When registering for push notifications, this option specifies whether to use the development or production APNs environment
  public var apnsEnvironment: PubNub.PushEnvironment

  /// Creates a new ``PushNotificationsConfig`` object
  ///
  /// - Parameters:
  ///   - sendPushes: A flag indicating whether to send push notifications
  ///   - deviceToken: Device token obtained during registration to use push notifications
  ///   - deviceGateway: The type of Remote Notification service used to send the notifications
  ///   - apnsTopic: The topic for the notification. In general, the topic is your app's bundle ID/app ID
  ///   - apnsEnvironment: The APS environment to register the device
  public init(
    sendPushes: Bool = false,
    deviceToken: String? = nil,
    deviceGateway: PubNub.PushService = .fcm,
    apnsTopic: String? = nil,
    apnsEnvironment: PubNub.PushEnvironment = .development
  ) {
    self.sendPushes = sendPushes
    self.deviceToken = deviceToken
    self.deviceGateway = deviceGateway
    self.apnsTopic = apnsTopic
    self.apnsEnvironment = apnsEnvironment
  }

  func transform() -> PubNubChat.PushNotificationsConfig {
    PubNubChat.PushNotificationsConfig(
      sendPushes: sendPushes,
      deviceToken: deviceToken,
      deviceGateway: deviceGateway.transform(),
      apnsTopic: apnsTopic,
      apnsEnvironment: apnsEnvironment.transform()
    )
  }
}
