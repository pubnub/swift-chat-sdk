//
//  GetUnreadMessagesCount.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Represents the count of unread messages for a specific user in a given channel
public struct GetUnreadMessagesCount<C: Channel, M: Membership> {
  /// The ``Channel`` in which unread messages are being counted
  public var channel: C
  /// The ``Membership`` representing the user's association with the channel
  public var membership: M
  /// The number of unread messages for the user in the specified channel
  public var count: UInt64
}
