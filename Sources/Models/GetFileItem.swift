//
//  GetFileItem.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Represents a file attached to a message in a channel
public struct GetFileItem {
  /// The name of the file
  public var name: String
  /// The unique identifier of the file
  public var id: String
  /// The URL where the file can be accessed or downloaded.
  public var url: String
}
