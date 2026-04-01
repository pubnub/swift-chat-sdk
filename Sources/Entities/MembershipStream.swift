//
//  MembershipStream.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Namespace providing `AsyncStream`-based streaming methods for a ``Membership``.
public struct MembershipStream<M: Membership> {
  let membership: M

  /// Emits the updated membership entity whenever this membership's metadata is modified.
  ///
  /// Async equivalent of ``Membership/onUpdated(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of updated memberships
  public func updates() -> AsyncStream<M.ChatType.ChatMembershipType> {
    AsyncStream { continuation in
      let autoCloseable = membership.onUpdated {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits an event whenever this membership is removed.
  ///
  /// Async equivalent of ``Membership/onDeleted(callback:)``.
  ///
  /// - Returns: An `AsyncStream` that yields `Void` on deletion
  public func deletions() -> AsyncStream<Void> {
    AsyncStream { continuation in
      let autoCloseable = membership.onDeleted {
        continuation.yield(())
        continuation.finish()
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }
}
