//
//  Message+AsyncAwait.swift
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
/// Extension providing `async-await` support for ``Message``.
///
public extension Message {
  /// Receive updates when specific messages and related message reactions are added, edited, or removed.
  ///
  /// - Parameter messages: A collection of ``Message`` objects for which you want to get updates on changed messages
  /// - Returns: An asynchronous stream that produces updates when any item in the `messages` collection is updated
  static func streamUpdatesOn(messages: [Self]) -> AsyncStream<[Self]> {
    AsyncStream { continuation in
      let autoCloseable = streamUpdatesOn(messages: messages) {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }
  
  /// Changes the content of the existing message to a new one.
  ///
  /// - Parameter newText: New/updated text that you want to add in place of the existing message
  /// - Returns: An updated ``Message`` object
  func editText(newText: String) async throws -> ChatType.ChatMessageType {
    try await withCheckedThrowingContinuation { continuation in
      editText(newText: newText) {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Either permanently removes a historical message from Message Persistence or marks it as deleted (if you remove the message with the soft option).
  ///
  /// - Parameters:
  ///   - soft: Decide if you want to permanently remove message data
  ///   - preserveFiles: Define if you want to keep the files attached to the message or remove them
  /// - Returns: For hard delete, the method returns `nil`. Otherwise, an updated ``Message`` instance with an added `"deleted"` action type
  func delete(
    soft: Bool = false,
    preserveFiles: Bool = false
  ) async throws -> ChatType.ChatMessageType? {
    try await withCheckedThrowingContinuation { continuation in
      delete(soft: soft, preserveFiles: preserveFiles) {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Get the thread channel on which the thread message is published.
  ///
  /// - Returns: A ``ThreadChannel`` object which can be used for sending and reading messages from the message thread
  func getThread() async throws -> ChatType.ChatThreadChannelType {
    try await withCheckedThrowingContinuation { continuation in
      getThread {
        switch $0 {
        case let .success(thread):
          continuation.resume(returning: thread)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Forward a given message from one channel to another.
  ///
  /// - Parameter channelId: Unique identifier of the channel to which you want to forward the message. You can forward a message to the same channel on which it was published or to any other
  /// - Returns: The timetoken of the forwarded message
  func forward(channelId: String) async throws -> Timetoken {
    try await withCheckedThrowingContinuation { continuation in
      forward(channelId: channelId) {
        switch $0 {
        case let .success(timetoken):
          continuation.resume(returning: timetoken)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Attach this message to its channel.
  ///
  /// - Returns: The updated Channel metadata
  func pin() async throws -> ChatType.ChatChannelType {
    try await withCheckedThrowingContinuation { continuation in
      pin {
        switch $0 {
        case let .success(timetoken):
          continuation.resume(returning: timetoken)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Flag and report an inappropriate message to the admin.
  ///
  /// - Parameter reason: Reason for reporting/flagging a given message
  /// - Returns: The timetoken of the reported message
  func report(reason: String) async throws -> Timetoken {
    try await withCheckedThrowingContinuation { continuation in
      report(reason: reason) {
        switch $0 {
        case let .success(timetoken):
          continuation.resume(returning: timetoken)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Create a thread (channel) for a selected message.
  ///
  /// - Returns: A ``ThreadChannel`` object which can be used for sending and reading messages from the newly created message thread
  func createThread() async throws -> ChatType.ChatThreadChannelType {
    try await withCheckedThrowingContinuation { continuation in
      createThread {
        switch $0 {
        case let .success(thread):
          continuation.resume(returning: thread)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Removes a thread (channel) for a selected message.
  ///
  /// - Returns: The updated channel object after the removal of the thread
  func removeThread() async throws -> ChatType.ChatChannelType? {
    try await withCheckedThrowingContinuation { continuation in
      removeThread {
        switch $0 {
        case let .success(thread):
          continuation.resume(returning: thread)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Add or remove a reaction to a message.
  ///
  /// It's a method for both adding and removing message reactions. It adds a string flag to the message if the current user hasn't added it yet
  /// or removes it if the current user already added it before.
  ///
  /// - Parameter reaction: Emoji added to the message or removed from it by the current user
  /// - Returns: An updated message instance
  func toggleReaction(reaction: String) async throws -> Self {
    try await withCheckedThrowingContinuation { continuation in
      toggleReaction(reaction: reaction) {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// You can receive updates when this message and related message reactions are added, edited, or removed.
  ///
  /// - Parameter completion: Function that takes a single Message object. It defines the custom behavior to be executed when detecting message or message reaction changes
  /// - Returns: An asynchronous stream that produces updates when the current Message is edited or removed.
  func streamUpdates() -> AsyncStream<Self?> {
    AsyncStream { continuation in
      let autoCloseable = streamUpdates {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }
  
  /// If you delete a message, you can restore its content together with the attached files using the `restore()` method.
  ///
  /// This is possible, however, only if the message you want to restore was soft deleted (the soft parameter was set to true when deleting it). Hard deleted messages cannot be restored as their data
  /// is no longer available in Message Persistence. This method also requires Message Persistence configuration. To manage messages, you must enable Message Persistence for your app's keyset
  /// in the Admin Portal and mark the Enable Delete-From-History option.
  ///
  /// - Returns: A restored message object
  func restore() async throws -> Self {
    try await withCheckedThrowingContinuation { continuation in
      restore {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
