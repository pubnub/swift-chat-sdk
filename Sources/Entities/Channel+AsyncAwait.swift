//
//  Channel+AsyncAwait.swift
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
/// Extension providing `async-await` support for ``Channel``.
///
public extension Channel {
  /// Requests another user to join a channel (except public channel) and become its member.
  ///
  /// - Parameter user: A user that you want to invite to a channel
  /// - Returns: List of ``Membership`` of invited users
  func invite(user: ChatType.ChatUserType) async throws -> ChatType.ChatMembershipType {
    try await withCheckedThrowingContinuation { continuation in
      invite(user: user) {
        switch $0 {
        case let .success(membership):
          continuation.resume(returning: membership)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Sends text to the ``Channel``.
  ///
  /// - Parameters:
  ///   - text: Text that you want to send to the selected channel
  ///   - meta: Publish additional details with the request
  ///   - shouldStore: If true, the messages are stored in Message Persistence if enabled in Admin Portal
  ///   - usePost: Use HTTP POST
  ///   - ttl: Defines if/how long (in hours) the message should be stored in Message Persistence
  ///   - quotedMessage: Object added to a message when you quote another message
  ///   - files: One or multiple files attached to the text message
  ///   - usersToMention: A collection of user ids to automatically notify with a mention after this message is sent
  /// - Returns: The timetoken of the sent message
  @discardableResult
  func sendText(
    text: String,
    meta: [String: JSONCodable]? = nil,
    shouldStore: Bool = true,
    usePost: Bool = false,
    ttl: Int? = nil,
    quotedMessage: ChatType.ChatMessageType? = nil,
    files: [InputFile]? = nil,
    usersToMention: [String]? = nil
  ) async throws -> Timetoken {
    try await withCheckedThrowingContinuation { continuation in
      sendText(
        text: text,
        meta: meta,
        shouldStore: shouldStore,
        usePost: usePost,
        ttl: ttl,
        quotedMessage: quotedMessage,
        files: files,
        usersToMention: usersToMention
      ) {
        switch $0 {
        case let .success(timetoken):
          continuation.resume(returning: timetoken)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Fetches the message from Message Persistence based on the message `timetoken`.
  ///
  /// - Parameter timetoken: Timetoken of the message you want to retrieve from Message Persistence
  /// - Returns: A message object (if any)
  func getMessage(timetoken: Timetoken) async throws -> ChatType.ChatMessageType? {
    try await withCheckedThrowingContinuation { continuation in
      getMessage(timetoken: timetoken) {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Fetches the message that is currently pinned to the channel.
  ///
  /// There can be only one pinned message on a channel at a time.
  ///
  /// - Returns: A pinned ``Message``
  func getPinnedMessage() async throws -> ChatType.ChatMessageType? {
    try await withCheckedThrowingContinuation { continuation in
      getPinnedMessage {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Allows to delete  an existing ``Channel`` with or without deleting its historical data from the App Context storage.
  ///
  /// - Parameter soft: Decide if you want to permanently remove channel metadata
  /// - Returns: For hard delete, the method returns `nil`. Otherwise, an updated ``Channel`` instance with the status field set to `"deleted"`
  func delete(soft: Bool = false) async throws -> ChatType.ChatChannelType? {
    try await withCheckedThrowingContinuation { continuation in
      delete(soft: soft) {
        switch $0 {
        case let .success(message):
          continuation.resume(returning: message)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns historical messages for the ``Channel``.
  ///
  /// - Parameters:
  ///   - startTimetoken: The start value for the set of remote data
  ///   - endTimetoken: The bounded end value that will be eventually fetched to
  ///   - count: The maximum number of messages to retrieve
  /// - Returns: A `Tuple` containing an array of messages, and a boolean indicating whether there are more messages available beyond the current result set
  func getHistory(
    startTimetoken: Timetoken? = nil,
    endTimetoken: Timetoken? = nil,
    count: Int = 25
  ) async throws -> (messages: [MessageType], isMore: Bool) {
    try await withCheckedThrowingContinuation { continuation in
      getHistory(startTimetoken: startTimetoken, endTimetoken: endTimetoken, count: count) {
        switch $0 {
        case let .success((messages, isMore)):
          continuation.resume(returning: (messages: messages, isMore: isMore))
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
