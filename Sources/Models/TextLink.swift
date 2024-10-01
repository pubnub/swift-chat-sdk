//
//  TextLink.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

/// Describes a text link
public struct TextLink {
  /// Starts with 0 and indicates the position in the whole message where the link should start
  public var startIndex: Int
  /// Indicates the position in the whole message where the link should end
  public var endIndex: Int
  /// A url link
  public var link: String

  func transform() -> PubNubChat.TextLink {
    PubNubChat.TextLink(
      startIndex: Int32(startIndex),
      endIndex: Int32(endIndex),
      link: link
    )
  }
}
