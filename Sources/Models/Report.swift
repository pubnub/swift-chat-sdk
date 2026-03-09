//
//  Report.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Represents a report event indicating that a user has reported a message.
public struct Report {
  /// The reason for reporting the message
  public let reason: String
  /// The text of the reported message, if provided
  public let text: String?
  /// The timetoken of the message being reported, if applicable
  public let messageTimetoken: Timetoken?
  /// The channel ID where the reported message was sent, if applicable
  public let reportedMessageChannelId: String?
  /// The user ID of the user being reported
  public let reportedUserId: String?
  /// The ID of the auto moderation rule that triggered the report, if applicable
  public let autoModerationId: String?
}
