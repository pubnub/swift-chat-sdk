//
//  MessageMentionedUser.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

public typealias MessageMentionedUsers = [Int: MessageMentionedUser]

public struct MessageMentionedUser {
  public var id: String
  public var name: String

  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}

extension MessageMentionedUsers {
  func transform() -> [KotlinInt: PubNubChat.MessageMentionedUser] {
    reduce(into: [KotlinInt: PubNubChat.MessageMentionedUser]()) { res, item in
      res[item.key.asKotlinInt] = PubNubChat.MessageMentionedUser(
        id: item.value.id,
        name: item.value.name
      )
    }
  }
}
