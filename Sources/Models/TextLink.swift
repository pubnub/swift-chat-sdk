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

public struct TextLink {
  public var startIndex: Int
  public var endIndex: Int
  public var link: String

  public init(startIndex: Int, endIndex: Int, link: String) {
    self.startIndex = startIndex
    self.endIndex = endIndex
    self.link = link
  }

  func transform() -> PubNubChat.TextLink {
    PubNubChat.TextLink(
      startIndex: Int32(startIndex),
      endIndex: Int32(endIndex),
      link: link
    )
  }
}
