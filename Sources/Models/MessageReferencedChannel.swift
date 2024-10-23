//
//  MessageReferencedChannel.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

/// The `MessageReferencedChannels` typealias represents a collection of channels that are referenced in a message,
/// where the key indicates the occurrence of the channel reference in the text (starting from 0) and the value is a ``MessageReferencedChannel`` object containing
/// details about the referenced channel.
@available(*, deprecated, message: "Use Message.getMessageElements() instead")
public typealias MessageReferencedChannels = [Int: MessageReferencedChannel]

/// Represents a channel which was mentioned in a message.
@available(*, deprecated, message: "Use Message.getMessageElements() instead")
public struct MessageReferencedChannel {
  /// The unique identifier of the referenced channel
  public var id: String
  /// The display name of the referenced channel
  public var name: String

  /// Initializes a new instance of ``MessageReferencedChannels`` with the provided details.
  ///
  /// - Parameters:
  ///   - id: The unique identifier of the referenced channel
  ///   - name: The display name of the referenced channel
  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}

extension MessageReferencedChannels {
  func transform() -> [KotlinInt: PubNubChat.MessageReferencedChannel] {
    reduce(into: [KotlinInt: PubNubChat.MessageReferencedChannel]()) { res, item in
      res[item.key.asKotlinInt] = PubNubChat.MessageReferencedChannel(
        id: item.value.id,
        name: item.value.name
      )
    }
  }
}
