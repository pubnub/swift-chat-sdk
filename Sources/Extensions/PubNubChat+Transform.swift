//
//  PubNubChat+Transform.swift
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

extension PubNubChat.QuotedMessage {
  func transform() -> QuotedMessage {
    QuotedMessage(
      timetoken: Timetoken(timetoken),
      text: text,
      userId: userId
    )
  }
}

extension PubNubChat.File {
  func transform() -> File {
    File(
      name: name,
      id: id,
      url: url,
      type: type
    )
  }
}

extension PubNubChat.TextLink {
  func transform() -> TextLink {
    TextLink(
      startIndex: Int(startIndex),
      endIndex: Int(endIndex),
      link: link
    )
  }
}

extension [PubNubChat.File] {
  func transform() -> [File] {
    map { $0.transform() }
  }
}

extension [PubNubChat.TextLink] {
  func transform() -> [TextLink] {
    map { $0.transform() }
  }
}

extension PubNubChat.EventContent.TextMessageContent {
  func transform() -> EventContent.TextMessageContent {
    EventContent.TextMessageContent(
      text: text,
      files: files?.transform()
    )
  }
}
