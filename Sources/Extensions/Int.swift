//
//  Int.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

extension Int {
  var asKotlinInt: KotlinInt {
    KotlinInt(integerLiteral: self)
  }
}
