//
//  MutedUsersManagerInterface.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

/// Defines a protocol for an object capable of muting and unmuting users.
public protocol MutedUsersManagerInterface {
  /// The current set of muted users.
  var mutedUsers: Set<String> { get }

  /// Add a user to the list of muted users
  ///
  /// - Parameters:
  ///   - userId: The ID of the user to mute
  ///   - completion: The `Result` of an asynchronous call:
  ///     - **Success**: The operation succeeded, returns nothing
  ///     - **Failure**: An `Error` describing the failure
  func muteUser(userId: String, completion: ((Swift.Result<Void, Error>) -> Void)?)

  /// Removes a user from the list of muted users
  ///
  /// - Parameters:
  ///   - userId: The ID of the muted user
  ///   - completion: The `Result` of an asynchronous call:
  ///     - **Success**: The operation succeeded, returns nothing
  ///     - **Failure**: An `Error` describing the failure
  func unmuteUser(userId: String, completion: ((Swift.Result<Void, Error>) -> Void)?)
}

/// Provides a default implementation for ``MutedUsersManagerInterface`` methods requiring a completion handler,
/// allowing the completion handler to be `nil` by default. This simplifies usage for cases where no action is needed after the method completes.
extension MutedUsersManagerInterface {
  /// Add a user to the list of muted users
  ///
  /// - Parameter userId: The ID of the user to mute
  func muteUser(userId: String) {
    muteUser(userId: userId, completion: nil)
  }

  /// Removes a user from the list of muted users
  ///
  /// - Parameter userId: The ID of the muted user
  func unmuteUser(userId: String) {
    unmuteUser(userId: userId, completion: nil)
  }
}

class MutedUsersManagerImpl: MutedUsersManagerInterface {
  let underlying: PubNubChat.MutedUsersManager

  init(underlying: PubNubChat.MutedUsersManager) {
    self.underlying = underlying
  }

  var mutedUsers: Set<String> {
    underlying.mutedUsers
  }

  func muteUser(userId: String, completion: ((Swift.Result<Void, Error>) -> Void)? = nil) {
    underlying.muteUser(userId: userId).async(
      caller: self
    ) { (result: FutureResult<MutedUsersManagerImpl, PubNubChat.KotlinUnit>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func unmuteUser(userId: String, completion: ((Swift.Result<Void, Error>) -> Void)? = nil) {
    underlying.unmuteUser(userId: userId).async(
      caller: self
    ) { (result: FutureResult<MutedUsersManagerImpl, PubNubChat.KotlinUnit>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }
}
