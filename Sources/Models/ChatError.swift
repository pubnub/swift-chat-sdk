//
//  ChatError.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

public struct ChatError: Error {
  public let underlying: Error?
  public let message: String

  init(underlying: Error? = nil, message: String? = nil) {
    self.underlying = underlying
    self.message = message ?? ""
  }
}
