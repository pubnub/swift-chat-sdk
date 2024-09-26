//
//  Channel.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Channel is an object that refers to a single chat room
public protocol Channel {
  associatedtype ChatType: Chat
  associatedtype MessageType: Message

  /// Reference to the main Chat object
  var chat: ChatType { get }
  /// Unique identifier for the channel
  var id: String { get }
  /// Display name or title of the channel
  var name: String? { get }
  /// Any custom properties or metadata associated with the channel in the form of a map of key-value pairs
  var custom: [String: JSONCodableScalar]? { get }
  /// Brief description or summary of the channel's purpose or content
  var description: String? { get }
  /// The last updated timestamp for the object
  var updated: String? { get }
  /// Current status of the channel, like online, offline, or archived
  var status: String? { get }
  /// Represents the type of channel
  var type: ChannelType? { get }

  /// Receive updates when specific channels are added, edited or removed
  /// 
  /// - Parameters:
  ///   - channels: Collection containing the channels to watch for updates
  ///   - callback: Defines the custom behavior to be executed when detecting channels changes
  /// - Returns: An ``AutoCloseable`` that you can use to stop receiving objects events by invoking its `close()` method
  static func streamUpdatesOn(
    channels: [Self],
    callback: @escaping (([Self]) -> Void)
  ) -> AutoCloseable

  /// Allows to update the ``Channel`` metadata
  /// - Parameters:
  ///   - name: Display name for the channel
  ///   - custom:  Any custom properties or metadata associated with the channel in the form key-value pairs
  ///   - description: Additional details about the channel
  ///   - status: Current status of the channel, like online, offline, or archived
  ///   - type: Represents the type of channel
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The updated channel object with its metadata
  ///     - **Failure**: An `Error` describing the failure
  func update(
    name: String?,
    custom: [String: JSONCodableScalar]?,
    description: String?,
    status: String?,
    type: ChannelType?,
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  /// Allows to delete  an existing ``Channel`` (with or without deleting its historical data from the App Context storage)
  /// - Parameters:
  ///   - soft: Decide if you want to permanently remove channel metadata
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: For hard delete, the method returns the last version of the ``Channel`` object before it was permanently deleted. Otherwise, an updated ``Channel`` instance with the status field set to `"deleted"`
  ///     - **Failure**: An `Error` describing the failure
  func delete(
    soft: Bool,
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  /// Forwards a message to existing channel
  ///
  /// - Parameters:
  ///   - message: Message object that you want to forward to the channel
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A timetoken value of the forwarded message
  ///     - **Failure**: An `Error` describing the failure
  func forward(
    message: ChatType.ChatMessageType,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  /// Activates a typing indicator on a given channel.
  ///
  /// The method sets a flag (typingSent) to indicate that a typing signal is in progress and adds a timer to reset
  /// the flag after a specified timeout. You can change the default typing timeout and set your own value during the Chat SDK configuration (init() method)
  /// using the `typingTimeout` parameter
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func startTyping(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  /// Deactivates a typing indicator on a given channel
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func stopTyping(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  /// Enables continuous tracking of typing activity within the ``Channel``
  ///
  /// - Parameter callback: Callback function passed as a parameter. It defines the custom behavior to be executed whenever a user starts/stops typin
  /// - Returns: ``AutoCloseable`` you can call to disconnect (unsubscribe) from the channel and stop receiving signal events for someone typing by invoking the `close()` method
  func getTyping(
    callback: @escaping (([String]) -> Void)
  ) -> AutoCloseable

  /// Returns a list of users present on the ``Channel``
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A collection of strings representing `userId`
  ///     - **Failure**: An `Error` describing the failure
  func whoIsPresent(
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  /// Returns information if the user is present on the ``Channel``
  ///
  /// - Parameters:
  ///   - userId: ID of the user whose presence you want to check
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A boolean value informing if a given user is present on a specified  channel
  ///     - **Failure**: An `Error` describing the failure
  func isPresent(
    userId: String,
    completion: ((Swift.Result<Bool, Error>) -> Void)?
  )

  /// Returns historical messages for the ``Channel``
  /// 
  /// - Parameters:
  ///   - startTimetoken: The start value for the set of remote data
  ///   - endTimetoken: The bounded end value that will be eventually fetched to
  ///   - count: The maximum number of messages to retrieve
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an array of messages, and a boolean indicating whether there are more messages available beyond the current result set
  ///     - **Failure**: An `Error` describing the failure
  func getHistory(
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(messages: [MessageType], isMore: Bool), Error>) -> Void)?
  )

  /// Sends text to the ``Channel``
  ///
  /// The following example describes how `mentionedUsers` and `referencedChannels` work.
  /// For example, `{ 0: { id: 123, name: "Mark" }, 2: { id: 345, name: "Rob" } }` means that Mark will be shown on the first mention (@) in the message
  /// and Rob on the third. The same rule applies for referenced channels. For example, `{ 0: { id: 123, name: "Support" }, 2: { id: 345, name: "Off-topic" } }`
  /// means that Support will be shown on the first reference in the message and Off-topic on the third
  ///
  /// - Parameters:
  ///   - text: Text that you want to send to the selected channel
  ///   - meta: Publish additional details with the request
  ///   - shouldStore: If true, the messages are stored in Message Persistence if enabled in Admin Portal
  ///   - usePost: Use HTTP POST
  ///   - ttl: Defines if/how long (in hours) the message should be stored in Message Persistence
  ///   - mentionedUsers: Object mapping a mentioned user (with name and ID) with the number of mention (like `@Mar`) in the message (relative to other user mentions).
  ///   - referencedChannels: Object mapping the referenced channel (with name and ID) with the place (Int) where this reference (like `#Sup`) was mentioned in the message (relative to other channel references)
  ///   - textLinks: Returned list of text links that are shown as text in the message
  ///   - quotedMessage: Object added to a message when you quote another message
  ///   - files: One or multiple files attached to the text message
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The timetoken of the sent message
  ///     - **Failure**: An `Error` describing the failure
  @available(*, deprecated, message: "Will be removed from SDK in the future")
  func sendText(
    text: String,
    meta: [String: JSONCodable]?,
    shouldStore: Bool,
    usePost: Bool,
    ttl: Int?,
    mentionedUsers: MessageMentionedUsers?,
    referencedChannels: MessageReferencedChannels?,
    textLinks: [TextLink]?,
    quotedMessage: ChatType.ChatMessageType?,
    files: [InputFile]?,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  /// Sends text to the ``Channel``
  ///
  /// - Parameters:
  ///   - text: Text that you want to send to the selected channel
  ///   - meta: Publish additional details with the request
  ///   - shouldStore: If true, the messages are stored in Message Persistence if enabled in Admin Portal
  ///   - usePost: Use HTTP POST
  ///   - ttl: Defines if/how long (in hours) the message should be stored in Message Persistence
  ///   - quotedMessage: Object added to a message when you quote another message
  ///   - files: One or multiple files attached to the text message
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The timetoken of the sent message
  ///     - **Failure**: An `Error` describing the failure
  func sendText(
    text: String,
    meta: [String: JSONCodable]?,
    shouldStore: Bool,
    usePost: Bool,
    ttl: Int?,
    quotedMessage: ChatType.ChatMessageType?,
    files: [InputFile]?,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  /// Requests another user to join a channel (except public channel) and become its member
  ///
  /// - Parameters:
  ///   - user: A user that you want to invite to a channel
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: List of ``Membership`` of invited users
  ///     - **Failure**: An `Error` describing the failure
  func invite(
    user: ChatType.ChatUserType,
    completion: ((Swift.Result<ChatType.ChatMembershipType, Error>) -> Void)?
  )

  /// Requests other users to join a channel and become its members. You can invite up to 100 users at once
  ///
  /// - Parameters:
  ///   - users: List of users you want to invite to the ``Channel``. You can invite up to 100 users in one call
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: List of ``Membership`` of invited users
  ///     - **Failure**: An `Error` describing the failure
  func inviteMultiple(
    users: [ChatType.ChatUserType],
    completion: ((Swift.Result<[ChatType.ChatMembershipType], Error>) -> Void)?
  )

  /// Returns the list of all channel members
  ///
  /// - Parameters:
  ///   - limit: Number of objects to return in response
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch
  ///   - filter: Expression used to filter the results. Returns only these members whose properties satisfy the given expression
  ///   - sort: A collection to specify the sort order. Available options are id, name, and updated
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an array of the members of the channel, and the next pagination `PubNubHashedPage` (if one exists)
  ///     - **Failure**: An `Error` describing the failure
  func getMembers(
    limit: Int?,
    page: PubNubHashedPage?,
    filter: String?,
    sort: [PubNub.MembershipSortField],
    completion: ((Swift.Result<(memberships: [ChatType.ChatMembershipType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  /// Watch the ``Channel`` content without a need to join the Channel
  ///
  /// - Parameter callback: Defines the custom behavior to be executed whenever a message is received on the ``Channel``
  /// - Returns: ``AutoCloseable`` interface you can call to stop listening for new messages and clean up resources when they are no longer needed by invoking the `close()` method
  func connect(
    callback: @escaping (ChatType.ChatMessageType) -> Void
  ) -> AutoCloseable

  /// Connects a user to the ``Channel`` and sets membership - this way, the chat user can both watch the channel's ontent and be its full-fledged member.
  ///
  /// - Parameters:
  ///   - custom: Any custom properties or metadata associated with the channel-user membership in the form of key-value pairs
  ///   - callback: Defines the custom behavior to be executed whenever a message is received on the [Channel]
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an array of the members of the channel, and ``AutoCloseable`` that  lets you stop listening to new channel messages while remaining a channel membership
  ///     - **Failure**: An `Error` describing the failure
  func join(
    custom: [String: JSONCodableScalar]?,
    callback: ((ChatType.ChatMessageType) -> Void)?,
    completion: ((Swift.Result<(membership: ChatType.ChatMembershipType, disconnect: AutoCloseable?), Error>) -> Void)?
  )

  /// Remove user's channel membership
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func leave(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func getPinnedMessage(
    completion: ((Swift.Result<(ChatType.ChatMessageType)?, Error>) -> Void)?
  )

  func getMessage(
    timetoken: Timetoken,
    completion: ((Swift.Result<(ChatType.ChatMessageType)?, Error>) -> Void)?
  )

  func registerForPush(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func unregisterFromPush(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func pinMessage(
    message: ChatType.ChatMessageType,
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  func unpinMessage(
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  func streamUpdates(
    callback: @escaping ((ChatType.ChatChannelType)?) -> Void
  ) -> AutoCloseable

  func streamReadReceipts(
    callback: @escaping (([Timetoken: [String]]) -> Void)
  ) -> AutoCloseable

  func getFiles(
    limit: Int,
    next: String?,
    completion: ((Swift.Result<(files: [GetFileItem], page: PubNubHashedPage?), Error>) -> Void)?
  )

  func deleteFile(
    id: String,
    name: String,
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func streamPresence(
    callback: @escaping (Set<String>) -> Void
  ) -> AutoCloseable

  func getUserSuggestions(
    text: String,
    limit: Int,
    completion: ((Swift.Result<[ChatType.ChatMembershipType], Error>) -> Void)?
  )

  func getMessageReportsHistory(
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(events: [EventWrapper<EventContent>], isMore: Bool), Error>) -> Void)?
  )

  func streamMessageReports(
    callback: @escaping (any Event<EventContent.Report>) -> Void
  ) -> AutoCloseable
}

// MARK: - ThreadChannel

public protocol ThreadChannel: Channel {
  var parentChannelId: String { get }
  var parentMessage: ChatType.ChatMessageType { get }

  func pinMessageToParentChannel(
    message: ChatType.ChatThreadMessageType,
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  func unpinMessageFromParentChannel(
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )
}
