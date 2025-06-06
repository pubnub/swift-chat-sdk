//
//  User.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Represents an object that refers to a single user in a chat, including details about the user's identity, metadata, and actions they can perform.
public protocol User: CustomStringConvertible {
  associatedtype ChatType: Chat

  /// Reference to the main chat object
  var chat: ChatType { get }
  /// Unique identifier for user
  var id: String { get }
  /// Display name or username of the user (must not be empty or consist only of whitespace characters)
  var name: String? { get }
  /// Identifier for the user from an external system, such as a third-party authentication provider or a user directory
  var externalId: String? { get }
  /// URL to the user's profile or avatar image
  var profileUrl: String? { get }
  /// User's email address
  var email: String? { get }
  /// Any custom properties or metadata associated with the user in the form of a map of key-value pairs
  var custom: [String: JSONCodableScalar]? { get }
  /// Current status of the user, like online, offline, or away
  var status: String? { get }
  /// Type of the user, like admin, member, guest
  var type: String? { get }
  /// The last updated timestamp for the object
  var updated: String? { get }
  /// The entity tag (`ETag`) that was returned by the server with this User object. It is a random string that changes with each data update.
  var eTag: String? { get }
  /// Timestamp for the last time the user information was updated or modified
  var lastActiveTimestamp: TimeInterval? { get }
  /// Indicates whether the user is currently (at the time of obtaining this ``User`` object) active
  var active: Bool { get }

  /// Receive updates when specific users are added, edited or removed.
  ///
  /// - Important: Keep a strong reference to the returned ``AutoCloseable`` object as long as you want to receive updates. If ``AutoCloseable`` is deallocated,
  /// the stream will be canceled, and no further items will be produced. You can also stop receiving updates manually by calling ``AutoCloseable/close()``.
  ///
  /// - Parameters:
  ///   - users: Collection containing the users to watch for updates
  ///   - callback: Defines the custom behavior to be executed when detecting users changes
  /// - Returns: An ``AutoCloseable`` that you can use to stop receiving objects events by invoking its ``AutoCloseable/close()`` method
  static func streamUpdatesOn(
    users: [ChatType.ChatUserType],
    callback: @escaping (([ChatType.ChatUserType]) -> Void)
  ) -> AutoCloseable

  /// Updates the metadata of the user with the provided details.
  ///
  /// - Parameters:
  ///   - name: The new name for the user
  ///   - externalId: The new external ID for the user
  ///   - profileUrl: The new profile image URL for the user
  ///   - email: The new email address for the user
  ///   - custom: A map of custom properties or metadata for the user
  ///   - status: The new status of the user (e.g., online, offline)
  ///   - type: The new type of the user (e.g., admin, member)
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The updated ``User`` object with its metadata
  ///     - **Failure**: An `Error` describing the failure
  func update(
    name: String?,
    externalId: String?,
    profileUrl: String?,
    email: String?,
    custom: [String: JSONCodableScalar]?,
    status: String?,
    type: String?,
    completion: ((Swift.Result<ChatType.ChatUserType, Error>) -> Void)?
  )

  /// Updates the metadata of the user with information provided in `updateAction`
  ///
  /// Please note that `updateAction` will be called **at least** once with the current data from the `User` object in
  /// the argument. Inside `updateAction`, new values for `User` fields should be computed and returned as a closure result.
  ///
  /// In case the user's information has changed on the server since the original User object was retrieved, the `updateAction` will be called again
  /// with new User data that represents the current server state. This might happen multiple times until either new data is saved successfully, or the request fails.
  ///
  /// - Parameters:
  ///   - updateAction: A function for computing new values for the `User` fields based on the provided `User` argument and returning changes to apply
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The updated ``User`` object with its metadata
  ///     - **Failure**: An `Error` describing the failure
  func update(
    updateAction: @escaping (ChatType.ChatUserType) -> [PubNubMetadataChange<PubNubUserMetadata>],
    completion: ((Swift.Result<ChatType.ChatUserType, Error>) -> Void)?
  )

  /// Deletes the user. If soft deletion is enabled, the user's data is retained but marked as inactive.
  ///
  /// - Parameters:
  ///   - soft: If true, the user is soft deleted, retaining their data but making them inactive
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: For hard delete, the method returns `nil`. Otherwise, an updated ``User`` instance with the status field set to `"deleted"`
  ///     - **Failure**: An `Error` describing the failure
  func delete(
    soft: Bool,
    completion: ((Swift.Result<ChatType.ChatUserType?, Error>) -> Void)?
  )

  /// Retrieves a list of channels where the user is currently present.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A list of channel IDs where the user is present
  ///     - **Failure**: An `Error` describing the failure
  func wherePresent(
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  /// Checks whether the user is present in the specified channel.
  ///
  /// - Parameters:
  ///   - channelId: The ID of the channel to check for the user's presence
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A boolean value indicating whether the user is present in the specified channel
  ///     - **Failure**: An `Error` describing the failure
  func isPresentOn(
    channelId: String,
    completion: ((Swift.Result<Bool, Error>) -> Void)?
  )

  /// Retrieves the memberships associated with the user across different channels.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of memberships to retrieve
  ///   - page: Pagination information for retrieving memberships
  ///   - filter: An expression to filter the retrieved memberships
  ///   - sort: A collection of sort keys to determine the sort order of the memberships
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an `Array` of memberships, and the next pagination `PubNubHashedPage` (if one exists)
  ///     - **Failure**: An `Error` describing the failure
  func getMemberships(
    limit: Int?,
    page: PubNubHashedPage?,
    filter: String?,
    sort: [PubNub.MembershipSortField],
    completion: ((Swift.Result<(memberships: [ChatType.ChatMembershipType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  /// Receives updates on a single User object.
  ///
  /// - Important: Keep a strong reference to the returned ``AutoCloseable`` object as long as you want to receive updates. If ``AutoCloseable`` is deallocated,
  /// the stream will be canceled, and no further items will be produced. You can also stop receiving updates manually by calling ``AutoCloseable/close()``.
  ///
  /// - Parameters:
  ///   - callback: A function that is triggered whenever the user's information are changed (added, edited, or removed)
  /// - Returns: An ``AutoCloseable`` that you can use to stop receiving objects events by invoking its ``AutoCloseable/close()`` method
  func streamUpdates(
    callback: @escaping ((ChatType.ChatUserType?) -> Void)
  ) -> AutoCloseable

  /// Checks if the user is currently active.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A boolean value indicating whether the user is active
  ///     - **Failure**: An `Error` describing the failure
  @available(*, deprecated, renamed: "active", message: "Use non-async `active` property instead")
  func active(
    completion: ((Swift.Result<Bool, Error>) -> Void)?
  )
}

/// Extension to conform to `CustomStringConvertible` for custom string representation.
/// Provides a readable description of the object for debugging and logging purposes
public extension User {
  var description: String {
    String.formattedDescription(
      self, arguments: [
        ("id", id),
        ("name", name ?? "nil"),
        ("externalId", externalId ?? "nil"),
        ("profileUrl", profileUrl ?? "nil"),
        ("email", email ?? "nil"),
        ("custom", custom ?? "nil"),
        ("status", status ?? "nil"),
        ("type", type ?? "nil"),
        ("updated", updated ?? "nil"),
        ("eTag", eTag ?? "nil"),
        ("lastActiveTimestamp", lastActiveTimestamp ?? "nil"),
        ("active", active)
      ]
    )
  }
}
