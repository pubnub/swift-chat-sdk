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

/// A protocol for representing the content of various types of events emitted during chat operations
public protocol EventContentProtocol {

}

/// Provides default implementation for various content.
public enum EventContent {
  /// Represents a report event, which is used to report a message or user to the admin.
  public struct Report: EventContentProtocol, CustomStringConvertible {
    /// The text of the report, if provided
    public let text: String?
    /// The reason for reporting the message or user
    public let reason: String
    /// The timetoken of the message being reported, if applicable
    public let reportedMessageTimetoken: Timetoken?
    /// The channel ID of the reported message, if applicable
    public let reportedMessageChannelId: String?
    /// The ID of the user being reported
    public let reportedUserId: String?

    /// Initializes a new instance of `EventContent.Report` with the provided details.
    ///
    /// - Parameters:
    ///   - text: The text of the report
    ///   - reason: The reason for reporting the message or user
    ///   - reportedMessageTimetoken: The timetoken of the message being reported
    ///   - reportedMessageChannelId: The channel ID of the reported message, if applicable
    ///   - reportedUserId: The ID of the user being reported
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

    /// Extension to conform to `CustomStringConvertible` for custom string representation.
    /// Provides a readable description of the object for debugging and logging purposes
    public var description: String {
      String.formattedDescription(
        self,
        arguments: [
          ("text", text ?? "nil"),
          ("reason", reason),
          ("reportedMessageTimetoken", reportedMessageTimetoken ?? "nil"),
          ("reportedMessageChannelId", reportedMessageChannelId ?? "nil"),
          ("reportedUserId", reportedUserId ?? "nil")
        ]
      )
    }
  }
}

public extension EventContent {
  /// Represents a typing event that indicates whether a user is typing.
  struct Typing: EventContentProtocol, CustomStringConvertible {
    /// A boolean value indicating whether the user is typing (true) or not (false)
    public let value: Bool

    /// Initializes a new instance of `EventContent.Typing` with the provided details.
    ///
    /// - Parameter value: A boolean value indicating whether the user is typing (true) or not (false)
    public init(value: Bool) {
      self.value = value
    }

    /// Extension to conform to `CustomStringConvertible` for custom string representation.
    /// Provides a readable description of the object for debugging and logging purposes
    public var description: String {
      String.formattedDescription(self, arguments: [("value", value)])
    }
  }
}

public extension EventContent {
  /// Represents a receipt event, indicating that a message was read.
  struct Receipt: EventContentProtocol, CustomStringConvertible {
    /// The timetoken of the message for which the receipt is being acknowledged
    public let messageTimetoken: Timetoken

    /// Initializes a new instance of `EventContent.Receipt` with the provided details.
    ///
    /// - Parameter messageTimetoken: The timetoken of the message for which the receipt is being acknowledged
    public init(messageTimetoken: Timetoken) {
      self.messageTimetoken = messageTimetoken
    }

    /// Extension to conform to `CustomStringConvertible` for custom string representation.
    /// Provides a readable description of the object for debugging and logging purposes
    public var description: String {
      String.formattedDescription(self, arguments: [("messageTimetoken", messageTimetoken)])
    }
  }
}

public extension EventContent {
  /// Represents a mention event, which indicates that a user was mentioned in a message.
  struct Mention: EventContentProtocol, CustomStringConvertible {
    /// The timetoken of the message in which the user was mentioned
    public let messageTimetoken: Timetoken
    /// The ID of the channel where the mention occurred
    public let channel: String
    /// The ID of the parent channel if the mention occurred in a thread, otherwise null
    public let parentChannel: String?

    /// Initializes a new instance of `EventContent.Mention` with the provided details.
    ///
    /// - Parameters:
    ///   - messageTimetoken: The timetoken of the message in which the user was mentioned
    ///   - channel: The ID of the channel where the mention occurred
    ///   - parentChannel: The ID of the parent channel if the mention occurred in a thread, otherwise null
    public init(messageTimetoken: Timetoken, channel: String, parentChannel: String? = nil) {
      self.messageTimetoken = messageTimetoken
      self.channel = channel
      self.parentChannel = parentChannel
    }

    /// Extension to conform to `CustomStringConvertible` for custom string representation.
    /// Provides a readable description of the object for debugging and logging purposes
    public var description: String {
      String.formattedDescription(
        self,
        arguments: [
          ("messageTimetoken", messageTimetoken),
          ("channel", channel),
          ("parentChannel", parentChannel ?? "nil")
        ]
      )
    }
  }
}

public extension EventContent {
  /// Represents an invite event, which is used when a user is invited to join a channel.
  struct Invite: EventContentProtocol, CustomStringConvertible {
    /// The type of the channel
    public let channelType: ChannelType
    /// The ID of the channel to which the user is invited
    public let channelId: String

    /// Initializes a new instance of `EventContent.Invite` with the provided details.
    ///
    /// - Parameters:
    ///   - channelType: The type of the channel (e.g., direct, group)
    ///   - channelId: The ID of the channel to which the user is invited
    public init(channelType: ChannelType, channelId: String) {
      self.channelType = channelType
      self.channelId = channelId
    }

    /// Extension to conform to `CustomStringConvertible` for custom string representation.
    /// Provides a readable description of the object for debugging and logging purposes
    public var description: String {
      String.formattedDescription(
        self,
        arguments: [
          ("channelType", channelType),
          ("channelId", channelId)
        ]
      )
    }
  }
}

public extension EventContent {
  /// Represents a moderation event, which is triggered when a restriction is applied to a user.
  struct Moderation: EventContentProtocol, CustomStringConvertible {
    /// The ID of the channel where the moderation event occurred
    public let channelId: String
    /// The type of restriction applied (e.g., ban, mute)
    public let restriction: RestrictionType
    /// The reason for the restriction, if provided
    public let reason: String?

    /// Initializes a new instance of `EventContent.Moderation` with the provided details.
    ///
    /// - Parameters:
    ///   - channelId: The ID of the channel where the moderation event occurred
    ///   - restriction: The type of restriction applied (e.g., ban, mute)
    ///   - reason: The reason for the restriction, if provided
    public init(channelId: String, restriction: RestrictionType, reason: String?) {
      self.channelId = channelId
      self.restriction = restriction
      self.reason = reason
    }

    /// Extension to conform to `CustomStringConvertible` for custom string representation.
    /// Provides a readable description of the object for debugging and logging purposes
    public var description: String {
      String.formattedDescription(
        self,
        arguments: [
          ("channelId", channelId),
          ("restriction", restriction),
          ("reason", reason ?? "nil")
        ]
      )
    }
  }
}

public extension EventContent {
  /// Represents a text message event, containing the message text and any associated files.
  struct TextMessageContent: EventContentProtocol, CustomStringConvertible {
    /// The text content of the message
    public let text: String
    /// A list of ``File`` objects attached to the given ``PubNubSwiftChatSDK/EventContent/TextMessageContent``, if any
    public let files: [File]?

    /// Initializes a new instance of `EventContent.TextMessageContent` with the provided details.
    ///
    /// - Parameters:
    ///   - text: The text content of the message
    ///   - files: A list of files attached to the message, if any
    public init(text: String, files: [File]? = nil) {
      self.text = text
      self.files = files
    }

    /// Extension to conform to `CustomStringConvertible` for custom string representation.
    /// Provides a readable description of the object for debugging and logging purposes
    public var description: String {
      String.formattedDescription(
        self,
        arguments: [
          ("text", text),
          ("files", files ?? "nil")
        ]
      )
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
}

public extension EventContent {
  /// Represents a custom event with arbitrary data.
  struct Custom: EventContentProtocol, CustomStringConvertible {
    /// A map containing key-value pairs of custom data associated with the event
    public let data: [String: Any]
    /// The method by which the event was emitted
    public let method: EmitEventMethod

    /// Initializes a new instance of `EventContent.Custom` with the provided details
    ///
    /// - Parameters:
    ///   - data: A map containing key-value pairs of custom data associated with the event
    ///   - method: The method by which the event was emitted
    public init(data: [String: Any], method: EmitEventMethod) {
      self.data = data
      self.method = method
    }

    /// Extension to conform to `CustomStringConvertible` for custom string representation.
    /// Provides a readable description of the object for debugging and logging purposes
    public var description: String {
      String.formattedDescription(
        self,
        arguments: [
          ("data", data),
          ("method", method)
        ]
      )
    }
  }
}

public extension EventContent {
  /// Represents a message with an unknown format, used to handle cases where the message format doesn't match known types.
  struct UnknownMessageFormat: EventContentProtocol, CustomStringConvertible {
    /// The raw JSON element representing the message with the unknown format
    public let element: Any?

    /// Initializes a new instance of `EventContent.UnknownMessageFormat` with the provided details.
    /// - Parameter element: The raw JSON element representing the message with the unknown format
    public init(element: Any? = nil) {
      self.element = element
    }

    /// Extension to conform to `CustomStringConvertible` for custom string representation.
    /// Provides a readable description of the object for debugging and logging purposes
    public var description: String {
      String.formattedDescription(self, arguments: [("element", element ?? "nil")])
    }
  }
}

// MARK: - EventContent Transformations

extension EventContent {
  static func from(rawValue: PubNubChat.EventContent) -> EventContentProtocol {
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
  static func transform(content: EventContentProtocol) -> PubNubChat.EventContent {
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

extension EventContentProtocol {
  static func classIdentifier(type: EventContentProtocol.Type) -> any KotlinKClass {
    switch type {
    case is EventContent.Report.Type:
      KClassConstants.Companion.shared.report
    case is EventContent.Typing.Type:
      KClassConstants.Companion.shared.typing
    case is EventContent.Receipt.Type:
      KClassConstants.Companion.shared.receipt
    case is EventContent.Mention.Type:
      KClassConstants.Companion.shared.mention
    case is EventContent.Invite.Type:
      KClassConstants.Companion.shared.invite
    case is EventContent.Custom.Type:
      KClassConstants.Companion.shared.custom
    case is EventContent.Moderation.Type:
      KClassConstants.Companion.shared.moderation
    case is EventContent.TextMessageContent.Type:
      KClassConstants.Companion.shared.textMessageContent
    default:
      KClassConstants.Companion.shared.unknownMessageFormat
    }
  }

  // swiftlint:disable:next file_length
}
