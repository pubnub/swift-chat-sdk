//
//  File.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Represents a file that is associated with a message in the chat system.
public struct File {
  /// The name of the file
  public var name: String
  /// The unique identifier of the file
  public var id: String
  /// The URL where the file can be accessed or downloaded
  public var url: String
  /// The MIME type of the file (e.g., "image/jpeg", "application/pdf"). This is optional
  public var type: String?
}
