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

  convenience init(
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
    eTag: String? = nil,
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
      eTag: eTag,
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
  public var eTag: String? { user.eTag }
  public var lastActiveTimestamp: TimeInterval? { user.lastActiveTimestamp?.doubleValue }
  public var active: Bool { user.active }

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

  // swiftlint:disable:next cyclomatic_complexity
  public func update(
    updateAction: @escaping (UserImpl) -> [PubNubMetadataChange<PubNubUserMetadata>],
    completion: ((Swift.Result<UserImpl, Error>) -> Void)? = nil
  ) {
    user.update(updateAction: { values, user in
      for change in updateAction(UserImpl(user: user)) {
        switch change {
        case let .stringOptional(keyPath, value):
          switch keyPath {
          case \.name:
            values.name = value
          case \.type:
            values.type = value
          case \.status:
            values.status = value
          case \.externalId:
            values.externalId = value
          case \.profileURL:
            values.profileUrl = value
          case \.email:
            values.email = value
          default:
            break
          }
        case let .customOptional(key, value):
          if key == \.custom {
            values.custom = value
          }
        }
      }
    }).async(caller: self) { (result: FutureResult<UserImpl, PubNubChat.User>) in
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
    completion: ((Swift.Result<UserImpl?, Error>) -> Void)? = nil
  ) {
    user.delete(
      soft: soft
    ).async(caller: self) { (result: FutureResult<UserImpl, PubNubChat.User?>) in
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
          memberships: response.memberships.map {
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
      },
      owner: self
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
