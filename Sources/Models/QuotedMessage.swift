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

public struct QuotedMessage {
  public var timetoken: Timetoken
  public var text: String
  public var userId: String

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
