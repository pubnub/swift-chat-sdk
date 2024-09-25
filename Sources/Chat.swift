//
//  Chat.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK
import Combine

/// To communicate with PubNub, you can use various methods on ``Chat`` object. For example, you can use ``deleteChannel(id:soft:completion:)``
/// to remove a given channel or ``wherePresent(userId:completion:)`` to check which channels a given user is subscribed to.
///
/// By calling methods on the ``Chat`` entity, you create chat objects like ``Channel``, ``User``, ``Message``, ``Membership``,  ``ThreadChannel``,
/// and ``ThreadMessage``. These objects also expose Chat API under various methods, letting you perform CRUD operations
/// on messages, channels, users, the related user-channel membership, and many more
public protocol Chat: AnyObject {
  associatedtype ChatUserType: User
  associatedtype ChatChannelType: Channel
  associatedtype ChatThreadChannelType: ThreadChannel
  associatedtype ChatMembershipType: Membership
  associatedtype ChatMessageType: Message
  associatedtype ChatThreadMessageType: ThreadMessage

  /// Contains chat app configuration settings, such as ``LogLevel`` or typing timeout
  /// that you can provide when initializing your chat app with the init method
  var config: ChatConfiguration { get }
  /// Allows you to access any Swift SDK method. For example, if you want to call a method available in the
  /// App Context API, you'd use `pubNub.allUUIDMetadata(include:filter:sort:limit:page:custom:completion)`
  var pubNub: PubNub { get }
  /// Object representing current user
  var currentUser: ChatUserType { get }
  /// The name of the action that represents editing a message.
  var editMessageActionName: String { get }
  /// The name of the action that represents deleting a message.
  var deleteMessageActionName: String { get }

  /// Initializes the current instance and performs any necessary setup
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The initialization succeeded and returns the instance
  ///     - **Failure**: The initialization failed and returns an error.
  func initialize(
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  /// Creates a new user
  ///
  /// - Parameters:
  ///   - user: A `User` object containing the details of the user to be created.
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The user was successfully created and returns the created user
  ///     - **Failure**: An `Error` describing the failure
  func createUser(
    user: ChatUserType,
    completion: ((Swift.Result<ChatUserType, Error>) -> Void)?
  )

  /// Creates a new user with a unique User ID
  /// - Parameters:
  ///   - id: Unique user identifier. A User ID is a UTF-8 encoded, unique string of up to 92 characters used to identify a single client (end user, device, or server)
  ///   - name: Display name for the user (must not be empty or consist only of whitespace characters)
  ///   - externalId: User's identifier in an external system. You can use it to match id with a similar identifier from an external database
  ///   - profileUrl: URL of the user's profile picture
  ///   - email: User's email address
  ///   - custom: Custom properties or metadata associated with the user in the form of a `[String: JSONCodableScalar]`
  ///   - status: Tag that lets you categorize your app users by their current state. The tag choice is entirely up to you and depends on your use case
  ///   - type: Tag that lets you categorize your app users by their functional roles. The tag choice is entirely up to you and depends on your use case
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The user was successfully created and returns the created user
  ///     - **Failure**: An `Error` describing the failure
  func createUser(
    id: String,
    name: String?,
    externalId: String?,
    profileUrl: String?,
    email: String?,
    custom: [String: JSONCodableScalar]?,
    status: String?,
    type: String?,
    completion: ((Swift.Result<ChatUserType, Error>) -> Void)?
  )

  /// Returns data about a specific user.
  ///
  /// - Parameters:
  ///   - userId: Unique user identifier (up to 92 UTF-8 characters).
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The user was successfully returned
  ///     - **Failure**: An `Error` describing the failure
  func getUser(
    userId: String,
    completion: ((Swift.Result<ChatUserType?, Error>) -> Void)?
  )

  /// Returns a paginated list of all users and their details
  ///
  /// - Parameters:
  ///   - filter: Expression used to filter the results. Returns only these users whose properties satisfy the given expression are returned. The filtering language is defined in [documentation](https://www.pubnub.com/docs/general/metadata/filtering)
  ///   - sort: A collection to specify the sort order
  ///   - limit: Number of objects to return in response
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an `Array` of users, and the next pagination `PubNubHashedPage` (if one exists)
  ///     - **Failure**: An `Error` describing the failure
  func getUsers(
    filter: String?,
    sort: [PubNub.ObjectSortField],
    limit: Int?,
    page: PubNubHashedPage?,
    completion: ((Swift.Result<(users: [ChatUserType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  
  /// Updates a user's metadata
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
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: Updated user
  ///     - **Failure**: An `Error` describing the failure
  func updateUser(
    id: String,
    name: String?,
    externalId: String?,
    profileUrl: String?,
    email: String?,
    custom: [String: JSONCodableScalar]?,
    status: String?,
    type: String?,
    completion: ((Swift.Result<ChatUserType, Error>) -> Void)?
  )

  /// Deletes a user with or without deleting its historical data from the App Context storage
  ///
  /// - Parameters:
  ///   - id: Unique user identifier
  ///   - soft: Decide if you want to permanently remove user metadata
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A value containing user object
  ///     - **Failure**: An `Error` describing the failure
  func deleteUser(
    id: String,
    soft: Bool,
    completion: ((Swift.Result<ChatUserType, Error>) -> Void)?
  )

  
  /// Retrieves list of channel identifiers where a given user is present
  ///
  /// - Parameters:
  ///   - userId: Unique user identifier
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: An array of channel identifiers
  ///     - **Failure**: An `Error` describing the failure
  func wherePresent(
    userId: String,
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  
  /// Returns information if the user is present on a specified channel
  ///
  /// - Parameters:
  ///   - userId: Unique user identifier
  ///   - channelId: Unique identifier of the channel where you want to check the user's presence
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A value containing information on whether a given user is present on a specified channel (true) or not (false)
  ///     - **Failure**: An `Error` describing the failure
  func isPresent(
    userId: String,
    channelId: String,
    completion: ((Swift.Result<Bool, Error>) -> Void)?
  )

  func createChannel(
    id: String,
    name: String?,
    description: String?,
    custom: [String: JSONCodableScalar]?,
    type: ChannelType?,
    status: String?,
    completion: ((Swift.Result<ChatChannelType, Error>) -> Void)?
  )

  
  /// Fetches details of a specific channel.

  /// - Parameters:
  ///   - channelId: Unique channel identifier (up to 92 UTF-8 byte sequences)
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A value containing channel object with its metadata
  ///     - **Failure**: An `Error` describing the failure
  func getChannel(
    channelId: String,
    completion: ((Swift.Result<ChatChannelType?, Error>) -> Void)?
  )

  
  func getChannels(
    filter: String?,
    sort: [PubNub.ObjectSortField],
    limit: Int?,
    page: PubNubHashedPage?,
    completion: ((Swift.Result<(channels: [ChatChannelType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  func updateChannel(
    id: String,
    name: String?,
    custom: [String: JSONCodableScalar]?,
    description: String?,
    status: String?,
    type: ChannelType?,
    completion: ((Swift.Result<ChatChannelType, Error>) -> Void)?
  )

  func deleteChannel(
    id: String,
    soft: Bool,
    completion: ((Swift.Result<ChatChannelType, Error>) -> Void)?
  )

  func forwardMessage(
    message: ChatMessageType,
    channelId: String,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  func whoIsPresent(
    channelId: String,
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  func emitEvent<T: EventContent>(
    channelId: String,
    payload: T,
    mergePayloadWith otherPayload: [String: JSONCodable]?,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  func createPublicConversation(
    channelId: String?,
    channelName: String?,
    channelDescription: String?,
    channelCustom: [String: JSONCodableScalar]?,
    channelStatus: String?,
    completion: ((Swift.Result<ChatChannelType, Error>) -> Void)?
  )

  func createDirectConversation(
    invitedUser: UserImpl,
    channelId: String?,
    channelName: String?,
    channelDescription: String?,
    channelCustom: [String: JSONCodableScalar]?,
    channelStatus: String?,
    membershipCustom: [String: JSONCodableScalar]?,
    completion: ((Swift.Result<CreateDirectConversationResult<ChatChannelType, ChatMembershipType>, Error>) -> Void)?
  )

  func createGroupConversation(
    invitedUsers: [UserImpl],
    channelId: String?,
    channelName: String?,
    channelDescription: String?,
    channelCustom: [String: JSONCodableScalar]?,
    channelStatus: String?,
    membershipCustom: [String: JSONCodableScalar]?,
    completion: ((Swift.Result<CreateGroupConversationResult<ChatChannelType, ChatMembershipType>, Error>) -> Void)?
  )

  func listenForEvents<T: EventContent>(
    type: T.Type,
    channelId: String,
    customMethod: EmitEventMethod,
    callback: @escaping ((EventWrapper<T>) -> Void)
  ) -> AutoCloseable

  func registerPushChannels(
    channels: [String],
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func unregisterPushChannels(
    channels: [String],
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func unregisterAllPushChannels(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func getThreadChannel(
    message: ChatMessageType,
    completion: ((Swift.Result<ChatThreadChannelType, Error>) -> Void)?
  )

  func getUnreadMessagesCount(
    limit: Int?,
    page: PubNubHashedPage?,
    filter: String?,
    sort: [PubNub.MembershipSortField],
    completion: ((Swift.Result<[GetUnreadMessagesCount<ChannelImpl, MembershipImpl>], Error>) -> Void)?
  )

  func markAllMessagesAsRead(
    limit: Int?,
    page: PubNubHashedPage?,
    filter: String?,
    sort: [PubNub.MembershipSortField],
    completion: ((Swift.Result<(memberships: [ChatMembershipType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  func getChannelSuggestions(
    text: String,
    limit: Int,
    completion: ((Swift.Result<[ChatChannelType], Error>) -> Void)?
  )

  func getUserSuggestions(
    text: String,
    limit: Int,
    completion: ((Swift.Result<[ChatUserType], Error>) -> Void)?
  )

  func getPushChannels(
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  func getEventsHistory(
    channelId: String,
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(events: [EventWrapper<EventContent>], isMore: Bool), Error>) -> Void)?
  )

  func getCurrentUserMentions(
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(mentions: [UserMentionDataWrapper<ChatMessageType>], isMore: Bool), Error>) -> Void)?
  )

  func destroy()
}
