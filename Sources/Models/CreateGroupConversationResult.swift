//
//  CreateGroupConversationResult.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Represents the result of creating a group conversation (group channel) for collaborative communication
public struct CreateGroupConversationResult<C: Channel, M: Membership> {
  /// The ``Channel`` object representing the newly created group conversation
  public var channel: C
  /// The ``Membership`` object representing the channel membership of the user who initiated the group conversation
  public var hostMembership: M
  /// An array of ``Membership`` objects representing the channel memberships of the users invited to the group conversation
  public var inviteeMemberships: [M]
}
