//
//  Dictionary.swift
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

extension [String: Any] {
  func mapToScalars() -> [String: JSONCodableScalar] {
    compactMapValues { element -> JSONCodableScalar? in
      if let element = element as? Int {
        return element
      } else if let element = element as? Double {
        return element
      } else if let element = element as? Bool {
        return element
      } else {
        return element as? JSONCodableScalar
      }
    }
  }
}

extension [String: [String: [Action]]] {
  func transform() -> [String: [String: [PubNubChat.PNFetchMessageItem.Action]]] {
    compactMapValues {
      $0.compactMapValues {
        $0.map {
          PubNubChat.PNFetchMessageItem.Action(
            uuid: $0.uuid,
            actionTimetoken: Int64($0.actionTimetoken)
          )
        }
      }
    }
  }
}

extension [String: JSONCodableScalar] {
  func asCustomObject() -> PubNubChat.CustomObject {
    PubNubChat.CustomObject(value: self)
  }
}

extension [String: [PubNubChat.PNFetchMessageItem.Action]] {
  func transform() -> [String: [Action]] {
    compactMapValues {
      $0.map {
        Action(
          uuid: $0.uuid,
          actionTimetoken: Timetoken($0.actionTimetoken)
        )
      }
    }
  }
}

extension [String: [String: [PNFetchMessageItem.Action]]] {
  func transform() -> [String: [String: [Action]]] {
    compactMapValues {
      $0.compactMapValues {
        $0.map {
          Action(
            uuid: $0.uuid,
            actionTimetoken: Timetoken($0.actionTimetoken)
          )
        }
      }
    }
  }
}

extension [KotlinInt: PubNubChat.MessageMentionedUser] {
  func transform() -> MessageMentionedUsers {
    reduce(into: MessageMentionedUsers()) { res, currentItem in
      res[currentItem.key.intValue] = MessageMentionedUser(
        id: currentItem.value.id,
        name: currentItem.value.name
      )
    }
  }
}

extension [KotlinInt: PubNubChat.MessageReferencedChannel] {
  func transform() -> MessageReferencedChannels {
    reduce(into: MessageReferencedChannels()) { res, currentItem in
      res[currentItem.key.intValue] = MessageReferencedChannel(
        id: currentItem.value.id,
        name: currentItem.value.name
      )
    }
  }
}

extension [PubNubSwiftChatSDK.ChannelType: Int64] {
  func transform() -> [PubNubChat.ChannelType: Any] {
    ChatConfigurationKt.RateLimitPerChannel(
      direct: KotlinDurationUtils.companion.toMilliseconds(interval: self[.direct] ?? 0),
      group: KotlinDurationUtils.companion.toMilliseconds(interval: self[.group] ?? 0),
      public: KotlinDurationUtils.companion.toMilliseconds(interval: self[.public] ?? 0),
      unknown: KotlinDurationUtils.companion.toMilliseconds(interval: self[.unknown] ?? 0)
    )
  }
}
