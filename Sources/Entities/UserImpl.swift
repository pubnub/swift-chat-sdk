//
//  UserImpl.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat
import PubNubSDK

/// A concrete implementation of the ``User`` protocol.
///
/// This class provides a ready-to-use solution for most use cases requiring
/// the features defined by the ``User`` protocol, offering default behavior for
/// associated types and default parameter values where applicable.
///
/// It inherits all the documentation for methods defined in the ``User`` protocol.
/// Refer to the ``User`` protocol for detailed information on how individual methods work.
public final class UserImpl {
  let user: PubNubChat.User

  /// Creates a new ``UserImpl`` object
  ///
  /// - Parameters:
  ///   - chat: Reference to the main chat object
  ///   - id: Unique identifier for user
  ///   - name: Display name or username of the user (must not be empty or consist only of whitespace characters)
  ///   - externalId: Identifier for the user from an external system, such as a third-party authentication provider or a user directory
  ///   - profileUrl: URL to the user's profile or avatar image
  ///   - email: User's email address
  ///   - custom: Any custom properties or metadata associated with the user in the form of a map of key-value pairs
  ///   - status: Current status of the user, like online, offline, or away
  ///   - type: Type of the user, like admin, member, guest
  ///   - updated: The last updated timestamp for the object
  ///   - lastActiveTimestamp: Timestamp for the last time the user information was updated or modified
  public convenience init(
    chat: ChatImpl,
    id: String,
    name: String? = nil,
    externalId: String? = nil,
    profileUrl: String? = nil,
    email: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    status: String? = nil,
    type: String? = nil,
    updated: String? = nil,
    lastActiveTimestamp: Timetoken? = nil
  ) {
    let underlyingUser = PubNubChat.UserImpl(
      chat: chat.chat,
      id: id,
      name: name,
      externalId: externalId,
      profileUrl: profileUrl,
      email: email,
      custom: custom?.compactMapValues { $0.rawValue },
      status: status,
      type: type,
      updated: updated,
      lastActiveTimestamp: lastActiveTimestamp?.asKotlinLong()
    )
    self.init(
      user: underlyingUser
    )
  }

  convenience init?(user: PubNubChat.User?) {
    if let user {
      self.init(user: user)
    } else {
      return nil
    }
  }

  init(user: PubNubChat.User) {
    self.user = user
  }
}

extension UserImpl: User {
  public var chat: ChatImpl { ChatAdapter.map(chat: user.chat).chat }
  public var id: String { user.id }
  public var name: String? { user.name }
  public var externalId: String? { user.externalId }
  public var profileUrl: String? { user.profileUrl }
  public var email: String? { user.email }
  public var custom: [String: JSONCodableScalar]? { user.custom?.mapToScalars() }
  public var status: String? { user.status }
  public var type: String? { user.type }
  public var updated: String? { user.updated }
  public var lastActiveTimestamp: TimeInterval? { user.lastActiveTimestamp?.doubleValue }

  public static func streamUpdatesOn(users: [UserImpl], callback: @escaping (([UserImpl]) -> Void)) -> AutoCloseable {
    AutoCloseableImpl(
      PubNubChat.UserImpl.Companion.shared.streamUpdatesOn(users: users.compactMap { $0.user }) {
        if let users = $0 as? [PubNubChat.User] {
          callback(users.map {
            UserImpl(user: $0)
          })
        }
      }
    )
  }

  public func update(
    name: String? = nil,
    externalId: String? = nil,
    profileUrl: String? = nil,
    email: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    status: String? = nil,
    type: String? = nil,
    completion: ((Swift.Result<UserImpl, Error>) -> Void)? = nil
  ) {
    user.update(
      name: name,
      externalId: externalId,
      profileUrl: profileUrl,
      email: email,
      custom: custom?.asCustomObject(),
      status: status,
      type: type
    ).async(caller: self) { (result: FutureResult<UserImpl, PubNubChat.User>) in
      switch result.result {
      case let .success(user):
        completion?(.success(UserImpl(user: user)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func delete(
    soft: Bool = false,
    completion: ((Swift.Result<UserImpl, Error>) -> Void)? = nil
  ) {
    user.delete(
      soft: soft
    ).async(caller: self) { (result: FutureResult<UserImpl, PubNubChat.UserImpl>) in
      switch result.result {
      case let .success(user):
        completion?(.success(UserImpl(user: user)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func wherePresent(completion: ((Swift.Result<[String], Error>) -> Void)? = nil) {
    user.wherePresent().async(caller: self) { (result: FutureResult<UserImpl, [String]>) in
      switch result.result {
      case let .success(channels):
        completion?(.success(channels))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func isPresentOn(
    channelId: String,
    completion: ((Swift.Result<Bool, Error>) -> Void)? = nil
  ) {
    user.isPresentOn(
      channelId: channelId
    ).async(caller: self) { (result: FutureResult<UserImpl, Bool>) in
      switch result.result {
      case let .success(boolResult):
        completion?(.success(boolResult))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func getMemberships(
    limit: Int? = nil,
    page: PubNubHashedPage? = nil,
    filter: String? = nil,
    sort: [PubNub.MembershipSortField] = [],
    completion: ((Swift.Result<(memberships: [ChatType.ChatMembershipType], page: PubNubHashedPage?), Error>) -> Void)? = nil
  ) {
    user.getMemberships(
      limit: limit?.asKotlinInt,
      page: page?.transform(),
      filter: filter,
      sort: sort.compactMap { $0.transform }
    ).async(caller: self) { (result: FutureResult<UserImpl, MembershipsResponse>) in
      switch result.result {
      case let .success(response):
        completion?(.success((
          memberships: response.memberships.compactMap {
            $0 as? PubNubChat.Membership
          }.map {
            MembershipImpl(membership: $0)
          },
          page: PubNubHashedPageBase(
            start: response.next?.pageHash,
            end: response.prev?.pageHash,
            totalCount: Int(response.total)
          )
        )))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func streamUpdates(callback: @escaping ((UserImpl?) -> Void)) -> AutoCloseable {
    AutoCloseableImpl(
      user.streamUpdates { [weak self] in
        if self != nil {
          if let user = $0 {
            callback(UserImpl(user: user))
          } else {
            callback(nil)
          }
        }
      }
    )
  }

  public func active(completion: ((Swift.Result<Bool, Error>) -> Void)? = nil) {
    user.active().async(caller: self) { (result: FutureResult<UserImpl, Bool>) in
      switch result.result {
      case let .success(boolResult):
        completion?(.success(boolResult))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }
}
