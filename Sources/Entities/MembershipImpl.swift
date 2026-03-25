//
//  MembershipImpl.swift
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

/// A concrete implementation of the ``Membership`` protocol.
///
/// This class provides a ready-to-use solution for most use cases requiring
/// the features defined by the ``Membership`` protocol, offering default behavior for
/// associated types and default parameter values where applicable.
///
/// It inherits all the documentation for methods defined in the ``Membership`` protocol.
/// Refer to the ``Membership`` protocol for detailed information on how individual methods work.
public final class MembershipImpl {
  public let chat: ChatImpl
  let membership: PubNubChat.Membership

  convenience init(
    chat: ChatImpl,
    channel: ChannelImpl,
    user: UserImpl,
    custom: [String: JSONCodableScalar]? = nil,
    updated: String? = nil,
    eTag: String? = nil,
    status: String? = nil,
    type: String? = nil
  ) {
    let underlyingMembership = PubNubChat.MembershipImpl(
      chat: chat.chat,
      channel: channel.target.channel,
      user: user.user,
      custom: custom?.compactMapValues { $0.rawValue },
      updated: updated,
      eTag: eTag,
      status: status,
      type: type
    )
    self.init(
      membership: underlyingMembership,
      chat: chat
    )
  }

  init(membership: PubNubChat.Membership, chat: ChatImpl) {
    self.membership = membership
    self.chat = chat
  }
}

extension MembershipImpl: Membership {
  public var channel: ChannelImpl { ChannelImpl(channel: membership.channel, chat: chat) }
  public var user: UserImpl { UserImpl(user: membership.user, chat: chat) }
  public var custom: [String: JSONCodableScalar]? { membership.custom?.mapToScalars() }
  public var status: String? { membership.status }
  public var type: String? { membership.type }
  public var eTag: String? { membership.eTag }
  public var updated: String? { membership.updated }
  public var lastReadMessageTimetoken: Timetoken? { membership.lastReadMessageTimetoken?.uint64Value }

  public static func streamUpdatesOn(
    memberships: [MembershipImpl],
    callback: @escaping (([MembershipImpl]) -> Void)
  ) -> AutoCloseable {
    guard let firstChat = memberships.first?.chat, memberships.allSatisfy({ $0.chat === firstChat }) else {
      return AutoCloseableImpl.empty()
    }
    return AutoCloseableImpl(
      PubNubChat.MembershipImpl.Companion.shared.streamUpdatesOn(memberships: memberships.compactMap { $0.membership }) { [chat = firstChat] in
        if let memberships = $0 as? [PubNubChat.Membership] {
          callback(memberships.map {
            MembershipImpl(membership: $0, chat: chat)
          })
        }
      }
    )
  }

  public func setLastReadMessage(
    message: MessageImpl,
    completion: ((Swift.Result<MembershipImpl, Error>) -> Void)? = nil
  ) {
    membership.setLastReadMessage(
      message: message.target.message
    ).async(caller: self) { (result: FutureResult<MembershipImpl, PubNubChat.Membership>) in
      switch result.result {
      case let .success(membership):
        completion?(.success(MembershipImpl(membership: membership, chat: result.caller.chat)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func update(
    custom: [String: JSONCodableScalar],
    completion: ((Swift.Result<MembershipImpl, Error>) -> Void)? = nil
  ) {
    membership.update(
      custom: custom
    ).async(caller: self) { (result: FutureResult<MembershipImpl, PubNubChat.Membership>) in
      switch result.result {
      case let .success(membership):
        completion?(.success(MembershipImpl(membership: membership, chat: result.caller.chat)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func setLastReadMessageTimetoken(_ timetoken: Timetoken, completion: ((Swift.Result<MembershipImpl, Error>) -> Void)? = nil) {
    membership.setLastReadMessageTimetoken(
      timetoken: Int64(timetoken)
    ).async(caller: self) { (result: FutureResult<MembershipImpl, PubNubChat.Membership>) in
      switch result.result {
      case let .success(membership):
        completion?(.success(MembershipImpl(membership: membership, chat: result.caller.chat)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func getUnreadMessagesCount(completion: ((Swift.Result<UInt64?, Error>) -> Void)? = nil) {
    membership.getUnreadMessagesCount().async(caller: self) { (result: FutureResult<MembershipImpl, UInt64?>) in
      switch result.result {
      case let .success(messagesCount):
        completion?(.success(messagesCount))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func delete(completion: ((Swift.Result<Void, Error>) -> Void)? = nil) {
    membership.delete().async(caller: self) { (result: FutureResult<MembershipImpl, PubNubChat.KotlinUnit>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func onUpdated(callback: @escaping (MembershipImpl) -> Void) -> AutoCloseable {
    AutoCloseableImpl(
      membership.onUpdated { [weak self] in
        if let self = self {
          callback(MembershipImpl(membership: $0, chat: self.chat))
        }
      },
      owner: self
    )
  }

  public func onDeleted(callback: @escaping () -> Void) -> AutoCloseable {
    AutoCloseableImpl(
      membership.onDeleted { [weak self] in
        if self != nil {
          callback()
        }
      },
      owner: self
    )
  }

  public func streamUpdates(callback: @escaping ((MembershipImpl?) -> Void)) -> AutoCloseable {
    AutoCloseableImpl(
      membership.streamUpdates { [weak self] in
        if let self = self {
          if let membership = $0 {
            callback(MembershipImpl(membership: membership, chat: self.chat))
          } else {
            callback(nil)
          }
        }
      },
      owner: self
    )
  }
}
