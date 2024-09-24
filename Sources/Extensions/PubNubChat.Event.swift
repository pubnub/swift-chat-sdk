//
//  PubNubChat.Event.swift
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

extension PubNubChat.EventContent {
  func map() -> EventContent {
    switch self {
    case let content as PubNubChat.EventContent.Typing:
      EventContent.Typing(
        value: content.value
      )
    case let content as PubNubChat.EventContent.Receipt:
      EventContent.Receipt(
        messageTimetoken: Timetoken(content.messageTimetoken)
      )
    case let content as PubNubChat.EventContent.UnknownMessageFormat:
      EventContent.UnknownMessageFormat(
        element: content.jsonElement.value
      )
    case let content as PubNubChat.EventContent.Invite:
      EventContent.Invite(
        channelType: content.channelType.transform(),
        channelId: content.channelId
      )
    case let content as PubNubChat.EventContent.Mention:
      EventContent.Mention(
        messageTimetoken: Timetoken(content.messageTimetoken),
        channel: content.channel,
        parentChannel: content.parentChannel
      )
    case let content as PubNubChat.EventContent.Report:
      EventContent.Report(
        text: content.text,
        reason: content.reason,
        reportedMessageTimetoken: content.reportedMessageTimetoken?.uint64Value,
        reportedMessageChannelId: content.reportedMessageChannelId,
        reportedUserId: content.reportedUserId
      )
    case let content as PubNubChat.EventContent.Custom:
      EventContent.Custom(
        data: content.data,
        method: content.method == .signal ? .signal : .publish
      )
    case let content as PubNubChat.EventContent.Moderation:
      EventContent.Moderation(
        channelId: content.channelId,
        restriction: content.restriction.transform(),
        reason: content.reason
      )
    case let content as PubNubChat.EventContent.TextMessageContent:
      EventContent.TextMessageContent(
        text: content.text,
        files: content.files?.map { File(name: $0.name, id: $0.id, url: $0.url, type: $0.type) }
      )
    default:
      EventContent.UnknownMessageFormat(
        element: self
      )
    }
  }
}
