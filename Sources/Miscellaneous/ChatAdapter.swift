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
  private static var associations: [Association] = []
  private static let queue = DispatchQueue(label: "ChatAdapter.associations")
  private init() {}

  static func map(chat: PubNubChat.Chat) -> Association {
    queue.sync {
      if let association = associations.first(where: { !$0.isEmpty() && $0.kotlinChat === chat }) {
        return association
      } else {
        preconditionFailure("Cannot find Chat object matching \(chat)")
      }
    }
  }

static func associate(chat: ChatImpl, with kotlinChat: PubNubChat.ChatImpl) {
  queue.sync {
    associations.removeAll {
       $0.isEmpty()
    }
    if let existing = associations.first(where: {
      !$0.isEmpty() && ($0.chat === chat || $0.kotlinChat === kotlinChat)
    }) {
      existing._chat = chat
      existing._kotlinChat = kotlinChat
    } else {
      associations.append(.init(chat: chat, kotlinChat: kotlinChat))
    }
  }
}

  static func clean() {
    queue.sync {
      associations.removeAll {
        $0.isEmpty()
      }
    }
  }

  class Association {
    // swiftlint:disable:next force_unwrapping
    var chat: ChatImpl { _chat! }
    // swiftlint:disable:next force_unwrapping
    var kotlinChat: PubNubChat.ChatImpl { _kotlinChat! }

    weak var _chat: ChatImpl?
    weak var _kotlinChat: PubNubChat.ChatImpl?

    init(chat: ChatImpl, kotlinChat: PubNubChat.ChatImpl) {
      _chat = chat
      _kotlinChat = kotlinChat
    }

    func isEmpty() -> Bool {
      _chat == nil || _kotlinChat == nil
    }
  }
}
