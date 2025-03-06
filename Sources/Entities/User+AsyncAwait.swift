//
//  User+AsyncAwait.swift
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
/// Extension providing `async-await` support for ``User``.
///
public extension User {
  /// Receive updates when specific users are added, edited or removed.
  ///
  /// - Parameters:
  ///   - users: Collection containing the users to watch for updates
  /// - Returns: An asynchronous stream that produces updates when any item in the `users` collection is updated
  static func streamUpdatesOn(users: [ChatType.ChatUserType]) -> AsyncStream<[ChatType.ChatUserType]> {
    AsyncStream { continuation in
      let autoCloseable = streamUpdatesOn(users: users) {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

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
  /// - Returns: The updated user object with its metadata
  @discardableResult
  func update(
    name: String? = nil,
    externalId: String? = nil,
    profileUrl: String? = nil,
    email: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    status: String? = nil,
    type: String? = nil
  ) async throws -> ChatType.ChatUserType {
    try await withCheckedThrowingContinuation { continuation in
      update(
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

  /// Updates the metadata of the user with information provided in `updateAction`
  ///
  /// Please note that `updateAction` will be called **at least** once with the current data from the `User` object in
  /// the argument. Inside `updateAction`, new values for `User` fields should be computed and returned as a closure result.
  ///
  /// In case the user's information has changed on the server since the original User object was retrieved, the `updateAction` will be called again
  /// with new User data that represents the current server state. This might happen multiple times until either new data is saved successfully, or the request fails.
  ///
  /// - Parameter updateAction: A function for computing new values for the `User` fields based on the provided `User` argument and returning changes to apply
  /// - Returns: The updated user object with its metadata
  func update(
    updateAction: @escaping (ChatType.ChatUserType) -> [PubNubMetadataChange<PubNubUserMetadata>]
  ) async throws -> ChatType.ChatUserType {
    try await withCheckedThrowingContinuation { continuation in
      update(updateAction: updateAction) {
        switch $0 {
        case let .success(user):
          continuation.resume(returning: user)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Deletes the user. If soft deletion is enabled, the user's data is retained but marked as inactive.
  ///
  /// - Parameter soft: If true, the user is soft deleted, retaining their data but making them inactive
  /// - Returns: Returns `nil` if the user was hard-deleted. Otherwise, an updated ``User`` instance with the status field set to `"deleted"`
  func delete(soft: Bool = false) async throws -> ChatType.ChatUserType? {
    try await withCheckedThrowingContinuation { continuation in
      delete(soft: soft) {
        switch $0 {
        case let .success(user):
          continuation.resume(returning: user)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Retrieves a list of channels where the user is currently present.
  ///
  /// - Returns: A list of channel IDs where the user is present
  func wherePresent() async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      wherePresent {
        switch $0 {
        case let .success(channelIdentifiers):
          continuation.resume(returning: channelIdentifiers)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Checks whether the user is present in the specified channel.
  ///
  /// - Parameter channelId: The ID of the channel to check for the user's presence
  /// - Returns: A boolean value indicating whether the user is present in the specified channel
  func isPresentOn(channelId: String) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      isPresentOn(channelId: channelId) {
        switch $0 {
        case let .success(isPresent):
          continuation.resume(returning: isPresent)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Retrieves the memberships associated with the user across different channels.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of memberships to retrieve
  ///   - page: Pagination information for retrieving memberships
  ///   - filter: An expression to filter the retrieved memberships
  ///   - sort: A collection of sort keys to determine the sort order of the memberships
  /// - Returns: A `Tuple` containing an `Array` of memberships, and the next pagination `PubNubHashedPage` (if one exists)
  func getMemberships(
    limit: Int? = nil,
    page: PubNubHashedPage? = nil,
    filter: String? = nil,
    sort: [PubNub.MembershipSortField] = []
  ) async throws -> (memberships: [ChatType.ChatMembershipType], page: PubNubHashedPage?) {
    try await withCheckedThrowingContinuation { continuation in
      getMemberships(
        limit: limit,
        page: page,
        filter: filter,
        sort: sort
      ) {
        switch $0 {
        case let .success(getMembershipsResult):
          continuation.resume(returning: getMembershipsResult)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Receives updates on a single User object.
  ///
  /// - Returns: An asynchronous stream that produces updates when the current User is edited or removed.
  func streamUpdates() -> AsyncStream<ChatType.ChatUserType?> {
    AsyncStream { continuation in
      let autoCloseable = streamUpdates {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }
}
