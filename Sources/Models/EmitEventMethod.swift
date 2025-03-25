//
//  EmitEventMethod.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Enum representing the method used to emit an event in the chat system.
public enum EmitEventMethod: JSONCodable {
  /// Represents events emitted using the "signal" method, typically for lightweight real-time updates
  case signal
  /// Represents events emitted using the "publish" method, typically for broadcasting messages to a channel
  case publish
}
