//
//  ReadReceipt.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Represents a read receipt for a single user on a channel, indicating how far they have read.
public struct ReadReceipt {
  /// The user ID who read the messages
  public let userId: String
  /// The timetoken of the last message the user has read
  public let lastReadTimetoken: Timetoken
}
