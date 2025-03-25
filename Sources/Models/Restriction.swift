//
//  Restriction.swift
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

/// Representing the type of restriction applied to a user.
public enum RestrictionType: String, JSONCodable {
  /// Represents a ban restriction
  case ban
  /// Represents a mute restriction
  case mute
  /// Represents the lifting of any restriction
  case lift

  func transform() -> PubNubChat.RestrictionType {
    switch self {
    case .ban:
      .ban
    case .mute:
      .mute
    case .lift:
      .lift
    }
  }
}

struct Restriction {
  var userId: String
  var channelId: String
  var ban: Bool
  var mute: Bool
  var reason: String?

  init(userId: String, channelId: String, ban: Bool, mute: Bool, reason: String? = nil) {
    self.userId = userId
    self.channelId = channelId
    self.ban = ban
    self.mute = mute
    self.reason = reason
  }
}
