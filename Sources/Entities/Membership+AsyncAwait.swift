//
//  Membership+AsyncAwait.swift
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
/// Extension providing `async-await` support for ``Membership``.
///
public extension Membership {
  /// Receive updates when specific memberships are added, edited or removed.
  ///
  /// - Parameter memberships: Collection containing the ``Membership`` to watch for updates
  /// - Returns: An asynchronous stream that produces updates when any item in the `memberships` collection is updated
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
  func getUnreadMessagesCount() async throws -> UInt64? {
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
  /// - Returns: An asynchronous stream that produces updates when the current ``Membership`` is edited or removed.
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
