//
//  Action.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Encapsulates a message action in terms of batch history.
public struct Action {
  /// The UUID of the publisher
  public var uuid: String
  /// The publish timetoken of the message action
  public var actionTimetoken: Timetoken

  public init(uuid: String, actionTimetoken: Timetoken) {
    self.uuid = uuid
    self.actionTimetoken = actionTimetoken
  }
}
