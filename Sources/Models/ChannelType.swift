//
//  ChannelType.swift
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

/// Enum representing the different types of channels that can be created
public enum ChannelType: String, CaseIterable {
  /// A direct channel, used for one-on-one communication
  case direct
  /// A group channel, used for communication between multiple users in a private group
  case group
  /// A public channel, used for communication that is accessible to all users
  case `public`
  /// An unknown channel type, used as a fallback when the type is unrecognized
  case unknown

  func transform() -> PubNubChat.ChannelType {
    switch self {
    case .direct:
      .direct
    case .group:
      .group
    case .public:
      .public_
    case .unknown:
      .unknown
    }
  }
}
