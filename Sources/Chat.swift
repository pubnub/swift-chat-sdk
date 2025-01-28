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

/// A protocol that defines the basic structure and behavior for a chat.
///
/// For example, you can use ``deleteChannel(id:soft:completion:)``
/// to remove a given channel or ``wherePresent(userId:completion:)`` to check which channels a given user is subscribed to.
///
/// By calling methods on the ``Chat`` entity, you create chat objects like ``Channel``, ``User``, ``Message``, ``Membership``,  ``ThreadChannel``,
/// and ``ThreadMessage``. These objects also expose Chat API under various methods, letting you perform CRUD operations
/// on messages, channels, users, the related user-channel membership, and many more.
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
  /// A type of action added to your Message object whenever a published message is edited, like "changed" or "modified". The default value is "edited"
  var editMessageActionName: String { get }
  /// A type of action added to your Message object whenever a published message is deleted, like "removed". The default value is "deleted"
  var deleteMessageActionName: String { get }
  /// A type of action you added to your Message object whenever a reaction is added to a published message, like "reacted". The default value is "reactions"
  var reactionsActionName: String { get }

  /// An object for manipulating the list of muted users.
  ///
  /// The list is local to this instance of Chat (it is not persisted anywhere) unless ``ChatConfiguration/syncMutedUsers`` is enabled, in which case it will be synced
  /// using App Context for the current user.
  ///
  /// Please note that this is not a server-side moderation mechanism, but rather a way to ignore messages from certain users on the client.
  var mutedUsersManager: MutedUsersManagerInterface { get }

  /// Initializes the current instance and performs any necessary setup.
  ///
  /// This method must be called before invoking any other operations
  /// in order to ensure the SDK is properly initialized.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The initialization succeeded and returns the instance
  ///     - **Failure**: The initialization failed and returns an error.
  func initialize(
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

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

  /// Returns a paginated list of all users and their details.
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

  /// Deletes a user with or without deleting its historical data from the App Context storage.
  ///
  /// - Parameters:
  ///   - id: Unique user identifier
  ///   - soft: Decide if you want to permanently remove user metadata
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: For hard delete, the method returns `nil`. Otherwise, an updated ``User`` instance with the status field set to `"deleted"`
  ///     - **Failure**: An `Error` describing the failure
  func deleteUser(
    id: String,
    soft: Bool,
    completion: ((Swift.Result<ChatUserType?, Error>) -> Void)?
  )

  /// Retrieves list of channel identifiers where a given user is present.
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

  /// Returns information if the user is present on a specified channel.
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

  /// Fetches details of a specific channel.
  ///
  /// - Parameters:
  ///   - channelId: Unique channel identifier (up to 92 UTF-8 byte sequences)
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A value containing a channel object with its metadata
  ///     - **Failure**: An `Error` describing the failure
  func getChannel(
    channelId: String,
    completion: ((Swift.Result<ChatChannelType?, Error>) -> Void)?
  )

  /// Returns a paginated list of all existing channels.
  ///
  /// - Parameters:
  ///   - filter: Expression used to filter the results. Returns only these channels whose properties satisfy the given expression are returned
  ///   - sort: A collection to specify the sort order
  ///   - limit: Number of objects to return in response. The maximum value is 100
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch.
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an `Array` of channels, and the next pagination `PubNubHashedPage` (if one exists)
  ///     - **Failure**: An `Error` describing the failure
  func getChannels(
    filter: String?,
    sort: [PubNub.ObjectSortField],
    limit: Int?,
    page: PubNubHashedPage?,
    completion: ((Swift.Result<(channels: [ChatChannelType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  /// Allows to update the ``Channel`` metadata.
  ///
  /// - Parameters:
  ///   - id: Unique channel identifier
  ///   - name: Display name for the channel
  ///   - custom: Any custom properties or metadata associated with the user in the form of a `[String: JSONCodableScalar]
  ///   - description: Channel description
  ///   - status: Tag that lets you categorize your app users by their current state. The tag choice is entirely up to you and depends on your use case
  ///   - type: Tag that lets you categorize your app users by their functional roles. The tag choice is entirely up to you and depends on your use case
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A value containing an updated channel and its metadata
  ///     - **Failure**: An `Error` describing the failure
  func updateChannel(
    id: String,
    name: String?,
    custom: [String: JSONCodableScalar]?,
    description: String?,
    status: String?,
    type: ChannelType?,
    completion: ((Swift.Result<ChatChannelType, Error>) -> Void)?
  )

  /// Allows to delete ``Channel`` with or without deleting its historical data from the App Context storage.
  ///
  /// - Parameters:
  ///   - id: Unique channel identifier (up to 92 UTF-8 byte sequences)
  ///   - soft: Decide if you want to permanently remove channel metadata. If you set this parameter to true, the ``Channel`` object gets the deleted status, and you can still restore/get its data
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: For hard delete, the method returns `nil`. Otherwise, an updated ``Channel`` instance with the status field set to `"deleted"`
  ///     - **Failure**: An `Error` describing the failure
  func deleteChannel(
    id: String,
    soft: Bool,
    completion: ((Swift.Result<ChatChannelType?, Error>) -> Void)?
  )

  /// Returns a list of ``User`` identifiers present on the given ``Channel``.
  ///
  /// - Parameters:
  ///   - channelId: Unique identifier of the channel where you want to check all present users
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A value containing collection of user identifiers
  ///     - **Failure**: An `Error` describing the failure
  func whoIsPresent(
    channelId: String,
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  /// Constructs and sends events with your custom payload.
  ///
  /// - Parameters:
  ///   - channelId: Channel where you want to send the events
  ///   - payload: The payload of the emitted event. Use one of ``EventContent`` subclasses. For example: `EventContent.TextMessageContent`, `EventContent.Mention`
  ///   - otherPayload: Metadata in the form of key-value pairs you want to pass as events from your chat app. Can contain anything in case of custom events, but has a predefined structure for other types of events
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Timetoken` value that holds the timestamp of the emitted event
  ///     - **Failure**: An `Error` describing the failure
  func emitEvent<T: EventContent>(
    channelId: String,
    payload: T,
    mergePayloadWith otherPayload: [String: JSONCodable]?,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  /// Creates a public channel that let users engage in open conversations with many people. Unlike group chats, anyone can join public channels.
  ///
  /// - Parameters:
  ///   - channelId: ID of the public channel. The channel ID is created automatically using the UUID generator. You can override it by providing your own ID
  ///   - channelName: Display name for the channel
  ///   - channelDescription: If you don't provide the name, the channel will get the same name as id (value of `channelId`)
  ///   - channelCustom: Any custom properties or metadata associated with the channel in the form of a map of key-value pairs
  ///   - channelStatus: Current status of the channel, like online, offline, or archived
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A value containing details about created ``Channel``
  ///     - **Failure**: An `Error` describing the failure
  func createPublicConversation(
    channelId: String?,
    channelName: String?,
    channelDescription: String?,
    channelCustom: [String: JSONCodableScalar]?,
    channelStatus: String?,
    completion: ((Swift.Result<ChatChannelType, Error>) -> Void)?
  )

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
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A ``CreateDirectConversationResult`` value representing the result of creating a direct conversation (private channel) between two users.
  ///     - **Failure**: An `Error` describing the failure
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
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A  ``CreateGroupConversationResult`` value representing the result of creating a group conversation (group channel) for collaborative communication
  ///     - **Failure**: An `Error` describing the failure
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

  /// Lets you watch a selected channel for any new custom events emitted by your chat app.
  ///
  /// - Parameters:
  ///   - type: The type of object that conforms to `EventContent` for which to listen
  ///   - channelId: Channel to listen for new events
  ///   - customMethod: An optional custom method for emitting events
  ///   - callback: A function that is called with an ``EventWrapper`` as its parameter. It defines the custom behavior to be executed whenever an event is detected on the specified channel
  /// - Returns: ``AutoCloseable`` interface you can call to stop listening for new events and clean up resources when they re no longer needed by invoking the `close()` method
  func listenForEvents<T: EventContent>(
    type: T.Type,
    channelId: String,
    customMethod: EmitEventMethod,
    callback: @escaping ((EventWrapper<T>) -> Void)
  ) -> AutoCloseable

  /// Specifies the channel or channels on which a previously registered device will receive push notifications for new messages.
  ///
  /// - Parameters:
  ///   - channels: List of channel identifiers
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func registerPushChannels(
    channels: [String],
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  /// Specifies the channel or channels on which a registered device will no longer receive push notifications for new messages.
  ///
  /// - Parameters:
  ///   - channels: List of channel identifiers
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func unregisterPushChannels(
    channels: [String],
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  /// Disable push notifications for a device on all registered channels.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func unregisterAllPushChannels(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  /// Returns info on all messages you didn't read on all joined channels. You can display this number on UI in the channel list of your chat app.
  ///
  /// - Parameters:
  ///   - limit: Number of objects to return in response. The maximum value is 100
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch
  ///   - filter: Expression used to filter the results. Returns only these channels whose properties satisfy the given expression are returned
  ///   - sort: A collection to specify the sort order
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: An array of ``GetUnreadMessagesCount`` representing unread messages for the current user in a given channel
  ///     - **Failure**: An `Error` describing the failure
  func getUnreadMessagesCount(
    limit: Int?,
    page: PubNubHashedPage?,
    filter: String?,
    sort: [PubNub.MembershipSortField],
    completion: ((Swift.Result<[GetUnreadMessagesCount<ChannelImpl, MembershipImpl>], Error>) -> Void)?
  )

  /// Allows you to mark as read all messages you didn't read on all joined channels.
  ///
  /// - Parameters:
  ///   - limit: Number of objects to return in response. The maximum value is 100
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch
  ///   - filter: Expression used to filter the results. Returns only these channels whose properties satisfy the given expression are returned
  ///   - sort: A collection to specify the sort order
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an `Array` of memberships, and the next pagination `PubNubHashedPage` (if one exists)
  ///     - **Failure**: An `Error` describing the failure
  func markAllMessagesAsRead(
    limit: Int?,
    page: PubNubHashedPage?,
    filter: String?,
    sort: [PubNub.MembershipSortField],
    completion: ((Swift.Result<(memberships: [ChatMembershipType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  /// Retrieves all channels where your registered device receives push notifications.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: An array of channel identifiers
  ///     - **Failure**: An `Error` describing the failure
  func getPushChannels(
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  /// Returns historical events that were emitted with the `EmitEventMethod.publish` method on selected ``Channel``.
  ///
  /// - Parameters:
  ///   - channelId: Channel from which you want to pull historical messages
  ///   - startTimetoken: Timetoken delimiting the start of a time slice (exclusive) to pull events from. For details, refer to the History section of PubNub Swift SDK
  ///   - endTimetoken: Timetoken delimiting the end of a time slice (inclusive) to pull events from.  For details, refer to the History section of PubNub Swift SDK
  ///   - count: Number of historical events to return for the channel in a single call. You can pull a maximum number of 100 events in a single call
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an `Array` of events, and boolean indicating whether there are more events available beyond the current result set
  ///     - **Failure**: An `Error` describing the failure
  func getEventsHistory(
    channelId: String,
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(events: [EventWrapper<EventContent>], isMore: Bool), Error>) -> Void)?
  )

  /// Returns all instances when a specific user was mentioned by someone - either in channels or threads.
  ///
  /// - Parameters:
  ///   - startTimetoken: Timetoken delimiting the start of a time slice (exclusive) to pull messages with mentions from. For details, refer to the History section of PubNub Swift SDK
  ///   - endTimetoken: Timetoken delimiting the end of a time slice (inclusive) to pull messages with mentions from. For details, refer to the History section of PubNub Swift SDK
  ///   - count: Number of users to return in a single call. You can pull a maximum number of 100 users in a single call
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an `Array` of ``UserMentionDataWrapper``, and boolean indicating whether there are more events available beyond the current result set
  ///     - **Failure**: An `Error` describing the failure
  func getCurrentUserMentions(
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(mentions: [UserMentionDataWrapper<ChatMessageType>], isMore: Bool), Error>) -> Void)?
  )

  /// Clears resources of chat instance and related PubNub SDK instance.
  func destroy()

  // swiftlint:disable:next file_length
}
