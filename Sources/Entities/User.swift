//
//  User.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

public protocol User {
  associatedtype ChatType: Chat

  var chat: ChatType { get }
  var id: String { get }
  var name: String? { get }
  var externalId: String? { get }
  var profileUrl: String? { get }
  var email: String? { get }
  var custom: [String: JSONCodableScalar]? { get }
  var status: String? { get }
  var type: String? { get }
  var updated: String? { get }
  var lastActiveTimestamp: TimeInterval? { get }

  static func streamUpdatesOn(
    users: [ChatType.ChatUserType],
    callback: @escaping (([ChatType.ChatUserType]) -> Void)
  ) -> AutoCloseable

  func update(
    name: String?,
    externalId: String?,
    profileUrl: String?,
    email: String?,
    custom: [String: JSONCodableScalar]?,
    status: String?,
    type: String?,
    completion: ((Swift.Result<ChatType.ChatUserType, Error>) -> Void)?
  )

  func delete(
    soft: Bool,
    completion: ((Swift.Result<ChatType.ChatUserType, Error>) -> Void)?
  )

  func wherePresent(
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  func isPresentOn(
    channelId: String,
    completion: ((Swift.Result<Bool, Error>) -> Void)?
  )

  func getMemberships(
    limit: Int?,
    page: PubNubHashedPage?,
    filter: String?,
    sort: [PubNub.MembershipSortField],
    completion: ((Swift.Result<(memberships: [ChatType.ChatMembershipType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  func streamUpdates(
    callback: @escaping ((ChatType.ChatUserType?) -> Void)
  ) -> AutoCloseable

  func active(
    completion: ((Swift.Result<Bool, Error>) -> Void)?
  )
}
