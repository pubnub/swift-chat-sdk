//
//  ChannelStream.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Namespace providing `AsyncStream`-based streaming methods for a ``Channel``.
public struct ChannelStream<C: Channel> {
  let channel: C

  /// Emits the list of user IDs whenever the typing status changes on this channel.
  ///
  /// Async equivalent of ``Channel/onTypingChanged(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of user ID arrays
  public func typingChanges() -> AsyncStream<[String]> {
    AsyncStream { continuation in
      let autoCloseable = channel.onTypingChanged {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits the received message whenever a new message is published on this channel.
  ///
  /// Async equivalent of ``Channel/onMessageReceived(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of messages
  public func messages() -> AsyncStream<C.MessageType> {
    AsyncStream { continuation in
      let autoCloseable = channel.onMessageReceived {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits the updated channel entity whenever this channel's metadata is modified.
  ///
  /// Async equivalent of ``Channel/onUpdated(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of updated channels
  public func updates() -> AsyncStream<C> {
    AsyncStream { continuation in
      let autoCloseable = channel.onUpdated {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits an event whenever this channel is deleted (soft or hard).
  ///
  /// Async equivalent of ``Channel/onDeleted(callback:)``.
  ///
  /// - Returns: An `AsyncStream` that yields `Void` on deletion
  public func deletions() -> AsyncStream<Void> {
    AsyncStream { continuation in
      let autoCloseable = channel.onDeleted {
        continuation.yield(())
        continuation.finish()
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits the set of user IDs whenever the presence state changes on this channel.
  ///
  /// Async equivalent of ``Channel/onPresenceChanged(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of presence user ID sets
  public func presenceChanges() -> AsyncStream<Set<String>> {
    AsyncStream { continuation in
      let autoCloseable = channel.onPresenceChanged {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits a read receipt whenever a member reads a message on this channel.
  ///
  /// Async equivalent of ``Channel/onReadReceiptReceived(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of ``ReadReceipt`` values
  public func readReceipts() -> AsyncStream<ReadReceipt> {
    AsyncStream { continuation in
      let autoCloseable = channel.onReadReceiptReceived {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits a report whenever a message in this channel is reported by a user.
  ///
  /// Async equivalent of ``Channel/onMessageReported(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of ``Report`` values
  public func reports() -> AsyncStream<Report> {
    AsyncStream { continuation in
      let autoCloseable = channel.onMessageReported {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }
}
