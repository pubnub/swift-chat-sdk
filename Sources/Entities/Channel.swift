//
//  Channel.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

public protocol Channel {
  associatedtype ChatType: Chat
  associatedtype MessageType: Message

  var chat: ChatType { get }
  var id: String { get }
  var name: String? { get }
  var custom: [String: JSONCodableScalar]? { get }
  var description: String? { get }
  var updated: String? { get }
  var status: String? { get }
  var type: ChannelType? { get }

  static func streamUpdatesOn(
    channels: [Self],
    callback: @escaping (([Self]) -> Void)
  ) -> AutoCloseable

  func update(
    name: String?,
    custom: [String: JSONCodableScalar]?,
    description: String?,
    status: String?,
    type: ChannelType?,
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  func delete(
    soft: Bool,
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  func forward(
    message: ChatType.ChatMessageType,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  func startTyping(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func stopTyping(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func getTyping(
    callback: @escaping (([String]) -> Void)
  ) -> AutoCloseable

  func whoIsPresent(
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  func isPresent(
    userId: String,
    completion: ((Swift.Result<Bool, Error>) -> Void)?
  )

  func getHistory(
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(messages: [MessageType], isMore: Bool), Error>) -> Void)?
  )

  @available(*, deprecated, message: "Will be removed from SDK in the future")
  func sendText(
    text: String,
    meta: [String: JSONCodable]?,
    shouldStore: Bool,
    usePost: Bool,
    ttl: Int?,
    mentionedUsers: MessageMentionedUsers?,
    referencedChannels: MessageReferencedChannels?,
    textLinks: [TextLink]?,
    quotedMessage: ChatType.ChatMessageType?,
    files: [InputFile]?,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  func sendText(
    text: String,
    meta: [String: JSONCodable]?,
    shouldStore: Bool,
    usePost: Bool,
    ttl: Int?,
    quotedMessage: ChatType.ChatMessageType?,
    files: [InputFile]?,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  func invite(
    user: ChatType.ChatUserType,
    completion: ((Swift.Result<ChatType.ChatMembershipType, Error>) -> Void)?
  )

  func inviteMultiple(
    users: [ChatType.ChatUserType],
    completion: ((Swift.Result<[ChatType.ChatMembershipType], Error>) -> Void)?
  )

  func getMembers(
    limit: Int?,
    page: PubNubHashedPage?,
    filter: String?,
    sort: [PubNub.MembershipSortField],
    completion: ((Swift.Result<(memberships: [ChatType.ChatMembershipType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  func connect(
    callback: @escaping (ChatType.ChatMessageType) -> Void
  ) -> AutoCloseable

  func join(
    custom: [String: JSONCodableScalar]?,
    callback: ((ChatType.ChatMessageType) -> Void)?,
    completion: ((Swift.Result<(membership: ChatType.ChatMembershipType, disconnect: AutoCloseable?), Error>) -> Void)?
  )

  func leave(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func getPinnedMessage(
    completion: ((Swift.Result<(ChatType.ChatMessageType)?, Error>) -> Void)?
  )

  func getMessage(
    timetoken: Timetoken,
    completion: ((Swift.Result<(ChatType.ChatMessageType)?, Error>) -> Void)?
  )

  func registerForPush(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func unregisterFromPush(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func pinMessage(
    message: ChatType.ChatMessageType,
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  func unpinMessage(
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  func streamUpdates(
    callback: @escaping ((ChatType.ChatChannelType)?) -> Void
  ) -> AutoCloseable

  func streamReadReceipts(
    callback: @escaping (([Timetoken: [String]]) -> Void)
  ) -> AutoCloseable

  func getFiles(
    limit: Int,
    next: String?,
    completion: ((Swift.Result<(files: [GetFileItem], page: PubNubHashedPage?), Error>) -> Void)?
  )

  func deleteFile(
    id: String,
    name: String,
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func streamPresence(
    callback: @escaping (Set<String>) -> Void
  ) -> AutoCloseable

  func getUserSuggestions(
    text: String,
    limit: Int,
    completion: ((Swift.Result<[ChatType.ChatMembershipType], Error>) -> Void)?
  )

  func getMessageReportsHistory(
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(events: [EventWrapper<EventContent>], isMore: Bool), Error>) -> Void)?
  )

  func streamMessageReports(
    callback: @escaping (any Event<EventContent.Report>) -> Void
  ) -> AutoCloseable
}

// MARK: - ThreadChannel

public protocol ThreadChannel: Channel {
  var parentChannelId: String { get }
  var parentMessage: ChatType.ChatMessageType { get }

  func pinMessageToParentChannel(
    message: ChatType.ChatThreadMessageType,
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  func unpinMessageFromParentChannel(
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )
}
