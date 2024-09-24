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

public typealias MessageReferencedChannels = [Int: MessageReferencedChannel]

public struct MessageReferencedChannel {
  public var id: String
  public var name: String

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
