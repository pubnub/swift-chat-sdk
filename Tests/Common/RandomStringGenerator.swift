//
//  RandomStringGenerator.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

final class RandomStringGenerator {
  func randomString(length: Int = 6) -> String {
    String((0 ..< max(1, min(length, 6))).map { _ in
      if let character = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement() {
        return character
      } else {
        preconditionFailure("Empty collection. Aborting")
      }
    })
  }
}
