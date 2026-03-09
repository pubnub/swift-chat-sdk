//
//  UserStream.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Namespace providing `AsyncStream`-based streaming methods for a ``User``.
public struct UserStream<U: User> {
  let user: U

  /// Emits the updated user entity whenever this user's metadata is modified.
  ///
  /// Async equivalent of ``User/onUpdated(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of updated users
  public func updates() -> AsyncStream<U.ChatType.ChatUserType> {
    AsyncStream { continuation in
      let autoCloseable = user.onUpdated {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits an event whenever this user is permanently deleted.
  ///
  /// Async equivalent of ``User/onDeleted(callback:)``.
  ///
  /// - Returns: An `AsyncStream` that yields `Void` on deletion
  public func deletions() -> AsyncStream<Void> {
    AsyncStream { continuation in
      let autoCloseable = user.onDeleted {
        continuation.yield(())
        continuation.finish()
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits a mention whenever this user is mentioned in a message.
  ///
  /// Async equivalent of ``User/onMentioned(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of ``Mention`` values
  public func mentions() -> AsyncStream<Mention> {
    AsyncStream { continuation in
      let autoCloseable = user.onMentioned {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits an invite whenever this user is invited to a channel.
  ///
  /// Async equivalent of ``User/onInvited(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of ``Invite`` values
  public func invites() -> AsyncStream<Invite> {
    AsyncStream { continuation in
      let autoCloseable = user.onInvited {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }

  /// Emits a restriction whenever the moderation status changes for this user.
  ///
  /// Async equivalent of ``User/onRestrictionChanged(callback:)``.
  ///
  /// - Returns: An `AsyncStream` of ``Restriction`` values
  public func restrictionChanges() -> AsyncStream<Restriction> {
    AsyncStream { continuation in
      let autoCloseable = user.onRestrictionChanged {
        continuation.yield($0)
      }
      continuation.onTermination = { _ in
        autoCloseable.close()
      }
    }
  }
}
