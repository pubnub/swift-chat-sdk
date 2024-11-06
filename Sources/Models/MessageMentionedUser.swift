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

/// The `MessageMentionedUsers` typealias represents a collection of users who are mentioned in a message,
/// where the key indicates the occurrence of the user mention in the text (starting from 0), and the value is a ``MessageMentionedUser`` object that contains
/// details about the mentioned user.
@available(*, deprecated, message: "Use Message.getMessageElements() instead")
public typealias MessageMentionedUsers = [Int: MessageMentionedUser]

/// Represents a user who was mentioned in a message.
@available(*, deprecated, message: "Use Message.getMessageElements() instead")
public struct MessageMentionedUser {
  /// The unique identifier of the mentioned user
  public var id: String
  /// The display name of the mentioned user
  public var name: String

  /// Initializes a new instance of ``MessageMentionedUser`` with the provided details.
  ///
  /// - Parameters:
  ///   - id: The unique identifier of the mentioned user
  ///   - name: The display name of the mentioned user
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
