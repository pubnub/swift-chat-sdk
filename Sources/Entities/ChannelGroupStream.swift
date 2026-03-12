//
//  ChannelGroupStream.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Namespace providing `AsyncStream`-based streaming methods for a ``ChannelGroup``.
public struct ChannelGroupStream<C: ChannelGroup> {
  let channelGroup: C

  /// Emits the received message whenever a new message is published on any channel within this channel group.
  ///
  /// Async equivalent of ``ChannelGroup/onMessageReceived(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of messages
  public func messages() -> AsyncStream<C.ChatType.ChatMessageType> {
    AsyncStream { continuation in
      let autoCloseable = channelGroup.onMessageReceived {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits presence data whenever the presence state changes on any channel within this channel group.
  ///
  /// Async equivalent of ``ChannelGroup/onPresenceChanged(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of dictionaries mapping channel identifiers to present user identifiers
  public func presenceChanges() -> AsyncStream<[String: [String]]> {
    AsyncStream { continuation in
      let autoCloseable = channelGroup.onPresenceChanged {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }
}
