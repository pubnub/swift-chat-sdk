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

public enum ChannelType: String, CaseIterable {
  case direct
  case group
  case `public`
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
