//
//  ChannelGroup+AsyncAwait.swift
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
/// Extension providing `async-await` support for ``ChannelGroup``.
///
public extension ChannelGroup {
  /// Returns a paginated list of all existing channels in a given ``ChannelGroup``.
  ///
  /// - Parameters:
  ///   - filter: Expression used to filter the results. Returns only these channels whose properties satisfy the given expression are returned
  ///   - sort: A collection to specify the sort order
  ///   - limit: Number of objects to return in response. The maximum value is 100
  ///   - page: Object used for pagination to define which previous or next result page you want to fetch
  /// - Returns:  A `Tuple` containing an `Array` of channels, and the next pagination `PubNubHashedPage` (if one exists)
  func listChannels(
    filter: String? = nil,
    sort: [PubNub.ObjectSortField] = [],
    limit: Int? = nil,
    page: PubNubHashedPage? = nil
  ) async throws -> (channels: [ChatType.ChatChannelType], page: PubNubHashedPage?) {
    try await withCheckedThrowingContinuation { continuation in
      listChannels(
        filter: filter,
        sort: sort,
        limit: limit,
        page: page
      ) {
        switch $0 {
          case let .success(value):
            continuation.resume(returning: value)
          case let .failure(error):
            continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Adds ``Channel`` entities to a channel group.
  ///
  /// - Parameter channels: The ``Channel`` entities to add
  func add(channels: [ChatType.ChatChannelType]) async throws {
    try await withCheckedThrowingContinuation { continuation in
      add(channels: channels) {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Adds channel identifiers to a channel group.
  ///
  /// This method reduces the overhead of fetching full ``Channel`` entities when
  /// only the IDs are known. It does not perform validation to check whether
  /// the channels with the given IDs exist — responsibility for ensuring
  /// validity lies with the caller.
  ///
  /// - Parameter ids: ``Channel`` identifiers to add
  func addChannelIdentifiers(_ ids: [String]) async throws {
    try await withCheckedThrowingContinuation { continuation in
      addChannelIdentifiers(ids) {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Remove ``Channel`` entities from a channel group.
  ///
  /// - Parameter channels: The ``Channel`` entities to remove
  func remove(channels: [ChatType.ChatChannelType]) async throws {
    try await withCheckedThrowingContinuation { continuation in
      remove(channels: channels) {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Remove channel identifiers from a channel group.
  ///
  /// This method reduces the overhead of fetching full ``Channel`` entities when
  /// only the IDs are known. It does not perform validation to check whether
  /// the channels with the given IDs exist — responsibility for ensuring
  /// validity lies with the caller.
  ///
  /// - Parameter ids: ``Channel`` identifiers to remove
  func removeChannelIdentifiers(_ ids: [String]) async throws {
    try await withCheckedThrowingContinuation { continuation in
      removeChannelIdentifiers(ids) {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Returns a collection of users currently present in any channel within the given ``ChannelGroup``.
  ///
  /// - Returns: A `Dictionary` where the key is a ``Channel`` identifier and the value is an array of present user identifiers
  func whoIsPresent() async throws -> [String: [String]] {
    try await withCheckedThrowingContinuation { continuation in
      whoIsPresent {
        switch $0 {
        case let .success(result):
          continuation.resume(returning: result)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Enables real-time tracking of users connecting to or disconnecting from the given ``ChannelGroup``.
  ///
  /// - Returns: An asynchronous stream that produces a dictionary of channel identifiers and their present user identifiers
  func streamPresence() -> AsyncStream<[String: [String]]> {
    AsyncStream { continuation in
      let autoCloseable = streamPresence {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Watch the ``ChannelGroup`` content.
  ///
  /// - Returns: An asynchronous stream that produces new messages from any channel in the group
  func connect() -> AsyncStream<ChatType.ChatMessageType> {
    AsyncStream { continuation in
      let autoCloseable = connect {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }
}
