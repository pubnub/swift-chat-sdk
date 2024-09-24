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

public typealias GetMessagePublishBody = (EventContent.TextMessageContent, String, DefaultGetMessagePublishBody) -> [String: Any]
public typealias DefaultGetMessagePublishBody = (EventContent.TextMessageContent) -> [String: Any]

public typealias GetMessageResponseBody = ((JSONCodable, String, DefaultGetMessageResponseBody) -> EventContent.TextMessageContent?)
public typealias DefaultGetMessageResponseBody = (JSONCodable) -> EventContent.TextMessageContent?

typealias KotlinGetMessagePublishBody = (PubNubChat.EventContent.TextMessageContent, String, KotlinDefaultGetMessagePublishBody) -> [String: Any]
typealias KotlinDefaultGetMessagePublishBody = (PubNubChat.EventContent.TextMessageContent) -> [String: Any]
typealias KotlinGetMessageResponseBody = (JsonElement, String, KotlinDefaultGetMessageResponseBody) -> PubNubChat.EventContent.TextMessageContent?
typealias KotlinDefaultGetMessageResponseBody = (JsonElement) -> PubNubChat.EventContent.TextMessageContent?

public class CustomPayloads {
  var getMessagePublishBody: GetMessagePublishBody?
  var getMessageResponseBody: GetMessageResponseBody?
  var editMessageActionName: String?
  var deleteMessageActionName: String?

  public init(
    getMessagePublishBody: GetMessagePublishBody? = nil,
    getMessageResponseBody: GetMessageResponseBody? = nil,
    editMessageActionName: String? = nil,
    deleteMessageActionName: String? = nil
  ) {
    self.getMessagePublishBody = getMessagePublishBody
    self.getMessageResponseBody = getMessageResponseBody
    self.editMessageActionName = editMessageActionName
    self.deleteMessageActionName = deleteMessageActionName
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
      deleteMessageActionName: deleteMessageActionName
    )
  }
}

// MARK: - LogLevel

public enum LogLevel {
  case off
  case error
  case warn
  case info
  case debug
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

public struct ChatConfiguration {
  public var logLevel: LogLevel
  public var typingTimeout: Int
  public var storeUserActivityInterval: Int
  public var storeUserActivityTimestamps: Bool
  public var pushNotificationsConfig: PushNotificationsConfig
  public var rateLimitFactor: Int
  public var rateLimitPerChannel: [ChannelType: Int64]
  public var customPayloads: CustomPayloads?

  public init(
    logLevel: LogLevel = .off,
    typingTimeout: Int = 5,
    storeUserActivityInterval: Int = 600,
    storeUserActivityTimestamps: Bool = false,
    pushNotificationsConfig: PushNotificationsConfig = .init(),
    rateLimitFactor: Int = 2,
    rateLimitPerChannel: [ChannelType: Int64] = ChannelType.allCases.reduce(into: [ChannelType: Int64]()) { res, type in res[type] = 0 },
    customPayloads: CustomPayloads? = nil
  ) {
    self.logLevel = logLevel
    self.typingTimeout = typingTimeout
    self.storeUserActivityInterval = storeUserActivityInterval
    self.storeUserActivityTimestamps = storeUserActivityTimestamps
    self.pushNotificationsConfig = pushNotificationsConfig
    self.rateLimitFactor = rateLimitFactor
    self.rateLimitPerChannel = rateLimitPerChannel
    self.customPayloads = customPayloads
  }

  func transform() -> any PubNubChat.ChatConfiguration {
    ChatConfigurationKt.ChatConfiguration(
      logLevel: logLevel.transform(),
      typingTimeout: KotlinDurationUtils.companion.toSeconds(interval: Int32(typingTimeout)),
      storeUserActivityInterval: KotlinDurationUtils.companion.toSeconds(
        interval: Int32(storeUserActivityInterval)
      ),
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
      customPayloads: customPayloads?.transform()
    )
  }
}

// MARK: - PushNotificationsConfig

public struct PushNotificationsConfig {
  public var sendPushes: Bool
  public var deviceToken: String?
  public var deviceGateway: PubNub.PushService
  public var apnsTopic: String?
  public var apnsEnvironment: PubNub.PushEnvironment

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
