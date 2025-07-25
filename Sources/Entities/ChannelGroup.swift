//
//  ChannelGroup.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// Represents an interface for types that refers to a channel group.
public protocol ChannelGroup {
  associatedtype ChatType: Chat

  /// The ID of the channel group.
  var id: String { get }
  /// The chat instance.
  var chat: ChatType { get }

  /// Returns a paginated list of all existing channels in a given ``ChannelGroup``.
  ///
  /// - Parameters:
  ///   - filter: Expression used to filter the results. Returns only the channels whose properties satisfy the given expression
  ///   - sort: A collection to specify the sort order
  ///   - limit: Number of objects to return in response. The maximum value is 100
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Tuple` containing an `Array` of channels, and the next pagination `PubNubHashedPage` (if one exists)
  ///     - **Failure**: An `Error` describing the failure
  func listChannels(
    filter: String?,
    sort: [PubNub.ObjectSortField],
    limit: Int?,
    page: PubNubHashedPage?,
    completion: ((Swift.Result<(channels: [ChatType.ChatChannelType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  /// Adds ``Channel`` entities to a channel group.
  ///
  /// - Parameters:
  ///   - channels: The ``Channel`` entities to add
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func add(channels: [ChatType.ChatChannelType], completion: ((Swift.Result<Void, Error>) -> Void)?)

  /// Adds channel identifiers to a channel group.
  ///
  /// This method reduces the overhead of fetching full ``Channel`` entities when
  /// only the IDs are known. It does not perform validation to check whether
  /// the channels with the given IDs exist — responsibility for ensuring
  /// validity lies with the caller.
  ///
  /// - Parameters:
  ///   - ids: ``Channel`` identifiers to add
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func addChannelIdentifiers(_ ids: [String], completion: ((Swift.Result<Void, Error>) -> Void)?)

  /// Remove ``Channel`` entities from a channel group.
  ///
  /// - Parameters:
  ///   - channels: The ``Channel`` entities to remove
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func remove(channels: [ChatType.ChatChannelType], completion: ((Swift.Result<Void, Error>) -> Void)?)

  /// Remove channel identifiers from a channel group.
  ///
  /// This method reduces the overhead of fetching full ``Channel`` entities when
  /// only the IDs are known. It does not perform validation to check whether
  /// the channels with the given IDs exist — responsibility for ensuring
  /// validity lies with the caller.
  ///
  /// - Parameters:
  ///   - ids: ``Channel`` identifiers to remove
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Void` indicating a success
  ///     - **Failure**: An `Error` describing the failure
  func removeChannelIdentifiers(_ ids: [String], completion: ((Swift.Result<Void, Error>) -> Void)?)

  /// Returns a collection of users currently present in any channel within the given ``ChannelGroup``.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: A `Dictionary` where the key is a ``Channel`` identifier and the value is an array of present user identifiers
  ///     - **Failure**: An `Error` describing the failure
  func whoIsPresent(completion: ((Swift.Result<[String: [String]], Error>) -> Void)?)

  /// Enables real-time tracking of users connecting to or disconnecting from the given ``ChannelGroup``.
  ///
  /// - Parameter callback: A closure that will be called with a dictionary of channel identifiers and their present user identifiers
  /// - Returns: ``AutoCloseable`` interface you can call to stop listening for present users by invoking the ``AutoCloseable/close()`` method.
  func streamPresence(callback: @escaping ([String: [String]]) -> Void) -> AutoCloseable

  /// Watch the ``ChannelGroup`` content.
  ///
  /// - Parameter callback: Custom behavior whenever a message is received
  /// - Returns: ``AutoCloseable`` interface you can call to stop listening for new messages by invoking the ``AutoCloseable/close()`` method.
  func connect(callback: @escaping (ChatType.ChatMessageType) -> Void) -> AutoCloseable
}
