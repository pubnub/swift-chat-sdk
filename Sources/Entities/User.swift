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
public protocol User {
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
  /// Timestamp for the last time the user information was updated or modified
  var lastActiveTimestamp: TimeInterval? { get }

  /// Receive updates when specific users are added, edited or removed.
  ///
  /// - Parameters:
  ///   - users: Collection containing the users to watch for updates
  ///   - callback: Defines the custom behavior to be executed when detecting users changes
  /// - Returns: An ``AutoCloseable`` that you can use to stop receiving objects events by invoking its `close()` method
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
  ///     - **Success**: The updated user object with its metadata
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

  /// Deletes the user. If soft deletion is enabled, the user's data is retained but marked as inactive.
  ///
  /// - Parameters:
  ///   - soft: If true, the user is soft deleted, retaining their data but making them inactive
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: For hard delete, the method returns the last version of the ``User`` object before it was permanently deleted. Otherwise, an updated ``User`` instance with the status field set to `"deleted"`
  ///     - **Failure**: An `Error` describing the failure
  func delete(
    soft: Bool,
    completion: ((Swift.Result<ChatType.ChatUserType, Error>) -> Void)?
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
  /// - Parameters:
  ///   - callback: A function that is triggered whenever the user's information are changed (added, edited, or removed)
  /// - Returns: An ``AutoCloseable`` that you can use to stop receiving objects events by invoking its `close()` method
  func streamUpdates(
    callback: @escaping ((ChatType.ChatUserType?) -> Void)
  ) -> AutoCloseable

  /// Checks if the user is currently active.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A boolean value indicating whether the user is active
  ///     - **Failure**: An `Error` describing the failure
  func active(
    completion: ((Swift.Result<Bool, Error>) -> Void)?
  )
}
