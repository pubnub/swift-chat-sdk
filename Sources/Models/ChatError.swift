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

/// Represents an error that can occur.
public struct ChatError: Error {
  /// An optional error that provides more context about the failure
  public let underlying: Error?
  /// A string describing the error
  public let message: String

  init(underlying: Error? = nil, message: String? = nil) {
    self.underlying = underlying
    self.message = message ?? ""
  }
}
