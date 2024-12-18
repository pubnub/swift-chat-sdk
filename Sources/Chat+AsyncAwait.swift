//
//  Chat+AsyncAwait.swift
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
/// Extension providing `async-await` support for ``Chat``.
///
public extension Chat {
  /// Initializes the current instance and performs any necessary setup.
  ///
  /// - Returns: The initialized object of ``Chat``
  @discardableResult func initialize() async throws -> Self {
    try await withCheckedThrowingContinuation { continuation in
      initialize {
        switch $0 {
        case let .success(instance):
          continuation.resume(returning: instance)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Deletes a user with or without deleting its historical data from the App Context storage.
  ///
  /// - Parameters:
  ///   - id: Unique user identifier
  ///   - soft: Decide if you want to permanently remove user metadata
  /// - Returns: For hard delete, the method returns `nil`. Otherwise, an updated ``User`` instance with the status field set to `"deleted"`
  @discardableResult func deleteUser(id: String, soft: Bool = false) async throws -> ChatUserType? {
    try await withCheckedThrowingContinuation { continuation in
      deleteUser(id: id, soft: soft) {
        switch $0 {
        case let .success(user):
          continuation.resume(returning: user)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Allows to delete ``Channel`` with or without deleting its historical data from the App Context storage.
  ///
  /// - Parameters:
  ///   - id: Unique channel identifier (up to 92 UTF-8 byte sequences)
  ///   - soft: Decide if you want to permanently remove channel metadata. If you set this parameter to true, the ``Channel`` object gets the deleted status, and you can still restore/get its data
  /// - Returns: For hard delete, the method returns `nil`. Otherwise, an updated ``Channel`` instance with the status field set to `"deleted"`
  @discardableResult
  func deleteChannel(id: String, soft: Bool = false) async throws -> ChatChannelType? {
    try await withCheckedThrowingContinuation { continuation in
      deleteChannel(id: id, soft: soft) {
        switch $0 {
        case let .success(channel):
          continuation.resume(returning: channel)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
