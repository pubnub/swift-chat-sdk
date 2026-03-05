//
//  MessageStream.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Namespace providing `AsyncStream`-based streaming methods for a ``Message``.
public struct MessageStream<M: Message> {
  let message: M

  /// Emits the updated message entity whenever this message's content or reactions are modified.
  ///
  /// Async equivalent of ``Message/onUpdated(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of updated messages
  public func updates() -> AsyncStream<M> {
    AsyncStream { continuation in
      let autoCloseable = message.onUpdated {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }
}
