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
public protocol Message {
  associatedtype ChatType: Chat

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
  /// use the ``PubNubSwiftChatSDK/Channel/getMessage(timetoken:)`` method and pass the `timetoken` property from the `QuotedMessage` value.
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
  ///     - **Success**: The updated Channel metadata
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
  func createThread(
    completion: ((Swift.Result<ChatType.ChatThreadChannelType, Error>) -> Void)?
  )

  /// Removes a thread (channel) for a selected message.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**:  The updated channel object after the removal of the thread
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
  ///     - **Success**:  An updated message instance
  ///     - **Failure**: An `Error` describing the failure
  func toggleReaction(
    reaction: String,
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  /// You can receive updates when this message and related message reactions are added, edited, or removed.
  ///
  /// - Parameter completion: Function that takes a single Message object. It defines the custom behavior to be executed when detecting message or message reaction changes
  /// - Returns: Interface that lets you stop receiving message-related updates by invoking the `close()` method
  func streamUpdates(
    completion: @escaping ((Self) -> Void)
  ) -> AutoCloseable

  /// If you delete a message, you can restore its content together with the attached files using the `restore()` method.
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

  /// Use this on the receiving end if a message was sent using ``MessageDraft`` to parse the `Message` text into parts
  /// representing plain text or additional information such as user mentions, channel references and links.
  func getMessageElements() -> [MessageElement]
}
