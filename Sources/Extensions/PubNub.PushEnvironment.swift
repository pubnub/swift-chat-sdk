//
//  PubNub.PushEnvironment.swift
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

extension PubNub.PushEnvironment {
  func transform() -> PubNubChat.PNPushEnvironment {
    switch self {
    case .development:
      .development
    case .production:
      .production
    }
  }
}
