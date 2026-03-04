//
//  Mention.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Represents a mention event delivered to a user.
public struct Mention {
  /// The timetoken of the message containing the mention
  public let messageTimetoken: Timetoken
  /// The channel where the mention occurred
  public let channelId: String
  /// The parent channel if the mention is in a thread, otherwise `nil`
  public let parentChannelId: String?
  /// The user ID of the message author who created the mention
  public let mentionedByUserId: String
}
