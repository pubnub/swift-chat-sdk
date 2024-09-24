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

public struct Restriction {
  public var userId: String
  public var channelId: String
  public var ban: Bool
  public var mute: Bool
  public var reason: String?

  public init(userId: String, channelId: String, ban: Bool, mute: Bool, reason: String? = nil) {
    self.userId = userId
    self.channelId = channelId
    self.ban = ban
    self.mute = mute
    self.reason = reason
  }
}

public enum RestrictionType {
  case ban
  case mute
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
