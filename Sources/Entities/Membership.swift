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
public protocol Membership: CustomStringConvertible {
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
  /// - Important: Keep a strong reference to the returned ``AutoCloseable`` object as long as you want to receive updates. If ``AutoCloseable`` is deallocated,
  /// the stream will be canceled, and no further items will be produced. You can also stop receiving updates manually by calling ``AutoCloseable/close()``.
  ///
  /// - Parameters:
  ///   - memberships: Collection containing the ``Membership`` to watch for updates
  ///   - callback: Defines the custom behavior to be executed when detecting membership changes
  /// - Returns: An ``AutoCloseable`` that you can use to stop receiving objects events by invoking its ``AutoCloseable/close()`` method
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
  ///     - **Success**: The number of unread messages on the membership's channel or `nil` when ``lastReadMessageTimetoken`` is also `nil`
  ///     - **Failure**: An `Error` describing the failure
  func getUnreadMessagesCount(
    completion: ((Swift.Result<UInt64?, Error>) -> Void)?
  )

  /// You can receive updates when specific user-channel Membership object(s) are added, edited, or removed.
  ///
  /// - Important: Keep a strong reference to the returned ``AutoCloseable`` object as long as you want to receive updates. If ``AutoCloseable`` is deallocated,
  /// the stream will be canceled, and no further items will be produced. You can also stop receiving updates manually by calling ``AutoCloseable/close()``.
  ///
  /// - Parameter callback: Defines the custom behavior to be executed when detecting membership changes
  /// - Returns: An ``AutoCloseable`` that you can use to stop receiving objects events by invoking its ``AutoCloseable/close()`` method
  func streamUpdates(
    callback: @escaping ((ChatType.ChatMembershipType?) -> Void)
  ) -> AutoCloseable
}

/// Extension to conform to `CustomStringConvertible` for custom string representation.
/// Provides a readable description of the object for debugging and logging purposes
public extension Membership {
  var description: String {
    String.formattedDescription(
      self,
      arguments: [
        ("channel", channel),
        ("user", user),
        ("custom", custom ?? "nil"),
        ("status", status ?? "nil"),
        ("type", type ?? "nil"),
        ("eTag", eTag ?? "nil"),
        ("updated", updated ?? "nil"),
        ("lastReadMessageTimetoken", lastReadMessageTimetoken ?? "nil")
      ]
    )
  }
}
