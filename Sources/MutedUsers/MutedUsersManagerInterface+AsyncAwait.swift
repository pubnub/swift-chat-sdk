//
//  MutedUsersManagerInterface+AsyncAwait.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

///
/// Extension providing `async-await` support for ``MutedUsersManagerInterface``.
///
public extension MutedUsersManagerInterface {
  /// Add a user to the list of muted users
  ///
  /// - Parameter userId: The ID of the user to mute
  func muteUser(userId: String) async throws {
    try await withCheckedThrowingContinuation { continuation in
      muteUser(userId: userId) {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Removes a user from the list of muted users
  ///
  /// - Parameter userId: The ID of the muted user
  func unmuteUser(userId: String) async throws {
    try await withCheckedThrowingContinuation { continuation in
      unmuteUser(userId: userId) {
        switch $0 {
        case .success:
          continuation.resume(returning: ())
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
