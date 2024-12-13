//
//  Timetoken.swift
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

extension Timetoken {
  func asKotlinLong() -> KotlinLong {
    KotlinLong(value: Int64(self))
  }
}

extension Int64 {
  func asTimetoken() -> Timetoken {
    Timetoken(self)
  }
}
