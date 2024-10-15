//
//  QuotedMessage.swift
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

/// Represents a quoted message within a conversation.
public struct QuotedMessage {
  /// Timetoken of the orginal message that you quote
  public var timetoken: Timetoken
  /// Original message content
  public var text: String
  /// Unique user identifier that identifies the user who published the quoted message
  public var userId: String

  /// Initializes a new instance of ``QuotedMessage`` with the provided details.
  /// 
  /// - Parameters:
  ///   - timetoken: Timetoken of the orginal message that you quote
  ///   - text: Original message content
  ///   - userId: Unique user identifier that identifies the user who published the quoted message
  public init(timetoken: Timetoken, text: String, userId: String) {
    self.timetoken = timetoken
    self.text = text
    self.userId = userId
  }

  func transform() -> PubNubChat.QuotedMessage {
    PubNubChat.QuotedMessage(
      timetoken: Int64(timetoken),
      text: text,
      userId: userId
    )
  }
}
