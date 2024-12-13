//
//  Membership.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Membership is an object that refers to a single user-channel relationship in a chat.
public protocol Membership {
  associatedtype ChatType: Chat

  /// Reference to the main Chat object
  var chat: ChatType { get }
  /// The ``Channel`` of this ``Membership``
  var channel: ChatType.ChatChannelType { get }
  /// The ``User`` of this ``Membership``
  var user: ChatType.ChatUserType { get }
  /// Any custom properties or metadata associated with the user-channel relationship in the form of a map of key-value pairs
  var custom: [String: JSONCodableScalar]? { get }
  /// Status of a Membership
  var status: String? { get }
  /// Type of a Membership
  var type: String? { get }
  /// Caching value that changes whenever the Membership object changes
  var eTag: String? { get }
  /// Last time the Membership object was changed
  var updated: String? { get }
  /// Timetoken of the last message a user read on a given channel
  var lastReadMessageTimetoken: Timetoken? { get }

  /// Receive updates when specific memberships are added, edited or removed.
  ///
  /// - Parameters:
  ///   - memberships: Collection containing the ``Membership`` to watch for updates
  ///   - callback: Defines the custom behavior to be executed when detecting membership changes
  /// - Returns: An ``AutoCloseable`` that you can use to stop receiving objects events by invoking its `close()` method
  static func streamUpdatesOn(
    memberships: [Self],
    callback: @escaping (([Self]) -> Void)
  ) -> AutoCloseable

  /// Setting the last read message for users lets you implement the Read Receipts feature and monitor which channel member read which message.
  ///
  /// - Parameters:
  ///   - message: Last read message on a given channel with the timestamp that gets added to the user-channel membership as the `lastReadMessageTimetoken` property
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: An updated ``Membership`` object
  ///     - **Failure**: An `Error` describing the failure
  func setLastReadMessage(
    message: ChatType.ChatMessageType,
    completion: ((Swift.Result<ChatType.ChatMembershipType, Error>) -> Void)?
  )

  /// Updates the channel membership information for a given user.
  ///
  /// - Parameters:
  ///   - custom: Any custom properties or metadata associated with the channel-user membership in a form of key-value pairs
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: An updated ``Membership`` object
  ///     - **Failure**: An `Error` describing the failure
  func update(
    custom: [String: JSONCodableScalar],
    completion: ((Swift.Result<ChatType.ChatMembershipType, Error>) -> Void)?
  )

  /// Setting the last read message timetoken for users lets you implement the Read Receipts feature and monitor which channel member read which message.
  ///
  /// - Parameters:
  ///   - timetoken: Timetoken of the last read message on a given channel that gets added to the user-channel membership as the `lastReadMessageTimetoken` property
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: An updated ``Membership`` object
  ///     - **Failure**: An `Error` describing the failure
  func setLastReadMessageTimetoken(
    _ timetoken: Timetoken,
    completion: ((Swift.Result<ChatType.ChatMembershipType, Error>) -> Void)?
  )

  /// Returns the number of messages you didn't read on a given channel. You can display this number on UI in the channel list of your chat app.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The number of unread messages on the membership's channel
  ///     - **Failure**: An `Error` describing the failure
  func getUnreadMessagesCount(
    completion: ((Swift.Result<UInt64, Error>) -> Void)?
  )

  /// You can receive updates when specific user-channel Membership object(s) are added, edited, or removed.
  ///
  /// - Parameter callback: Defines the custom behavior to be executed when detecting membership changes
  /// - Returns: An ``AutoCloseable`` that you can use to stop receiving objects events by invoking its `close()` method
  func streamUpdates(
    callback: @escaping ((ChatType.ChatMembershipType?) -> Void)
  ) -> AutoCloseable
}

///
/// Extension providing `async-await` support for ``Membership``.
///
extension Membership {
  /// Receive updates when specific memberships are added, edited or removed.
  ///
  /// - Parameter memberships: Collection containing the ``Membership`` to watch for updates
  /// - Returns: An asynAn asynchronous stream that produces updates when any item in the `memberships` collection is updated
  static func streamUpdatesOn(memberships: [Self]) -> AsyncStream<[Self]> {
    AsyncStream { continuation in
      let autoCloseable = streamUpdatesOn(memberships: memberships) {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Setting the last read message for users lets you implement the Read Receipts feature and monitor which channel member read which message.
  ///
  /// - Parameter message: Last read message on a given channel with the timestamp that gets added to the user-channel membership as the `lastReadMessageTimetoken` property
  /// - Returns: An updated ``Membership`` object
  func setLastReadMessage(message: ChatType.ChatMessageType) async throws -> ChatType.ChatMembershipType {
    try await withCheckedThrowingContinuation { continuation in
      setLastReadMessage(message: message) {
        switch $0 {
        case let .success(membership):
          continuation.resume(returning: membership)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Updates the channel membership information for a given user.
  ///
  /// - Parameter custom: Any custom properties or metadata associated with the channel-user membership in a form of key-value pairs
  /// - Returns: An updated ``Membership`` object
  func update(custom: [String: JSONCodableScalar]) async throws -> ChatType.ChatMembershipType {
    try await withCheckedThrowingContinuation { continuation in
      update(custom: custom) {
        switch $0 {
        case let .success(membership):
          continuation.resume(returning: membership)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Setting the last read message timetoken for users lets you implement the Read Receipts feature and monitor which channel member read which message.
  ///
  /// - Parameter timetoken: Timetoken of the last read message on a given channel that gets added to the user-channel membership as the `lastReadMessageTimetoken` property
  /// - Returns: An updated ``Membership`` object
  func setLastReadMessageTimetoken(_ timetoken: Timetoken) async throws -> ChatType.ChatMembershipType {
    try await withCheckedThrowingContinuation { continuation in
      setLastReadMessageTimetoken(timetoken) {
        switch $0 {
        case let .success(membership):
          continuation.resume(returning: membership)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns the number of messages you didn't read on a given channel. You can display this number on UI in the channel list of your chat app.
  ///
  /// - Returns: A number of unread messages
  func getUnreadMessagesCount() async throws -> UInt64 {
    try await withCheckedThrowingContinuation { continuation in
      getUnreadMessagesCount {
        switch $0 {
        case let .success(messagesCount):
          continuation.resume(returning: messagesCount)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// You can receive updates when specific user-channel Membership object(s) are added, edited, or removed.
  ///
  /// - Returns: An asynchronous stream that produces updates when the current Membership is edited or removed.
  func streamUpdates() -> AsyncStream<ChatType.ChatMembershipType?> {
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
