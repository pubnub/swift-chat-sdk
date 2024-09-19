//
//  EventContent.swift
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

public class EventContent {
  // MARK: - Report

  public class Report: EventContent {
    public let text: String?
    public let reason: String
    public let reportedMessageTimetoken: Timetoken?
    public let reportedMessageChannelId: String?
    public let reportedUserId: String?

    public init(
      text: String? = nil,
      reason: String,
      reportedMessageTimetoken: Timetoken? = nil,
      reportedMessageChannelId: String? = nil,
      reportedUserId: String? = nil
    ) {
      self.text = text
      self.reason = reason
      self.reportedMessageTimetoken = reportedMessageTimetoken
      self.reportedMessageChannelId = reportedMessageChannelId
      self.reportedUserId = reportedUserId
    }
  }

  // MARK: - Typing

  public class Typing: EventContent {
    public let value: Bool

    public init(value: Bool) {
      self.value = value
    }
  }

  // MARK: - Receipt

  public class Receipt: EventContent {
    public let messageTimetoken: Timetoken

    public init(messageTimetoken: Timetoken) {
      self.messageTimetoken = messageTimetoken
    }
  }

  // MARK: - Mention

  public class Mention: EventContent {
    public let messageTimetoken: Timetoken
    public let channel: String
    public let parentChannel: String?

    public init(messageTimetoken: Timetoken, channel: String, parentChannel: String? = nil) {
      self.messageTimetoken = messageTimetoken
      self.channel = channel
      self.parentChannel = parentChannel
    }
  }

  // MARK: - Invite

  public class Invite: EventContent {
    public let channelType: ChannelType
    public let channelId: String

    public init(channelType: ChannelType, channelId: String) {
      self.channelType = channelType
      self.channelId = channelId
    }
  }

  // MARK: - Custom

  public class Custom: EventContent {
    public let data: [String: Any]
    public let method: EmitEventMethod

    public init(data: [String: Any], method: EmitEventMethod) {
      self.data = data
      self.method = method
    }
  }

  // MARK: - Moderation

  public class Moderation: EventContent {
    public let channelId: String
    public let restriction: RestrictionType
    public let reason: String?

    public init(channelId: String, restriction: RestrictionType, reason: String?) {
      self.channelId = channelId
      self.restriction = restriction
      self.reason = reason
    }
  }

  // MARK: - TextMessageContent

  public class TextMessageContent: EventContent {
    public let text: String
    public let files: [File]?

    public init(text: String, files: [File]? = nil) {
      self.text = text
      self.files = files
    }

    func transform() -> PubNubChat.EventContent.TextMessageContent {
      PubNubChat.EventContent.TextMessageContent(
        text: text,
        files: files?.map {
          PubNubChat.File(
            name: $0.name,
            id: $0.id,
            url: $0.url,
            type: $0.type
          )
        }
      )
    }
  }

  // MARK: - UnknownMessageFormat

  public class UnknownMessageFormat: EventContent {
    public let element: Any?

    public init(element: Any? = nil) {
      self.element = element
    }
  }
}

// MARK: - EventContent Transformations

extension EventContent {
  static func from(rawValue: PubNubChat.EventContent) -> EventContent {
    switch rawValue {
    case let content as PubNubChat.EventContent.Typing:
      EventContent.Typing(
        value: content.value
      )
    case let content as PubNubChat.EventContent.Report:
      EventContent.Report(
        text: content.text,
        reason: content.reason,
        reportedMessageTimetoken: content.reportedMessageTimetoken?.uint64Value,
        reportedMessageChannelId: content.reportedMessageChannelId,
        reportedUserId: content.reportedUserId
      )
    case let conent as PubNubChat.EventContent.Receipt:
      EventContent.Receipt(
        messageTimetoken: Timetoken(conent.messageTimetoken)
      )
    case let content as PubNubChat.EventContent.Mention:
      EventContent.Mention(
        messageTimetoken: Timetoken(content.messageTimetoken),
        channel: content.channel,
        parentChannel: content.parentChannel
      )
    case let content as PubNubChat.EventContent.Invite:
      EventContent.Invite(
        channelType: content.channelType.transform(),
        channelId: content.channelId
      )
    case let content as PubNubChat.EventContent.Custom:
      EventContent.Custom(
        data: content.data,
        method: content.method == .signal ? .signal : .publish
      )
    case let content as PubNubChat.EventContent.TextMessageContent:
      EventContent.TextMessageContent(
        text: content.text,
        files: content.files?.compactMap { $0.transform() }
      )
    case let content as PubNubChat.EventContent.UnknownMessageFormat:
      EventContent.UnknownMessageFormat(
        element: content.jsonElement.value
      )
    default:
      EventContent.UnknownMessageFormat(
        element: rawValue
      )
    }
  }
}

// MARK: - EventContent Transformations

extension EventContent {
  static func transform(content: EventContent) -> PubNubChat.EventContent {
    switch content {
    case let content as EventContent.Typing:
      PubNubChat.EventContent.Typing(value: content.value)
    case let content as EventContent.Report:
      PubNubChat.EventContent.Report(
        text: content.text,
        reason: content.reason,
        reportedMessageTimetoken: content.reportedMessageTimetoken?.asKotlinLong(),
        reportedMessageChannelId: content.reportedMessageChannelId,
        reportedUserId: content.reportedUserId
      )
    case let content as EventContent.Receipt:
      PubNubChat.EventContent.Receipt(
        messageTimetoken: Int64(content.messageTimetoken)
      )
    case let content as EventContent.Mention:
      PubNubChat.EventContent.Mention(
        messageTimetoken: Int64(content.messageTimetoken),
        channel: content.channel,
        parentChannel: content.parentChannel
      )
    case let content as EventContent.Invite:
      PubNubChat.EventContent.Invite(
        channelType: content.channelType.transform(),
        channelId: content.channelId
      )
    case let content as EventContent.Custom:
      PubNubChat.EventContent.Custom(
        data: content.data,
        method: content.method == .signal ? .signal : .publish
      )
    case let content as EventContent.Moderation:
      PubNubChat.EventContent.Moderation(
        channelId: content.channelId,
        restriction: content.restriction.transform(),
        reason: content.reason
      )
    case let content as EventContent.TextMessageContent:
      PubNubChat.EventContent.TextMessageContent(
        text: content.text,
        files: content.files?.map {
          PubNubChat.File(
            name: $0.name,
            id: $0.id,
            url: $0.url,
            type: $0.type
          )
        }
      )
    case let content as EventContent.UnknownMessageFormat:
      PubNubChat.EventContent.UnknownMessageFormat(
        jsonElement: JsonElement(value: content.element)
      )
    default:
      PubNubChat.EventContent.UnknownMessageFormat(
        jsonElement: JsonElement(value: nil)
      )
    }
  }
}

extension EventContent {
  static func classIdentifier(type: EventContent.Type) -> any KotlinKClass {
    switch type {
    case is Report.Type:
      KClassConstants.Companion.shared.report
    case is Typing.Type:
      KClassConstants.Companion.shared.typing
    case is Receipt.Type:
      KClassConstants.Companion.shared.receipt
    case is Mention.Type:
      KClassConstants.Companion.shared.mention
    case is Invite.Type:
      KClassConstants.Companion.shared.invite
    case is Custom.Type:
      KClassConstants.Companion.shared.custom
    case is Moderation.Type:
      KClassConstants.Companion.shared.moderation
    case is TextMessageContent.Type:
      KClassConstants.Companion.shared.textMessageContent
    case is UnknownMessageFormat.Type:
      KClassConstants.Companion.shared.unknownMessageFormat
    default:
      KClassConstants.Companion.shared.unknownMessageFormat
    }
  }
}
