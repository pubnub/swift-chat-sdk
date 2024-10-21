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

/// Channel is an object that refers to a single chat room.
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
  /// Represents the type of the given ``Channel``
  var type: ChannelType? { get }

  /// Receive updates when specific channels are added, edited or removed.
  ///
  /// - Parameters:
  ///   - channels: Collection containing the channels to watch for updates
  ///   - callback: Defines the custom behavior to be executed when detecting channels changes
  /// - Returns: An ``AutoCloseable`` that you can use to stop receiving objects events by invoking its `close()` method
  static func streamUpdatesOn(
    channels: [Self],
    callback: @escaping (([Self]) -> Void)
  ) -> AutoCloseable

  /// Allows to update the ``Channel`` metadata.
  ///
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

  /// Allows to delete  an existing ``Channel`` with or without deleting its historical data from the App Context storage.
  ///
  /// - Parameters:
  ///   - soft: Decide if you want to permanently remove channel metadata
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: For hard delete, the method returns the last version of the ``Channel`` object before it was permanently deleted. Otherwise, an updated ``Channel`` instance with the status field set to `"deleted"`
  ///     - **Failure**: An `Error` describing the failure
  func delete(
    soft: Bool,
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  /// Forwards a message to existing channel.
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

  /// Deactivates a typing indicator on a given channel.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func stopTyping(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  /// Enables continuous tracking of typing activity within the ``Channel``.
  ///
  /// - Parameter callback: Callback function passed as a parameter. It defines the custom behavior to be executed whenever a user starts/stops typin
  /// - Returns: ``AutoCloseable`` you can call to disconnect (unsubscribe) from the channel and stop receiving signal events for someone typing by invoking the `close()` method
  func getTyping(
    callback: @escaping (([String]) -> Void)
  ) -> AutoCloseable

  /// Returns a list of users present on the ``Channel``.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A collection of strings representing `userId`
  ///     - **Failure**: An `Error` describing the failure
  func whoIsPresent(
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  /// Returns information if the user is present on the ``Channel``.
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

  /// Returns historical messages for the ``Channel``.
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

  /// Sends text to the ``Channel``.
  ///
  /// The following example describes how `mentionedUsers` and `referencedChannels` work.
  /// For example, `{ 0: { id: 123, name: "Mark" }, 2: { id: 345, name: "Rob" } }` means that Mark will be shown on the first mention (@) in the message
  /// and Rob on the third. The same rule applies for referenced channels. For example, `{ 0: { id: 123, name: "Support" }, 2: { id: 345, name: "Off-topic" } }`
  /// means that Support will be shown on the first reference in the message and Off-topic on the third.
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

  /// Sends text to the ``Channel``.
  ///
  /// The following example describes how `mentionedUsers` and `referencedChannels` work.
  /// For example, `{ 0: { id: 123, name: "Mark" }, 2: { id: 345, name: "Rob" } }` means that Mark will be shown on the first mention (@) in the message
  /// and Rob on the third. The same rule applies for referenced channels. For example, `{ 0: { id: 123, name: "Support" }, 2: { id: 345, name: "Off-topic" } }`
  /// means that Support will be shown on the first reference in the message and Off-topic on the third.
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
    usersToMention: [String]?,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  /// Requests another user to join a channel (except public channel) and become its member.
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

  /// Requests other users to join a channel and become its members. You can invite up to 100 users at once.
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

  /// Returns the list of all channel members.
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

  /// Watch the ``Channel`` content without a need to join the ``Channel``.
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

  /// Remove user's channel membership.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func leave(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  /// Fetches the message that is currently pinned to the channel.
  ///
  /// There can be only one pinned message on a channel at a time.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A pinned ``Message``
  ///     - **Failure**: An `Error` describing the failure
  func getPinnedMessage(
    completion: ((Swift.Result<(ChatType.ChatMessageType)?, Error>) -> Void)?
  )

  /// Fetches the message from Message Persistence based on the message `timetoken`.
  ///
  /// - Parameters:
  ///   - timetoken: Timetoken of the message you want to retrieve from Message Persistence
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A message object (if any)
  ///     - **Failure**: An `Error` describing the failure
  func getMessage(
    timetoken: Timetoken,
    completion: ((Swift.Result<(ChatType.ChatMessageType)?, Error>) -> Void)?
  )

  /// Register a device on the ``Channel`` to receive push notifications. Push options can be configured in ``ChatConfiguration``.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func registerForPush(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  /// Unregister a device from the ``Channel``.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func unregisterFromPush(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  /// Attaches messages to the ``Channel``. Replace an already pinned message.
  ///
  /// There can be only one pinned message on a channel at a time.
  ///
  /// - Parameters:
  ///   - message: Message that you want to pin to the selected channel
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A channel with updated `custom` field
  ///     - **Failure**: An `Error` describing the failure
  func pinMessage(
    message: ChatType.ChatMessageType,
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  /// Unpins a message from the ``Channel``.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A channel with updated `custom` field
  ///     - **Failure**: An `Error` describing the failure
  func unpinMessage(
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  /// Receives updates on a single ``Channel`` object.
  ///
  /// - Parameter callback: Function that takes a single Channel object. It defines the custom behavior to be executed when detecting channel changes
  /// - Returns: ``AutoCloseable`` interface that lets you stop receiving channel-related updates (objects events) and clean up resources by invoking the `close()` method
  func streamUpdates(
    callback: @escaping ((ChatType.ChatChannelType)?) -> Void
  ) -> AutoCloseable

  /// Lets you get a read confirmation status for messages you published on a channel.
  ///
  /// - Parameter callback: Defines the custom behavior to be executed when receiving a read confirmation status on the joined channel.
  /// - Returns: AutoCloseable Interface you can call to stop listening for message read receipts and clean up resources by invoking the close() method
  func streamReadReceipts(
    callback: @escaping (([Timetoken: [String]]) -> Void)
  ) -> AutoCloseable

  /// Returns all files attached to messages on a given channel.
  ///
  /// - Parameters:
  ///   - limit: Number of files to return
  ///   - next: Token to get the next batch of files
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an array of ``GetFileItem``, and the next pagination `PubNubHashedPage` (if one exists)
  ///     - **Failure**: An `Error` describing the failure
  func getFiles(
    limit: Int,
    next: String?,
    completion: ((Swift.Result<(files: [GetFileItem], page: PubNubHashedPage?), Error>) -> Void)?
  )

  /// Delete sent files or files from published messages.
  ///
  /// - Parameters:
  ///   - id: Unique identifier assigned to the file by `PubNub`
  ///   - name: Name of the file
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func deleteFile(
    id: String,
    name: String,
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  /// Enables real-time tracking of users connecting to or disconnecting from a ``Channel``.
  ///
  /// - Parameter callback: Defines the custom behavior to be executed when detecting user presence event
  /// - Returns: ``AutoCloseable`` interface that lets you stop receiving presence-related updates (presence events) by invoking the `close()` method
  func streamPresence(
    callback: @escaping (Set<String>) -> Void
  ) -> AutoCloseable

  /// Fetches all suggested users that match the provided 3-letter string from ``Channel``.
  ///
  /// - Parameters:
  ///   - text: At least a 3-letter string typed in after `@` with the user name you want to mention
  ///   - limit: Maximum number of returned usernames that match the typed 3-letter suggestion
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: An array of matching memberships
  ///     - **Failure**: An `Error` describing the failure
  func getUserSuggestions(
    text: String,
    limit: Int,
    completion: ((Swift.Result<[ChatType.ChatMembershipType], Error>) -> Void)?
  )

  /// Fetches a list of reported message events for ``Channel`` within optional time and count constraints.
  ///
  /// - Parameters:
  ///   - startTimetoken: The start timetoken for fetching the history of reported messages, which allows specifying the point in time where the history retrieval should begin
  ///   - endTimetoken: The end time token for fetching the history of reported messages, which allows specifying the point in time where the history retrieval should end
  ///   - count: The number of reported message events to fetch from the history
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an array of `EventWrapper<EventContent>`, and a boolean indicating whether there are more messages available beyond the current result set
  ///     - **Failure**: An `Error` describing the failure
  func getMessageReportsHistory(
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(events: [EventWrapper<EventContent>], isMore: Bool), Error>) -> Void)?
  )

  /// As an admin of your chat app, monitor all events emitted when someone reports an offensive message.
  ///
  /// - Parameter callback: Callback function passed as a parameter. It defines the custom behavior to be executed when detecting new message report events
  /// - Returns: ``AutoCloseable`` interface that lets you stop receiving report-related updates (report events) by invoking the close() method
  func streamMessageReports(
    callback: @escaping (any Event<EventContent.Report>) -> Void
  ) -> AutoCloseable

  /// Creates a ``MessageDraft`` for composing a message that will be sent to this ``Channel``
  ///
  /// - Parameters:
  ///   - userSuggestionSource: The scope for searching for suggested users
  ///   - isTypingIndicatorTriggered: Whether modifying the message text triggers the typing indicator on channel
  ///   - userLimit: The limit on the number of users returned when searching for users to mention
  ///   - channelLimit: The limit on the number of channels returned when searching for channels to reference
  func createMessageDraft(
    userSuggestionSource: UserSuggestionSource,
    isTypingIndicatorTriggered: Bool,
    userLimit: Int,
    channelLimit: Int
  ) -> any MessageDraft

  // swiftlint:disable:next file_length
}
