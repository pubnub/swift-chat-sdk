//
//  Membership.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

public protocol Membership {
  associatedtype ChatType: Chat

  var chat: ChatType { get }
  var channel: ChatType.ChatChannelType { get }
  var user: ChatType.ChatUserType { get }
  var custom: [String: JSONCodableScalar]? { get }
  var eTag: String? { get }
  var updated: String? { get }
  var lastReadMessageTimetoken: Timetoken? { get }

  static func streamUpdatesOn(
    memberships: [Self],
    callback: @escaping (([Self]) -> Void)
  ) -> AutoCloseable

  func setLastReadMessage(
    message: ChatType.ChatMessageType,
    completion: ((Swift.Result<ChatType.ChatMembershipType, Error>) -> Void)?
  )

  func update(
    custom: [String: JSONCodableScalar],
    completion: ((Swift.Result<ChatType.ChatMembershipType, Error>) -> Void)?
  )

  func setLastReadMessageTimetoken(
    _ timetoken: Timetoken,
    completion: ((Swift.Result<ChatType.ChatMembershipType, Error>) -> Void)?
  )

  func getUnreadMessagesCount(
    completion: ((Swift.Result<UInt64, Error>) -> Void)?
  )

  func streamUpdates(
    callback: @escaping ((ChatType.ChatMembershipType?) -> Void)
  ) -> AutoCloseable
}
