//
//  CreateDirectConversationResult.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Represents the result of creating a direct conversation (private channel) between two users
public struct CreateDirectConversationResult<C: Channel, M: Membership> {
  /// The ``Channel`` object representing the newly created direct conversation
  public var channel: C
  /// The ``Membership`` object representing the channel membership of the user who initiated the conversation
  public var hostMembership: M
  /// The ``Membership`` object representing the channel membership of the invited user.
  public var inviteeMembership: M
}
