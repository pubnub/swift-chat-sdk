//
//  PubNubChat.PNPushType.swift
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

extension PubNubChat.PNPushType {
  func transform() -> PubNub.PushService {
    switch self {
    case .apns:
      .apns
    case .mpns:
      .mpns
    case .gcm:
      .fcm
    case .apns2:
      .apns
    default:
      .fcm
    }
  }
}
