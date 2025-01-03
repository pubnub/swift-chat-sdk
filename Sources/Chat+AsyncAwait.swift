//
//  Chat+AsyncAwait.swift
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
/// Extension providing `async-await` support for ``Chat``.
///
public extension Chat {
  /// Initializes the current instance and performs any necessary setup.
  ///
  /// - Returns: The initialized object of ``Chat``
  @discardableResult
  func initialize() async throws -> Self {
    try await withCheckedThrowingContinuation { continuation in
      initialize {
        switch $0 {
        case let .success(instance):
          continuation.resume(returning: instance)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Creates a new user.
  ///
  /// - Parameters:
  ///   - user: A `User` object containing the details of the user to be created.
  /// - Returns: The created ``User`` object
  @discardableResult
  func createUser(user: ChatUserType) async throws -> ChatUserType {
    try await withCheckedThrowingContinuation { continuation in
      createUser(user: user) {
        switch $0 {
        case let .success(user):
          continuation.resume(returning: user)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Creates a new user with a unique User ID.
  ///
  /// - Parameters:
  ///   - id: Unique user identifier. A User ID is a UTF-8 encoded, unique string of up to 92 characters used to identify a single client (end user, device, or server)
  ///   - name: Display name for the user (must not be empty or consist only of whitespace characters)
  ///   - externalId: User's identifier in an external system. You can use it to match id with a similar identifier from an external database
  ///   - profileUrl: URL of the user's profile picture
  ///   - email: User's email address
  ///   - custom: Custom properties or metadata associated with the user in the form of a `[String: JSONCodableScalar]`
  ///   - status: Tag that lets you categorize your app users by their current state. The tag choice is entirely up to you and depends on your use case
  ///   - type: Tag that lets you categorize your app users by their functional roles. The tag choice is entirely up to you and depends on your use case
  /// - Returns: The created ``User`` object
  func createUser(
    id: String,
    name: String? = nil,
    externalId: String? = nil,
    profileUrl: String? = nil,
    email: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    status: String? = nil,
    type: String? = nil
  ) async throws -> ChatUserType {
    try await withCheckedThrowingContinuation { continuation in
      createUser(
        id: id,
        name: name,
        externalId: externalId,
        profileUrl: profileUrl,
        email: email,
        custom: custom,
        status: status,
        type: type
      ) {
        switch $0 {
        case let .success(user):
          continuation.resume(returning: user)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns data about a specific user.
  ///
  /// - Parameter userId: Unique user identifier (up to 92 UTF-8 characters)
  /// - Returns: The ``User`` object, or nil if no user object exists for the given `userId`
  func getUser(userId: String) async throws -> ChatUserType? {
    try await withCheckedThrowingContinuation { continuation in
      getUser(userId: userId) {
        switch $0 {
        case let .success(user):
          continuation.resume(returning: user)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns a paginated list of all users and their details.
  ///
  /// - Parameters:
  ///   - filter: Expression used to filter the results. Returns only these users whose properties satisfy the given expression are returned. The filtering language is defined in [documentation](https://www.pubnub.com/docs/general/metadata/filtering)
  ///   - sort: A collection to specify the sort order
  ///   - limit: Number of objects to return in response
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch
  /// - Returns: A `Tuple` containing an `Array` of users, and the next pagination `PubNubHashedPage` (if one exists)
  func getUsers(
    filter: String? = nil,
    sort: [PubNub.ObjectSortField] = [],
    limit: Int? = nil,
    page: PubNubHashedPage? = nil
  ) async throws -> (users: [ChatUserType], page: PubNubHashedPage?) {
    try await withCheckedThrowingContinuation { continuation in
      getUsers(
        filter: filter,
        sort: sort,
        limit: limit,
        page: page
      ) {
        switch $0 {
        case let .success(getUsersResponse):
          continuation.resume(returning: getUsersResponse)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Updates a user's metadata.
  ///
  /// - Parameters:
  ///   - id: Unique user identifier. A User ID is a UTF-8 encoded, unique string of up to 92 characters used to identify a single client (end user, device, or server)
  ///   - name: Display name for the user (must not be empty or consist only of whitespace characters)
  ///   - externalId: User's identifier in an external system. You can use it to match id with a similar identifier from an external database
  ///   - profileUrl: URL of the user's profile picture
  ///   - email: User's email address
  ///   - custom: Any custom properties or metadata associated with the user in the form of a `[String: JSONCodableScalar]
  ///   - status: Tag that lets you categorize your app users by their current state. The tag choice is entirely up to you and depends on your use case
  ///   - type: Tag that lets you categorize your app users by their functional roles. The tag choice is entirely up to you and depends on your use case
  /// - Returns: Updated user
  @discardableResult
  func updateUser(
    id: String,
    name: String? = nil,
    externalId: String? = nil,
    profileUrl: String? = nil,
    email: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    status: String? = nil,
    type: String? = nil
  ) async throws -> ChatUserType {
    try await withCheckedThrowingContinuation { continuation in
      updateUser(
        id: id,
        name: name,
        externalId: externalId,
        profileUrl: profileUrl,
        email: email,
        custom: custom,
        status: status,
        type: type
      ) {
        switch $0 {
        case let .success(user):
          continuation.resume(returning: user)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Deletes a user with or without deleting its historical data from the App Context storage.
  ///
  /// - Parameters:
  ///   - id: Unique user identifier
  ///   - soft: Decide if you want to permanently remove user metadata
  /// - Returns: For hard delete, the method returns `nil`. Otherwise, an updated ``User`` instance with the status field set to `"deleted"`
  @discardableResult
  func deleteUser(
    id: String,
    soft: Bool = false
  ) async throws -> ChatUserType? {
    try await withCheckedThrowingContinuation { continuation in
      deleteUser(id: id, soft: soft) {
        switch $0 {
        case let .success(user):
          continuation.resume(returning: user)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Retrieves list of channel identifiers where a given user is present.
  ///
  /// - Parameter userId: Unique user identifier
  /// - Returns: An array of channel identifiers
  func wherePresent(userId: String) async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      wherePresent(userId: userId) {
        switch $0 {
        case let .success(channelIdentifiers):
          continuation.resume(returning: channelIdentifiers)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns information if the user is present on a specified channel.
  ///
  /// - Parameters:
  ///   - userId: Unique user identifier
  ///   - channelId: Unique identifier of the channel where you want to check the user's presence
  /// - Returns: A value containing information on whether a given user is present on a specified channel (true) or not (false)
  func isPresent(
    userId: String,
    channelId: String
  ) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      isPresent(userId: userId, channelId: channelId) {
        switch $0 {
        case let .success(isPresent):
          continuation.resume(returning: isPresent)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Fetches details of a specific channel.
  ///
  /// - Parameter channelId: Unique channel identifier (up to 92 UTF-8 byte sequences)
  /// - Returns: A value containing a channel object with its metadata
  func getChannel(channelId: String) async throws -> ChatChannelType? {
    try await withCheckedThrowingContinuation { continuation in
      getChannel(channelId: channelId) {
        switch $0 {
        case let .success(channel):
          continuation.resume(returning: channel)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns a paginated list of all existing channels.
  ///
  /// - Parameters:
  ///   - filter: Expression used to filter the results. Returns only these channels whose properties satisfy the given expression are returned
  ///   - sort: A collection to specify the sort order
  ///   - limit: Number of objects to return in response. The maximum value is 100
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch.
  /// - Returns: A `Tuple` containing an `Array` of channels, and the next pagination `PubNubHashedPage` (if one exists)
  func getChannels(
    filter: String? = nil,
    sort: [PubNub.ObjectSortField] = [],
    limit: Int? = nil,
    page: PubNubHashedPage? = nil
  ) async throws -> (channels: [ChatChannelType], page: PubNubHashedPage?) {
    try await withCheckedThrowingContinuation { continuation in
      getChannels(
        filter: filter,
        sort: sort,
        limit: limit,
        page: page
      ) {
        switch $0 {
        case let .success(getChannelsResponse):
          continuation.resume(returning: getChannelsResponse)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Allows to update the ``Channel`` metadata.
  ///
  /// - Parameters:
  ///   - id: Unique channel identifier
  ///   - name: Display name for the channel
  ///   - custom: Any custom properties or metadata associated with the user in the form of a `[String: JSONCodableScalar]
  ///   - description: Channel description
  ///   - status: Tag that lets you categorize your app users by their current state. The tag choice is entirely up to you and depends on your use case
  ///   - type: Tag that lets you categorize your app users by their functional roles. The tag choice is entirely up to you and depends on your use case
  /// - Returns: A value containing an updated channel and its metadata
  @discardableResult
  func updateChannel(
    id: String,
    name: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    description: String? = nil,
    status: String? = nil,
    type: ChannelType? = nil
  ) async throws -> ChatChannelType {
    try await withCheckedThrowingContinuation { continuation in
      updateChannel(
        id: id,
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

  /// Allows to delete ``Channel`` with or without deleting its historical data from the App Context storage.
  ///
  /// - Parameters:
  ///   - id: Unique channel identifier (up to 92 UTF-8 byte sequences)
  ///   - soft: Decide if you want to permanently remove channel metadata. If you set this parameter to true, the ``Channel`` object gets the deleted status, and you can still restore/get its data
  /// - Returns: For hard delete, the method returns `nil`. Otherwise, an updated ``Channel`` instance with the status field set to `"deleted"`
  @discardableResult
  func deleteChannel(id: String, soft: Bool = false) async throws -> ChatChannelType? {
    try await withCheckedThrowingContinuation { continuation in
      deleteChannel(id: id, soft: soft) {
        switch $0 {
        case let .success(channel):
          continuation.resume(returning: channel)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns a list of ``User`` identifiers present on the given ``Channel``.
  ///
  /// - Parameter channelId: Unique identifier of the channel where you want to check all present users
  /// - Returns: A value containing collection of user identifiers
  func whoIsPresent(channelId: String) async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      whoIsPresent(channelId: channelId) {
        switch $0 {
        case let .success(userIdentifiers):
          continuation.resume(returning: userIdentifiers)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Constructs and sends events with your custom payload.
  ///
  /// - Parameters:
  ///   - channelId: Channel where you want to send the events
  ///   - payload: The payload of the emitted event. Use one of ``EventContent`` subclasses. For example: `EventContent.TextMessageContent`, `EventContent.Mention`
  ///   - otherPayload: Metadata in the form of key-value pairs you want to pass as events from your chat app. Can contain anything in case of custom events, but has a predefined structure for other types of events
  /// - Returns: A `Timetoken` value that holds the timestamp of the emitted event
  func emitEvent(
    channelId: String,
    payload: some EventContent,
    mergePayloadWith otherPayload: [String: JSONCodable]? = nil,
    completion _: ((Swift.Result<Timetoken, Error>) -> Void)?
  ) async throws -> Timetoken {
    try await withCheckedThrowingContinuation { continuation in
      emitEvent(channelId: channelId, payload: payload, mergePayloadWith: otherPayload) {
        switch $0 {
        case let .success(timetoken):
          continuation.resume(returning: timetoken)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Creates a public channel that let users engage in open conversations with many people. Unlike group chats, anyone can join public channels.
  ///
  /// - Parameters:
  ///   - channelId: ID of the public channel. The channel ID is created automatically using the UUID generator. You can override it by providing your own ID
  ///   - channelName: Display name for the channel
  ///   - channelDescription: If you don't provide the name, the channel will get the same name as id (value of `channelId`)
  ///   - channelCustom: Any custom properties or metadata associated with the channel in the form of a map of key-value pairs
  ///   - channelStatus: Current status of the channel, like online, offline, or archived
  /// - Returns: A value containing details about created ``Channel``
  func createPublicConversation(
    channelId: String? = nil,
    channelName: String? = nil,
    channelDescription: String? = nil,
    channelCustom: [String: JSONCodableScalar]? = nil,
    channelStatus: String? = nil
  ) async throws -> ChatChannelType {
    try await withCheckedThrowingContinuation { continuation in
      createPublicConversation(
        channelId: channelId,
        channelName: channelName,
        channelDescription: channelDescription,
        channelCustom: channelCustom,
        channelStatus: channelStatus
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

  /// Creates channel for private conversations between two users, letting one person initiate the chat, letting one person initiate the chat and send an invitation to another person.
  ///
  /// The channel ID is created automatically by a hashing function that takes the string of two user names joined by &, computes a numeric value based on the characters
  /// in that string, and adds the direct prefix in front. For example, `direct.1234567890`. You can override this default value by providing your own ID.
  ///
  /// - Parameters:
  ///   - invitedUser: User that you invite to join a channel
  ///   - channelId: ID of the direct channel
  ///   - channelName: Display name for the channel
  ///   - channelDescription: Additional details about the channel
  ///   - channelCustom: Any custom properties or metadata associated with the channel in the form of a map of key-value pairs
  ///   - channelStatus: Current status of the channel, like online, offline, or archived
  ///   - membershipCustom: Any custom properties or metadata associated with the user-channel membership in the form of a map of key-value pairs
  /// - Returns: A ``CreateDirectConversationResult`` value representing the result of creating a direct conversation (private channel) between two users.
  func createDirectConversation(
    invitedUser: UserImpl,
    channelId: String? = nil,
    channelName: String? = nil,
    channelDescription: String? = nil,
    channelCustom: [String: JSONCodableScalar]? = nil,
    channelStatus: String? = nil,
    membershipCustom: [String: JSONCodableScalar]? = nil
  ) async throws -> CreateDirectConversationResult<ChatChannelType, ChatMembershipType> {
    try await withCheckedThrowingContinuation { continuation in
      createDirectConversation(
        invitedUser: invitedUser,
        channelId: channelId,
        channelName: channelName,
        channelDescription: channelDescription,
        channelCustom: channelCustom,
        channelStatus: channelStatus,
        membershipCustom: membershipCustom
      ) {
        switch $0 {
        case let .success(conversationResult):
          continuation.resume(returning: conversationResult)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Create channel for group communication, promoting collaboration and teamwork.
  ///
  /// - Parameters:
  ///   - invitedUsers: Users that you invite to join a channel
  ///   - channelId: ID of the group channel. The channel ID is created automatically using the UUID generator. You can override it by providing your own ID
  ///   - channelName: Display name for the channel. If you don't provide the name, the channel will get the same name as id (value of channelId)
  ///   - channelDescription: Additional details about the channel
  ///   - channelCustom: Any custom properties or metadata associated with the channel in the form of key-value pairs
  ///   - channelStatus: Current status of the channel, like online, offline, or archived
  ///   - membershipCustom: Any custom properties or metadata associated with the membership in the form of key-value pairs
  /// - Returns: A  ``CreateGroupConversationResult`` value representing the result of creating a group conversation (group channel) for collaborative communication
  func createGroupConversation(
    invitedUsers: [UserImpl],
    channelId: String? = nil,
    channelName: String? = nil,
    channelDescription: String? = nil,
    channelCustom: [String: JSONCodableScalar]? = nil,
    channelStatus: String? = nil,
    membershipCustom: [String: JSONCodableScalar]? = nil
  ) async throws -> CreateGroupConversationResult<ChatChannelType, ChatMembershipType> {
    try await withCheckedThrowingContinuation { continuation in
      createGroupConversation(
        invitedUsers: invitedUsers,
        channelId: channelId,
        channelName: channelName,
        channelDescription: channelDescription,
        channelCustom: channelCustom,
        channelStatus: channelStatus,
        membershipCustom: membershipCustom
      ) {
        switch $0 {
        case let .success(conversationResult):
          continuation.resume(returning: conversationResult)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Lets you watch a selected channel for any new custom events emitted by your chat app.
  ///
  /// - Parameters:
  ///   - type: The type of object that conforms to `EventContent` for which to listen
  ///   - channelId: Channel to listen for new events
  ///   - customMethod: An optional custom method for emitting events
  /// - Returns: An asynchronous stream that produces a value each time a new event of the specified type is detected
  func eventStream<T: EventContent>(
    type: T.Type,
    channelId: String,
    customMethod: EmitEventMethod
  ) -> AsyncStream<EventWrapper<T>> {
    AsyncStream<EventWrapper<T>> { continuation in
      let autoCloseable = listenForEvents(type: type, channelId: channelId, customMethod: customMethod) {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Specifies the channel or channels on which a previously registered device will receive push notifications for new messages.
  ///
  /// - Parameter channels: List of channel identifiers
  func registerPushChannels(channels: [String]) async throws {
    try await withCheckedThrowingContinuation { continuation in
      registerPushChannels(channels: channels) {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Specifies the channel or channels on which a registered device will no longer receive push notifications for new messages.
  ///
  /// - Parameter channels: List of channel identifiers
  func unregisterPushChannels(channels: [String]) async throws {
    try await withCheckedThrowingContinuation { continuation in
      unregisterPushChannels(channels: channels) {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Disable push notifications for a device on all registered channels.
  func unregisterAllPushChannels() async throws {
    try await withCheckedThrowingContinuation { continuation in
      unregisterAllPushChannels {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns info on all messages you didn't read on all joined channels. You can display this number on UI in the channel list of your chat app.
  ///
  /// - Parameters:
  ///   - limit: Number of objects to return in response. The maximum value is 100
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch
  ///   - filter: Expression used to filter the results. Returns only these channels whose properties satisfy the given expression are returned
  ///   - sort: A collection to specify the sort order
  /// - Returns: An array of ``GetUnreadMessagesCount`` representing unread messages for the current user in a given channel
  func getUnreadMessagesCount(
    limit: Int? = nil,
    page: PubNubHashedPage? = nil,
    filter: String? = nil,
    sort: [PubNub.MembershipSortField] = []
  ) async throws -> [GetUnreadMessagesCount<ChannelImpl, MembershipImpl>] {
    try await withCheckedThrowingContinuation { continuation in
      getUnreadMessagesCount(
        limit: limit,
        page: page,
        filter: filter,
        sort: sort
      ) {
        switch $0 {
        case let .success(unreadMessagesCount):
          continuation.resume(returning: unreadMessagesCount)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Allows you to mark as read all messages you didn't read on all joined channels.
  ///
  /// - Parameters:
  ///   - limit: Number of objects to return in response. The maximum value is 100
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch
  ///   - filter: Expression used to filter the results. Returns only these channels whose properties satisfy the given expression are returned
  ///   - sort: A collection to specify the sort order
  /// - Returns: A `Tuple` containing an `Array` of memberships, and the next pagination `PubNubHashedPage` (if one exists)
  func markAllMessagesAsRead(
    limit: Int? = nil,
    page: PubNubHashedPage? = nil,
    filter: String? = nil,
    sort: [PubNub.MembershipSortField] = [],
    completion _: ((Swift.Result<(memberships: [ChatMembershipType], page: PubNubHashedPage?), Error>) -> Void)?
  ) async throws -> (memberships: [ChatMembershipType], page: PubNubHashedPage?) {
    try await withCheckedThrowingContinuation { continuation in
      markAllMessagesAsRead(
        limit: limit,
        page: page,
        filter: filter,
        sort: sort
      ) {
        switch $0 {
        case let .success(result):
          continuation.resume(returning: result)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Retrieves all channels where your registered device receives push notifications.
  ///
  /// - Returns: An array of channel identifiers
  func getPushChannels() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      getPushChannels {
        switch $0 {
        case let .success(channelIdentifiers):
          continuation.resume(returning: channelIdentifiers)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns historical events that were emitted with the `EmitEventMethod.publish` method on selected ``Channel``.
  ///
  /// - Parameters:
  ///   - channelId: Channel from which you want to pull historical messages
  ///   - startTimetoken: Timetoken delimiting the start of a time slice (exclusive) to pull events from. For details, refer to the History section of PubNub Swift SDK
  ///   - endTimetoken: Timetoken delimiting the end of a time slice (inclusive) to pull events from.  For details, refer to the History section of PubNub Swift SDK
  ///   - count: Number of historical events to return for the channel in a single call. You can pull a maximum number of 100 events in a single call
  /// - Returns: A `Tuple` containing an `Array` of events, and boolean indicating whether there are more events available beyond the current result set
  func getEventsHistory(
    channelId: String,
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion _: ((Swift.Result<(events: [EventWrapper<EventContent>], isMore: Bool), Error>) -> Void)?
  ) async throws -> (events: [EventWrapper<EventContent>], isMore: Bool) {
    try await withCheckedThrowingContinuation { continuation in
      getEventsHistory(
        channelId: channelId,
        startTimetoken: startTimetoken,
        endTimetoken: endTimetoken,
        count: count
      ) {
        switch $0 {
        case let .success(result):
          continuation.resume(returning: result)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns all instances when a specific user was mentioned by someone - either in channels or threads.
  ///
  /// - Parameters:
  ///   - startTimetoken: Timetoken delimiting the start of a time slice (exclusive) to pull messages with mentions from. For details, refer to the History section of PubNub Swift SDK
  ///   - endTimetoken: Timetoken delimiting the end of a time slice (inclusive) to pull messages with mentions from. For details, refer to the History section of PubNub Swift SDK
  ///   - count: Number of users to return in a single call. You can pull a maximum number of 100 users in a single call
  /// - Returns: A `Tuple` containing an `Array` of ``UserMentionDataWrapper``, and boolean indicating whether there are more events available beyond the current result set
  func getCurrentUserMentions(
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion _: ((Swift.Result<(mentions: [UserMentionDataWrapper<ChatMessageType>], isMore: Bool), Error>) -> Void)?
  ) async throws -> (mentions: [UserMentionDataWrapper<ChatMessageType>], isMore: Bool) {
    try await withCheckedThrowingContinuation { continuation in
      getCurrentUserMentions(
        startTimetoken: startTimetoken,
        endTimetoken: endTimetoken,
        count: count
      ) {
        switch $0 {
        case let .success(result):
          continuation.resume(returning: result)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}

extension ChatImpl {
  func createChannel(
    id: String,
    name: String? = nil,
    description: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    type: ChannelType? = nil,
    status: String? = nil
  ) async throws -> ChannelImpl {
    try await withCheckedThrowingContinuation { continuation in
      createChannel(id: id, name: name, description: description, custom: custom, type: type, status: status) {
        switch $0 {
        case let .success(channel):
          continuation.resume(returning: channel)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  // swiftlint:disable:next file_length
}
