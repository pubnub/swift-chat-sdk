//
//  Message.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Represents an object that refers to a single message in a chat.
public protocol Message: CustomStringConvertible {
  associatedtype ChatType: Chat
  associatedtype MessageDraftType: MessageDraft

  /// Reference to the main Chat object
  var chat: ChatType { get }
  /// Timetoken for the message
  var timetoken: Timetoken { get }
  /// Original text content of the message
  var content: EventContent.TextMessageContent { get }
  /// Unique identifier for the channel in which the message was sent
  var channelId: String { get }
  /// Unique ID of the user who sent the message
  var userId: String { get }
  /// Any actions associated with the message, such as reactions, replies, or other interactive elements
  var actions: [String: [String: [Action]]]? { get }
  /// Extra information added to the message giving additional context
  var meta: [String: JSONCodable]? { get }

  /// List of mentioned users with IDs and names
  @available(*, deprecated, message: "Use `Message.getMessageElements()` instead")
  var mentionedUsers: MessageMentionedUsers? { get }
  /// List of referenced channels with IDs and names
  @available(*, deprecated, message: "Use `Message.getMessageElements()` instead")
  var referencedChannels: MessageReferencedChannels? { get }
  /// List of included text links and their position
  @available(*, deprecated, message: "Use `Message.getMessageElements()` instead")
  var textLinks: [TextLink]? { get }

  /// Access the original quoted message in the given ``Message``
  ///
  /// Stores only values for the timetoken, text, and userId parameters. If you want to return the full quoted Message object,
  /// use the ``PubNubSwiftChatSDK/Channel/getMessage(timetoken:)`` method and pass the `timetoken` property from the ``QuotedMessage`` value.
  var quotedMessage: QuotedMessage? { get }
  /// Content of the message
  var text: String { get }
  /// Whether the message is soft deleted
  var deleted: Bool { get }
  /// Whether any thread has been created for this message
  var hasThread: Bool { get }
  /// Message type (currently `"text"` for all Messages)
  var type: String { get }
  /// List of attached files to the given ``Message`` with their names, types, and sources
  var files: [File] { get }
  /// List of reactions attached to the given ``Message``
  var reactions: [String: [Action]] { get }
  /// Error associated with the message, if any
  var error: Error? { get }

  /// Receive updates when specific messages and related message reactions are added, edited, or removed.
  ///
  /// - Important: Keep a strong reference to the returned ``AutoCloseable`` object as long as you want to receive updates. If ``AutoCloseable`` is deallocated,
  /// the stream will be canceled, and no further items will be produced. You can also stop receiving updates manually by calling ``AutoCloseable/close()``.
  ///
  /// - Parameters:
  ///   - messages: A collection of ``Message`` objects for which you want to get updates on changed messages
  ///   - callback: Function that takes a collection of ``Message`` objects. It defines the custom behavior to be executed when detecting message or message reaction changes
  /// - Returns: Interface that lets you stop receiving message-related updates by invoking the `close()` method
  static func streamUpdatesOn(
    messages: [Self],
    callback: @escaping (([Self]) -> Void)
  ) -> AutoCloseable

  /// Checks if the current user added a given emoji to the message.
  ///
  /// - Parameter reaction: Specific emoji added to the message
  /// - Returns: A boolean value indicating if the current user added a given emoji to the message or not
  func hasUserReaction(
    reaction: String
  ) -> Bool

  /// Changes the content of the existing message to a new one.
  ///
  /// - Parameters:
  ///   - newText: New/updated text that you want to add in place of the existing message
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: An updated ``Message`` object
  ///     - **Failure**: An `Error` describing the failure
  func editText(
    newText: String,
    completion: ((Swift.Result<ChatType.ChatMessageType, Error>) -> Void)?
  )

  /// Either permanently removes a historical message from Message Persistence or marks it as deleted (if you remove the message with the soft option).
  ///
  /// - Parameters:
  ///   - soft: Decide if you want to permanently remove message data
  ///   - preserveFiles: Define if you want to keep the files attached to the message or remove them
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: For hard delete, the method returns `nil`. Otherwise, an updated ``Message`` instance with an added `"deleted"` action type
  ///     - **Failure**: An `Error` describing the failure
  func delete(
    soft: Bool,
    preserveFiles: Bool,
    completion: ((Swift.Result<ChatType.ChatMessageType?, Error>) -> Void)?
  )

  /// Get the thread channel on which the thread message is published.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A ``ThreadChannel`` object which can be used for sending and reading messages from the message thread
  ///     - **Failure**: An `Error` describing the failure
  func getThread(
    completion: ((Swift.Result<ChatType.ChatThreadChannelType, Error>) -> Void)?
  )

  /// Forward a given message from one channel to another.
  ///
  /// - Parameters:
  ///   - channelId: Unique identifier of the channel to which you want to forward the message. You can forward a message to the same channel on which it was published or to any other
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The timetoken of the forwarded message
  ///     - **Failure**: An `Error` describing the failure
  func forward(
    channelId: String,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  /// Attach this message to its channel.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The updated ``Channel`` metadata
  ///     - **Failure**: An `Error` describing the failure
  func pin(
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  /// Flag and report an inappropriate message to the admin.
  ///
  /// - Parameters:
  ///   - reason: Reason for reporting/flagging a given message
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The timetoken of the reported message
  ///     - **Failure**: An `Error` describing the failure
  func report(
    reason: String,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  /// Create a thread (channel) for a selected message.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**:  Returns a ``ThreadChannel`` object which can be used for sending and reading messages from the newly created message thread
  ///     - **Failure**: An `Error` describing the failure
  @available(*, deprecated, message: "Use `createThread(text:meta:shouldStore:usePost:ttl:quotedMessage:files:usersToMention:customPushData:completion:)` instead")
  // swiftlint:disable:previous line_length
  func createThread(
    completion: ((Swift.Result<ChatType.ChatThreadChannelType, Error>) -> Void)?
  )

  /// Create a thread by sending the first reply to the current message.
  ///
  /// - Parameters:
  ///   - text: Text that you want to send to the selected channel
  ///   - meta: Publish additional details with the request
  ///   - shouldStore: If true, the messages are stored in Message Persistence if enabled in Admin Portal
  ///   - usePost: Use HTTP POST
  ///   - ttl: Defines if/how long (in hours) the message should be stored in Message Persistence
  ///   - quotedMessage: Object added to a message when you quote another message
  ///   - files: One or multiple files attached to the text message
  ///   - usersToMention: A collection of user ids to automatically notify with a mention after this message is sent
  ///   - customPushData: Additional key-value pairs that will be added to the FCM and/or APNS push messages for the message itself and any user mentions
  ///   - completion: The async `Result` of the method call
  ///     - **Success**:  Returns a ``ThreadChannel`` object which can be used for sending and reading messages from the newly created message thread
  ///     - **Failure**: An `Error` describing the failure
  func createThread(
    text: String,
    meta: [String: JSONCodable]?,
    shouldStore: Bool,
    usePost: Bool,
    ttl: Int?,
    quotedMessage: ChatType.ChatMessageType?,
    files: [InputFile]?,
    usersToMention: [String]?,
    customPushData: [String: String]?,
    completion: ((Swift.Result<ChatType.ChatThreadChannelType, Error>) -> Void)?
  )

  /// Removes a thread (channel) for a selected message.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**:  The updated ``Channel`` object after the removal of the thread
  ///     - **Failure**: An `Error` describing the failure
  func removeThread(
    completion: ((Swift.Result<ChatType.ChatChannelType?, Error>) -> Void)?
  )

  /// Add or remove a reaction to a message.
  ///
  /// It's a method for both adding and removing message reactions. It adds a string flag to the message if the current user hasn't added it yet
  /// or removes it if the current user already added it before.
  ///
  /// - Parameters:
  ///   - reaction: Emoji added to the message or removed from it by the current user
  ///   - completion: The async `Result` of the method call
  ///     - **Success**:  An updated ``Message`` instance
  ///     - **Failure**: An `Error` describing the failure
  func toggleReaction(
    reaction: String,
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  /// You can receive updates when this message and related message reactions are added, edited, or removed.
  ///
  /// - Important: Keep a strong reference to the returned ``AutoCloseable`` object as long as you want to receive updates. If ``AutoCloseable`` is deallocated,
  /// the stream will be canceled, and no further items will be produced. You can also stop receiving updates manually by calling ``AutoCloseable/close()``.
  ///
  /// - Parameter completion: Function that takes a single Message object. It defines the custom behavior to be executed when detecting message or message reaction changes
  /// - Returns: Interface that lets you stop receiving message-related updates by invoking the ``AutoCloseable/close()`` method
  func streamUpdates(
    completion: @escaping ((Self) -> Void)
  ) -> AutoCloseable

  /// If you delete a message, you can restore its content together with the attached files using the ``restore(completion:)`` method.
  ///
  /// This is possible, however, only if the message you want to restore was soft deleted (the soft parameter was set to true when deleting it). Hard deleted messages cannot be restored as their data
  /// is no longer available in Message Persistence. This method also requires Message Persistence configuration. To manage messages, you must enable Message Persistence for your app's keyset
  /// in the Admin Portal and mark the Enable Delete-From-History option.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**:  A restored message object
  ///     - **Failure**: An `Error` describing the failure
  func restore(
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  /// Use this on the receiving end if a message was sent using ``MessageDraft`` to parse the ``Message`` text into parts
  /// representing plain text or additional information such as user mentions, channel references and links.
  func getMessageElements() -> [MessageElement]

  /// Creates a message draft for replying in a thread
  ///
  /// - Parameters:
  ///   - userSuggestionSource: The scope for searching for suggested users
  ///   - isTypingIndicatorTriggered: Whether modifying the message text triggers the typing indicator on channel
  ///   - userLimit: The limit on the number of users returned when searching for users to mention
  ///   - channelLimit: The limit on the number of channels returned when searching for channels to reference
  ///   - completion: The async `Result` of the method call
  ///     - **Success**:  A message draft object for composing a message, which you can send by calling ``MessageDraft/send(meta:shouldStore:usePost:ttl:completion:)`` when ready
  ///     - **Failure**: An `Error` describing the failure
  func createThreadMessageDraft(
    userSuggestionSource: UserSuggestionSource,
    isTypingIndicatorTriggered: Bool,
    userLimit: Int,
    channelLimit: Int,
    completion: ((Swift.Result<MessageDraftType, Error>) -> Void)?
  )
}

/// Extension to conform to `CustomStringConvertible` for custom string representation.
/// Provides a readable description of the object for debugging and logging purposes
public extension Message {
  var description: String {
    String.formattedDescription(
      self,
      arguments: [
        ("timetoken", timetoken),
        ("content", content),
        ("channelId", channelId),
        ("userId", userId),
        ("actions", actions ?? "nil"),
        ("meta", meta ?? "nil")
      ]
    )
  }
}
