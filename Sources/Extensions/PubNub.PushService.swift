//
//  PubNub.PushService.swift
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

extension PubNub.PushService {
  func transform() -> PubNubChat.PNPushType {
    switch self {
    case .gcm:
      .gcm
    case .fcm:
      .fcm
    case .apns:
      .apns
    case .mpns:
      .mpns
    }
  }
}
