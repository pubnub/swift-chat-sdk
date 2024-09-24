//
//  Chat.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

public protocol Chat: AnyObject {
  associatedtype ChatUserType: User
  associatedtype ChatChannelType: Channel
  associatedtype ChatThreadChannelType: ThreadChannel
  associatedtype ChatMembershipType: Membership
  associatedtype ChatMessageType: Message
  associatedtype ChatThreadMessageType: ThreadMessage

  var config: ChatConfiguration { get }
  var pubNub: PubNub { get }
  var currentUser: ChatUserType { get }
  var editMessageActionName: String { get }
  var deleteMessageActionName: String { get }

  func initialize(
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  func createUser(
    user: ChatUserType,
    completion: ((Swift.Result<ChatUserType, Error>) -> Void)?
  )

  func createUser(
    id: String,
    name: String?,
    externalId: String?,
    profileUrl: String?,
    email: String?,
    custom: [String: JSONCodableScalar]?,
    status: String?,
    type: String?,
    completion: ((Swift.Result<ChatUserType, Error>) -> Void)?
  )

  func getUser(
    userId: String,
    completion: ((Swift.Result<ChatUserType?, Error>) -> Void)?
  )

  func getUsers(
    filter: String?,
    sort: [PubNub.ObjectSortField],
    limit: Int?,
    page: PubNubHashedPage?,
    completion: ((Swift.Result<(users: [ChatUserType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  func updateUser(
    id: String,
    name: String?,
    externalId: String?,
    profileUrl: String?,
    email: String?,
    custom: [String: JSONCodableScalar]?,
    status: String?,
    type: String?,
    completion: ((Swift.Result<ChatUserType, Error>) -> Void)?
  )

  func deleteUser(
    id: String,
    soft: Bool,
    completion: ((Swift.Result<ChatUserType, Error>) -> Void)?
  )

  func wherePresent(
    userId: String,
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  func isPresent(
    userId: String,
    channelId: String,
    completion: ((Swift.Result<Bool, Error>) -> Void)?
  )

  func createChannel(
    id: String,
    name: String?,
    description: String?,
    custom: [String: JSONCodableScalar]?,
    type: ChannelType?,
    status: String?,
    completion: ((Swift.Result<ChatChannelType, Error>) -> Void)?
  )

  func getChannel(
    channelId: String,
    completion: ((Swift.Result<ChatChannelType?, Error>) -> Void)?
  )

  func getChannels(
    filter: String?,
    sort: [PubNub.ObjectSortField],
    limit: Int?,
    page: PubNubHashedPage?,
    completion: ((Swift.Result<(channels: [ChatChannelType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  func updateChannel(
    id: String,
    name: String?,
    custom: [String: JSONCodableScalar]?,
    description: String?,
    status: String?,
    type: ChannelType?,
    completion: ((Swift.Result<ChatChannelType, Error>) -> Void)?
  )

  func deleteChannel(
    id: String,
    soft: Bool,
    completion: ((Swift.Result<ChatChannelType, Error>) -> Void)?
  )

  func forwardMessage(
    message: ChatMessageType,
    channelId: String,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  func whoIsPresent(
    channelId: String,
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  func emitEvent<T: EventContent>(
    channelId: String,
    payload: T,
    mergePayloadWith otherPayload: [String: JSONCodable]?,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  func createPublicConversation(
    channelId: String?,
    channelName: String?,
    channelDescription: String?,
    channelCustom: [String: JSONCodableScalar]?,
    channelStatus: String?,
    completion: ((Swift.Result<ChatChannelType, Error>) -> Void)?
  )

  func createDirectConversation(
    invitedUser: UserImpl,
    channelId: String?,
    channelName: String?,
    channelDescription: String?,
    channelCustom: [String: JSONCodableScalar]?,
    channelStatus: String?,
    membershipCustom: [String: JSONCodableScalar]?,
    completion: ((Swift.Result<CreateDirectConversationResult<ChatChannelType, ChatMembershipType>, Error>) -> Void)?
  )

  func createGroupConversation(
    invitedUsers: [UserImpl],
    channelId: String?,
    channelName: String?,
    channelDescription: String?,
    channelCustom: [String: JSONCodableScalar]?,
    channelStatus: String?,
    membershipCustom: [String: JSONCodableScalar]?,
    completion: ((Swift.Result<CreateGroupConversationResult<ChatChannelType, ChatMembershipType>, Error>) -> Void)?
  )

  func listenForEvents<T: EventContent>(
    type: T.Type,
    channelId: String,
    customMethod: EmitEventMethod,
    callback: @escaping ((EventWrapper<T>) -> Void)
  ) -> AutoCloseable

  func registerPushChannels(
    channels: [String],
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func unregisterPushChannels(
    channels: [String],
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func unregisterAllPushChannels(
    completion: ((Swift.Result<Void, Error>) -> Void)?
  )

  func getThreadChannel(
    message: ChatMessageType,
    completion: ((Swift.Result<ChatThreadChannelType, Error>) -> Void)?
  )

  func getUnreadMessagesCount(
    limit: Int?,
    page: PubNubHashedPage?,
    filter: String?,
    sort: [PubNub.MembershipSortField],
    completion: ((Swift.Result<[GetUnreadMessagesCount<ChannelImpl, MembershipImpl>], Error>) -> Void)?
  )

  func markAllMessagesAsRead(
    limit: Int?,
    page: PubNubHashedPage?,
    filter: String?,
    sort: [PubNub.MembershipSortField],
    completion: ((Swift.Result<(memberships: [ChatMembershipType], page: PubNubHashedPage?), Error>) -> Void)?
  )

  func getChannelSuggestions(
    text: String,
    limit: Int,
    completion: ((Swift.Result<[ChatChannelType], Error>) -> Void)?
  )

  func getUserSuggestions(
    text: String,
    limit: Int,
    completion: ((Swift.Result<[ChatUserType], Error>) -> Void)?
  )

  func getPushChannels(
    completion: ((Swift.Result<[String], Error>) -> Void)?
  )

  func getEventsHistory(
    channelId: String,
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(events: [EventWrapper<EventContent>], isMore: Bool), Error>) -> Void)?
  )

  func getCurrentUserMentions(
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(mentions: [UserMentionDataWrapper<ChatMessageType>], isMore: Bool), Error>) -> Void)?
  )

  func destroy()
}
