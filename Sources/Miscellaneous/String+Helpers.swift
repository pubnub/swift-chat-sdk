//
//  String+Helpers.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Creates a formatted description of an instance and its key-value attributes
/// and returns a formatted string in the form of `TypeName(key: value, key: value)`
extension String {
  static func formattedDescription(_ instance: Any, arguments: @autoclosure () -> [(String, Any)] = []) -> String {
    formattedDescription(String(describing: type(of: instance)), arguments: arguments())
  }

  static func formattedDescription(_ prefix: String, arguments: @autoclosure () -> [(String, Any)] = []) -> String {
    "\(prefix)(\(arguments().map { "\($0.0): \(String(describing: $0.1))" }.joined(separator: ", ")))"
  }
}
