//
//  MessageActionType.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Enum representing different types of message actions that can be performed on a message.
public enum MessageActionType: String {
  /// Represents a message action related to adding or removing a reaction
  case reactions
  /// Represents a message action related to deleting a message
  case deleted
  /// Represents a message action related to editing a message
  case edited
}
