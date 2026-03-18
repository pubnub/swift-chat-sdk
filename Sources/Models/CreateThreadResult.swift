//
//  CreateThreadResult.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Represents the result of creating a thread and sending the first reply.
public struct CreateThreadResult<TC: ThreadChannel, M: Message> {
  /// The ``ThreadChannel`` object representing the newly created thread
  public var threadChannel: TC
  /// The updated parent ``Message`` with `hasThread` set to `true`
  public var parentMessage: M
}
