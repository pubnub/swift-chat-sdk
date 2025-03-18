//
//  Channel+AsyncAwait.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

///
/// Extension providing `async-await` support for ``Channel``.
///
public extension Channel {
  /// Receive updates when specific channels are added, edited or removed.
  ///
  /// - Parameter channels: Collection containing the channels to watch for updates
  /// - Returns: An asynchronous stream that produces updates when any item in the `channels` collection is updated
  static func streamUpdatesOn(channels: [Self]) -> AsyncStream<[Self]> {
    AsyncStream { continuation in
      let autoCloseable = streamUpdatesOn(channels: channels) {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Allows to update the ``Channel`` metadata.
  ///
  /// - Parameters:
  ///   - name: Display name for the channel
  ///   - custom:  Any custom properties or metadata associated with the channel in the form key-value pairs
  ///   - description: Additional details about the channel
  ///   - status: Current status of the channel, like online, offline, or archived
  ///   - type: Represents the type of channel
  /// - Returns: The updated channel object with its metadata
  func update(
    name: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    description: String? = nil,
    status: String? = nil,
    type: ChannelType? = nil
  ) async throws -> ChatType.ChatChannelType {
    try await withCheckedThrowingContinuation { continuation in
      update(
        name: name,
        custom: custom,
        description: description,
        status: status,
        type: type
      ) {
        switch $0 {
        case let .success(channel):
          continuation.resume(returning: channel)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Allows to delete  an existing ``Channel`` with or without deleting its historical data from the App Context storage.
  ///
  /// - Parameter soft: Decide if you want to permanently remove channel metadata
  /// - Returns: For hard delete, the method returns `nil`. Otherwise, an updated ``Channel`` instance with the status field set to `"deleted"`
  func delete(soft: Bool = false) async throws -> ChatType.ChatChannelType? {
    try await withCheckedThrowingContinuation { continuation in
      delete(soft: soft) {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Forwards a message to existing channel.
  ///
  /// - Parameters:
  ///   - message: Message object that you want to forward to the channel
  /// - Returns: A timetoken value of the forwarded message
  @discardableResult
  func forward(message: ChatType.ChatMessageType) async throws -> Timetoken {
    try await withCheckedThrowingContinuation { continuation in
      forward(message: message) {
        switch $0 {
        case let .success(timetoken):
          continuation.resume(returning: timetoken)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Activates a typing indicator on a given channel.
  ///
  /// The method sets a flag (typingSent) to indicate that a typing signal is in progress and adds a timer to reset
  /// the flag after a specified timeout. You can change the default typing timeout and set your own value during the Chat SDK configuration (init() method)
  /// using the `typingTimeout` parameter
  ///
  /// - Returns: A `Timetoken` indicating the action timestamp
  @discardableResult
  func startTyping() async throws -> Timetoken? {
    try await withCheckedThrowingContinuation { continuation in
      startTyping {
        switch $0 {
        case let .success(timetoken):
          continuation.resume(returning: timetoken)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Deactivates a typing indicator on a given channel.
  ///
  /// - Returns: A `Timetoken` indicating the action timestamp
  @discardableResult
  func stopTyping() async throws -> Timetoken? {
    try await withCheckedThrowingContinuation { continuation in
      stopTyping {
        switch $0 {
        case let .success(timetoken):
          continuation.resume(returning: timetoken)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Enables continuous tracking of typing activity within the ``Channel``.
  ///
  /// - Returns: An asynchronous stream producing typing user identifiers
  func getTyping() -> AsyncStream<[String]> {
    AsyncStream { continuation in
      let autoCloseable = getTyping {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Returns a list of users present on the ``Channel``.
  ///
  /// - Returns: A collection of strings representing `userId`
  func whoIsPresent() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      whoIsPresent {
        switch $0 {
        case let .success(collection):
          continuation.resume(returning: collection)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns information if the user is present on the ``Channel``.
  ///
  /// - Returns: A boolean value informing if a given user is present on a specified  channel
  func isPresent(userId: String) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      isPresent(userId: userId) {
        switch $0 {
        case let .success(isPresent):
          continuation.resume(returning: isPresent)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns historical messages for the ``Channel``.
  ///
  /// - Parameters:
  ///   - startTimetoken: The start value for the set of remote data
  ///   - endTimetoken: The bounded end value that will be eventually fetched to
  ///   - count: The maximum number of messages to retrieve
  /// - Returns: A `Tuple` containing an array of messages, and a boolean indicating whether there are more messages available beyond the current result set
  func getHistory(
    startTimetoken: Timetoken? = nil,
    endTimetoken: Timetoken? = nil,
    count: Int = 25
  ) async throws -> (messages: [MessageType], isMore: Bool) {
    try await withCheckedThrowingContinuation { continuation in
      getHistory(startTimetoken: startTimetoken, endTimetoken: endTimetoken, count: count) {
        switch $0 {
        case let .success((messages, isMore)):
          continuation.resume(returning: (messages: messages, isMore: isMore))
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Sends text to the ``Channel``.
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
  /// - Returns: The timetoken of the sent message
  @discardableResult
  func sendText(
    text: String,
    meta: [String: JSONCodable]? = nil,
    shouldStore: Bool = true,
    usePost: Bool = false,
    ttl: Int? = nil,
    quotedMessage: ChatType.ChatMessageType? = nil,
    files: [InputFile]? = nil,
    usersToMention: [String]? = nil,
    customPushData: [String: String]? = nil
  ) async throws -> Timetoken {
    try await withCheckedThrowingContinuation { continuation in
      sendText(
        text: text,
        meta: meta,
        shouldStore: shouldStore,
        usePost: usePost,
        ttl: ttl,
        quotedMessage: quotedMessage,
        files: files,
        usersToMention: usersToMention,
        customPushData: customPushData
      ) {
        switch $0 {
        case let .success(timetoken):
          continuation.resume(returning: timetoken)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Requests another user to join a channel (except public channel) and become its member.
  ///
  /// - Parameter user: A user that you want to invite to a channel
  /// - Returns: List of ``Membership`` of invited users
  @discardableResult
  func invite(user: ChatType.ChatUserType) async throws -> ChatType.ChatMembershipType {
    try await withCheckedThrowingContinuation { continuation in
      invite(user: user) {
        switch $0 {
        case let .success(membership):
          continuation.resume(returning: membership)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Requests other users to join a channel and become its members. You can invite up to 100 users at once.
  ///
  /// - Parameters:
  ///   - users: List of users you want to invite to the ``Channel``. You can invite up to 100 users in one call
  ///   - completion: List of ``Membership`` of invited users
  @discardableResult
  func inviteMultiple(users: [ChatType.ChatUserType]) async throws -> [ChatType.ChatMembershipType] {
    try await withCheckedThrowingContinuation { continuation in
      inviteMultiple(users: users) {
        switch $0 {
        case let .success(membership):
          continuation.resume(returning: membership)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns the list of all channel members.
  ///
  /// - Parameters:
  ///   - limit: Number of objects to return in response
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch
  ///   - filter: Expression used to filter the results. Returns only these members whose properties satisfy the given expression
  ///   - sort: A collection to specify the sort order. Available options are id, name, and updated
  ///   - completion: A `Tuple` containing an array of the members of the channel, and the next pagination `PubNubHashedPage` (if one exists)
  func getMembers(
    limit: Int? = nil,
    page: PubNubHashedPage? = nil,
    filter: String? = nil,
    sort: [PubNub.MembershipSortField] = []
  ) async throws -> (memberships: [ChatType.ChatMembershipType], page: PubNubHashedPage?) {
    try await withCheckedThrowingContinuation { continuation in
      getMembers(limit: limit, page: page, filter: filter, sort: sort) {
        switch $0 {
        case let .success(getMembersResult):
          continuation.resume(returning: getMembersResult)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Watch the ``Channel`` content without a need to join the ``Channel``.
  ///
  /// - Parameter callback: Defines the custom behavior to be executed whenever a message is received on the ``Channel``
  /// - Returns: An asynchronous stream that produces a new value every time a new message is published on the current channel
  func connect() -> AsyncStream<ChatType.ChatMessageType> {
    AsyncStream { continuation in
      let autoCloseable = connect {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Connects a user to the ``Channel`` and sets membership - this way, the chat user can both watch the channel's content and be its full-fledged member.
  ///
  /// - Warning: Keep a strong reference to the returned `AsyncStream` to ensure your subscription to the current channel remains active and you continue to receive messages.
  ///  You can skip this strong reference if you are only interested in being a full-fledged member of the current channel and not in receiving real-time updates.
  ///
  /// - Parameters:
  ///   - custom: Any custom properties or metadata associated with the channel-user membership in the form of key-value pairs
  /// - Returns: A `Tuple` containing the user's membership in the channel, and an asynchronous stream that produces a new value every time a new message is published on the current channel
  @discardableResult
  func join(
    custom: [String: JSONCodableScalar]? = nil
  ) async throws -> (
    membership: ChatType.ChatMembershipType,
    messageStream: AsyncStream<ChatType.ChatMessageType>
  ) {
    let messageStream = connect()

    return try await withCheckedThrowingContinuation { continuation in
      join(custom: custom, callback: nil) {
        switch $0 {
        case let .success(joinResult):
          joinResult.disconnect?.close()
          continuation.resume(returning: (membership: joinResult.membership, messageStream))
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Remove user's channel membership.
  func leave() async throws {
    try await withCheckedThrowingContinuation { continuation in
      leave {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Fetches the message that is currently pinned to the channel.
  ///
  /// There can be only one pinned message on a channel at a time.
  ///
  /// - Returns: A pinned ``Message``
  func getPinnedMessage() async throws -> ChatType.ChatMessageType? {
    try await withCheckedThrowingContinuation { continuation in
      getPinnedMessage {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Fetches the message from Message Persistence based on the message `timetoken`.
  ///
  /// - Parameter timetoken: Timetoken of the message you want to retrieve from Message Persistence
  /// - Returns: A message object (if any)
  func getMessage(timetoken: Timetoken) async throws -> ChatType.ChatMessageType? {
    try await withCheckedThrowingContinuation { continuation in
      getMessage(timetoken: timetoken) {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Register a device on the ``Channel`` to receive push notifications. Push options can be configured in ``ChatConfiguration``.
  func registerForPush() async throws {
    try await withCheckedThrowingContinuation { continuation in
      registerForPush {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Unregister a device from the ``Channel``.
  func unregisterFromPush() async throws {
    try await withCheckedThrowingContinuation { continuation in
      unregisterFromPush {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Attaches messages to the ``Channel``. Replace an already pinned message.
  ///
  /// There can be only one pinned message on a channel at a time.
  ///
  /// - Parameters: message: Message that you want to pin to the selected channel
  /// - Returns: A channel with updated `custom` field
  func pinMessage(message: MessageType) async throws -> Self {
    try await withCheckedThrowingContinuation { continuation in
      pinMessage(message: message) {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Unpins a message from the ``Channel``.
  ///
  /// - Returns: A channel with updated `custom` field
  func unpinMessage() async throws -> Self {
    try await withCheckedThrowingContinuation { continuation in
      unpinMessage {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Receives updates on a single ``Channel`` object.
  ///
  /// - Returns: An asynchronous stream that produces updates when the current Channel is edited or removed.
  func streamUpdates() -> AsyncStream<ChatType.ChatChannelType?> {
    AsyncStream { continuation in
      let autoCloseable = streamUpdates {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Lets you get a read confirmation status for messages you published on a channel.
  func streamReadReceipts() -> AsyncStream<[Timetoken: [String]]> {
    AsyncStream { continuation in
      let autoCloseable = streamReadReceipts {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Returns all files attached to messages on a given channel.
  ///
  /// - Parameters:
  ///   - limit: Number of files to return
  ///   - next: Token to get the next batch of files
  /// - Returns: A `Tuple` containing an array of ``GetFileItem``, and the next pagination `PubNubHashedPage` (if one exists)
  func getFiles(
    limit: Int = 100,
    next: String? = nil
  ) async throws -> (files: [GetFileItem], page: PubNubHashedPage?) {
    try await withCheckedThrowingContinuation { continuation in
      getFiles(limit: limit, next: next) {
        switch $0 {
        case let .success(getFilesResult):
          continuation.resume(returning: getFilesResult)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Delete sent files or files from published messages.
  ///
  /// - Parameters:
  ///   - id: Unique identifier assigned to the file by `PubNub`
  ///   - name: Name of the file
  func deleteFile(
    id: String,
    name: String
  ) async throws {
    try await withCheckedThrowingContinuation { continuation in
      deleteFile(id: id, name: name) {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Enables real-time tracking of users connecting to or disconnecting from a ``Channel``.
  func streamPresence() -> AsyncStream<Set<String>> {
    AsyncStream { continuation in
      let autoCloseable = streamPresence {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Fetches all suggested users that match the provided 3-letter string from ``Channel``.
  ///
  /// - Parameters:
  ///   - text: At least a 3-letter string typed in after `@` with the user name you want to mention
  ///   - limit: Maximum number of returned usernames that match the typed 3-letter suggestion
  /// - Returns: An array of matching memberships
  func getUserSuggestions(
    text: String,
    limit: Int = 10
  ) async throws -> [ChatType.ChatMembershipType] {
    try await withCheckedThrowingContinuation { continuation in
      getUserSuggestions(text: text, limit: limit) {
        switch $0 {
        case let .success(memberships):
          continuation.resume(returning: memberships)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

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
    startTimetoken: Timetoken? = nil,
    endTimetoken: Timetoken? = nil,
    count: Int = 25
  ) async throws -> (
    events: [EventWrapper<EventContent>],
    isMore: Bool
  ) {
    try await withCheckedThrowingContinuation { continuation in
      getMessageReportsHistory(startTimetoken: startTimetoken, endTimetoken: endTimetoken, count: count) {
        switch $0 {
        case let .success(reportsTuple):
          continuation.resume(returning: reportsTuple)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// As an admin of your chat app, monitor all events emitted when someone reports an offensive message.
  func streamMessageReports() -> AsyncStream<EventWrapper<EventContent.Report>> {
    AsyncStream { continuation in
      let autoCloseable = streamMessageReports {
        continuation.yield(EventWrapper(event: $0))
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  // swiftlint:disable:next file_length
}
