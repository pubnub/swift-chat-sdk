//
//  ChatAdapter.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

class ChatAdapter {
  static var associations: [Association] = []

  private init() {}

  static func map(chat: PubNubChat.Chat) -> Association {
    if let association = associations.first(where: { !$0.isEmpty() && $0.rawChat === chat }) {
      association
    } else {
      preconditionFailure("Cannot find Chat object matching \(chat)")
    }
  }

  static func associate(chat: ChatImpl, rawChat: PubNubChat.ChatImpl) {
    if !associations.contains(where: { !$0.isEmpty() && $0.chat !== chat && $0.rawChat !== rawChat }) {
      associations.append(.init(chat: chat, rawChat: rawChat))
    }
  }

  static func clean() {
    associations.removeAll {
      $0.isEmpty()
    }
  }

  class Association {
    // swiftlint:disable:next force_unwrapping
    var chat: ChatImpl { _chat! }
    // swiftlint:disable:next force_unwrapping
    var rawChat: PubNubChat.ChatImpl { _rawChat! }

    private weak var _chat: ChatImpl?
    private weak var _rawChat: PubNubChat.ChatImpl?

    init(chat: ChatImpl, rawChat: PubNubChat.ChatImpl) {
      _chat = chat
      _rawChat = rawChat
    }

    func isEmpty() -> Bool {
      _chat == nil || _rawChat == nil
    }
  }
}
