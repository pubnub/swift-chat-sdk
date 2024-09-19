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
import PubNubChat
import PubNubSDK

public struct Action {
  public var uuid: String
  public var actionTimetoken: Timetoken

  public init(uuid: String, actionTimetoken: Timetoken) {
    self.uuid = uuid
    self.actionTimetoken = actionTimetoken
  }
}
