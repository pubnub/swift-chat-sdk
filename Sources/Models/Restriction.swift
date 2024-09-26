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

/// Represents a restriction applied to a specific user
public struct Restriction {
  /// The unique identifier of the user who is subject to the restriction
  public var userId: String
  /// The unique identifier of the channel where the restriction applies
  public var channelId: String
  /// Indicates whether the user is banned from the channel
  public var ban: Bool
  /// Indicates whether the user is muted in the channel
  public var mute: Bool
  /// An optional description or explanation for the restriction
  public var reason: String?

  /// Initializes a new instance of ``EventContent.Custom`` with the provided details
  ///
  /// - Parameters:
  ///   - userId: The unique identifier of the user who is subject to the restriction
  ///   - channelId: The unique identifier of the channel where the restriction applies
  ///   - ban: Indicates whether the user is banned from the channel
  ///   - mute: Indicates whether the user is muted in the channel
  ///   - reason: An optional description or explanation for the restriction
  public init(userId: String, channelId: String, ban: Bool, mute: Bool, reason: String? = nil) {
    self.userId = userId
    self.channelId = channelId
    self.ban = ban
    self.mute = mute
    self.reason = reason
  }
}

/// Representing the type of restriction applied to a user
public enum RestrictionType: String {
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
