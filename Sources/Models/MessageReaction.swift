//
//  MessageReaction.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Represents a reaction attached to a message.
public struct MessageReaction {
  /// The emoji or reaction string (e.g., "👍", "❤️", "😂")
  public let value: String
  /// Whether the current user added this reaction
  public let isMine: Bool
  /// List of all user IDs who added this reaction
  public let userIds: [String]

  /// The number of users who added this reaction
  public var count: Int { userIds.count }

  init(value: String, isMine: Bool, userIds: [String]) {
    self.value = value
    self.isMine = isMine
    self.userIds = userIds
  }
}
