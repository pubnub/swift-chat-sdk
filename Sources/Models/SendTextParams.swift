//
//  SendTextParams.swift
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

/// Encapsulates the additional parameters for sending text messages.
public struct SendTextParams {
  /// Extra information added to the message giving additional context
  public var meta: [String: JSONCodable]?
  /// If true, the messages are stored in Message Persistence if enabled in Admin Portal
  public var shouldStore: Bool
  /// Use HTTP POST
  public var usePost: Bool
  /// Defines if/how long (in hours) the message should be stored in Message Persistence
  public var ttl: Int?
  /// Additional key-value pairs that will be added to the FCM and/or APNS push messages
  public var customPushData: [String: String]?

  public init(
    meta: [String: JSONCodable]? = nil,
    shouldStore: Bool = true,
    usePost: Bool = false,
    ttl: Int? = nil,
    customPushData: [String: String]? = nil
  ) {
    self.meta = meta
    self.shouldStore = shouldStore
    self.usePost = usePost
    self.ttl = ttl
    self.customPushData = customPushData
  }

  func transform() -> PubNubChat.SendTextParams {
    PubNubChat.SendTextParams(
      meta: meta?.compactMapValues { $0.rawValue },
      shouldStore: shouldStore,
      usePost: usePost,
      ttl: ttl?.asKotlinInt,
      customPushData: customPushData
    )
  }
}
