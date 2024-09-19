//
//  PubNubChat.ChannelType.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

extension PubNubChat.ChannelType {
  func transform() -> ChannelType {
    if self == .direct {
      .direct
    } else if self == .public_ {
      .public
    } else if self == .group {
      .group
    } else if self == .unknown {
      .unknown
    } else {
      .unknown
    }
  }
}
