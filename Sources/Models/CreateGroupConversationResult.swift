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

public struct CreateGroupConversationResult<C: Channel, M: Membership> {
  public var channel: C
  public var hostMembership: M
  public var inviteeMemberships: [M]
}
