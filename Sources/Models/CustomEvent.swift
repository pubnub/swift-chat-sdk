//
//  CustomEvent.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Represents a custom event received on a channel.
public struct CustomEvent {
  /// The timetoken indicating when the event was published
  public let timetoken: Timetoken
  /// The ID of the user who emitted the event
  public let userId: String
  /// The custom message type used to categorize the event
  public let type: String?
  /// The custom event payload data
  public let payload: [String: JSONCodable]
}
