//
//  Invite.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Represents an invite event delivered to a user.
public struct Invite {
  /// The channel the user is invited to
  public let channelId: String
  /// Type of the channel (direct, group, etc.)
  public let channelType: ChannelType
  /// User ID who sent the invitation
  public let invitedByUserId: String
  /// Timetoken of the invitation
  public let invitationTimetoken: Timetoken
}
