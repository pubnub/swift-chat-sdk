//
//  ThreadChannelImpl.swift
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

/// A concrete implementation of the ``ThreadChannel`` protocol.
///
/// This class provides a ready-to-use solution for most use cases requiring
/// the features defined by the ``ThreadChannel`` protocol, offering default behavior for
/// associated types and default parameter values where applicable.
///
/// It inherits all the documentation for methods defined in the ``ThreadChannel`` protocol.
/// Refer to the ``ThreadChannel`` protocol for detailed information on how individual methods work.
public final class ThreadChannelImpl {
  let target: BaseChannel<PubNubChat.ThreadChannel, PubNubChat.ThreadMessage>

  convenience init(
    parentMessage: MessageImpl,
    chat: ChatImpl,
    id: String,
    name: String? = nil,
    custom: [String: JSONCodableScalar],
    description: String? = nil,
    updated: String? = nil,
    status: String? = nil,
    type: ChannelType? = nil
  ) {
    let underlyingThreadChannel = PubNubChat.ThreadChannelImpl(
      parentMessage: parentMessage.target.message,
      chat: chat.chat,
      clock: PubNubChat.ClockSystem(),
      id: id,
      name: name,
      custom: custom.compactMapValues { $0.rawValue },
      description: description,
      updated: updated,
      status: status,
      type: type?.transform(),
      threadCreated: true
    )
    self.init(
      channel: underlyingThreadChannel
    )
  }

  init(channel: PubNubChat.ThreadChannel) {
    target = BaseChannel(channel: channel)
  }

  convenience init?(channel: PubNubChat.ThreadChannel?) {
    if let channel {
      self.init(channel: channel)
    } else {
      return nil
    }
  }
}

extension ThreadChannelImpl: ThreadChannel {
  public var chat: ChatImpl { target.chat }
  public var id: String { target.id }
  public var name: String? { target.name }
  public var custom: [String: JSONCodableScalar]? { target.custom }
  public var description: String? { target.description }
  public var updated: String? { target.updated }
  public var status: String? { target.status }
  public var type: ChannelType? { target.type }
  public var parentMessage: MessageImpl { MessageImpl(message: target.channel.parentMessage) }
  public var parentChannelId: String { target.channel.parentChannelId }

  public static func streamUpdatesOn(
    channels: [ThreadChannelImpl],
    callback: @escaping (([ThreadChannelImpl]) -> Void)
  ) -> AutoCloseable {
    AutoCloseableImpl(
      PubNubChat.ThreadChannelCompanion.shared.streamUpdatesOn(channels: channels.map(\.target.channel)) {
        callback(($0 as? [PubNubChat.ThreadChannel] ?? []).map {
          ThreadChannelImpl(channel: $0)
        })
      }
    )
  }

  public func pinMessageToParentChannel(
    message: ThreadMessageImpl,
    completion: ((Swift.Result<ChannelImpl, Error>) -> Void)? = nil
  ) {
    target.channel.pinMessageToParentChannel(
      message: message.target.message
    ).async(caller: self) { (result: FutureResult<ThreadChannelImpl, PubNubChat.Channel_>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func unpinMessageFromParentChannel(completion: ((Swift.Result<ChannelImpl, Error>) -> Void)? = nil) {
    target.channel.unpinMessageFromParentChannel().async(
      caller: self
    ) { (result: FutureResult<ThreadChannelImpl, PubNubChat.Channel_>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func update(
    name: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    description: String? = nil,
    status: String? = nil,
    type: ChannelType? = nil,
    completion: ((Swift.Result<ChannelImpl, Error>) -> Void)? = nil
  ) {
    target.update(
      name: name,
      custom: custom,
      description: description,
      status: status,
      type: type,
      completion: completion
    )
  }

  public func delete(soft: Bool = false, completion: ((Swift.Result<ChannelImpl?, Error>) -> Void)? = nil) {
    target.delete(
      soft: soft,
      completion: completion
    )
  }

  public func forward(message: MessageImpl, completion: ((Swift.Result<Timetoken, Error>) -> Void)? = nil) {
    target.forward(
      message: message,
      completion: completion
    )
  }

  public func startTyping(completion: ((Swift.Result<Timetoken?, Error>) -> Void)? = nil) {
    target.startTyping(
      completion: completion
    )
  }

  public func stopTyping(completion: ((Swift.Result<Timetoken?, Error>) -> Void)? = nil) {
    target.stopTyping(
      completion: completion
    )
  }

  public func getTyping(callback: @escaping (([String]) -> Void)) -> AutoCloseable {
    target.getTyping(
      callback: callback
    )
  }

  public func whoIsPresent(completion: ((Swift.Result<[String], Error>) -> Void)? = nil) {
    target.whoIsPresent(
      completion: completion
    )
  }

  public func isPresent(userId: String, completion: ((Swift.Result<Bool, Error>) -> Void)? = nil) {
    target.isPresent(
      userId: userId,
      completion: completion
    )
  }

  public func getHistory(
    startTimetoken: Timetoken? = nil,
    endTimetoken: Timetoken? = nil,
    count: Int = 25,
    completion: ((Swift.Result<(messages: [ThreadMessageImpl], isMore: Bool), Error>) -> Void)?
  ) {
    target.getHistory(
      startTimetoken: startTimetoken,
      endTimetoken: endTimetoken,
      count: count
    ) {
      switch $0 {
      case let .success(res):
        completion?(.success((
          messages: res.messages.map { ThreadMessageImpl(message: $0.message) },
          isMore: res.isMore
        )))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func sendText(
    text: String,
    meta: [String: JSONCodable]? = nil,
    shouldStore: Bool = true,
    usePost: Bool = false,
    ttl: Int? = nil,
    mentionedUsers: MessageMentionedUsers? = nil,
    referencedChannels: MessageReferencedChannels? = nil,
    textLinks: [TextLink]? = nil,
    quotedMessage: MessageImpl? = nil,
    files: [InputFile]? = nil,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)? = nil
  ) {
    target.sendText(
      text: text,
      meta: meta,
      shouldStore: shouldStore,
      usePost: usePost,
      ttl: ttl,
      mentionedUsers: mentionedUsers,
      referencedChannels: referencedChannels,
      textLinks: textLinks,
      quotedMessage: quotedMessage,
      files: files,
      completion: completion
    )
  }

  public func sendText(
    text: String,
    meta: [String: JSONCodable]? = nil,
    shouldStore: Bool = true,
    usePost: Bool = false,
    ttl: Int? = nil,
    quotedMessage: MessageImpl? = nil,
    files: [InputFile]?,
    usersToMention: [String]? = nil,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)? = nil
  ) {
    target.sendText(
      text: text,
      meta: meta,
      shouldStore: shouldStore,
      usePost: usePost,
      ttl: ttl,
      quotedMessage: quotedMessage,
      files: files,
      usersToMention: usersToMention,
      completion: completion
    )
  }

  public func invite(user: UserImpl, completion: ((Swift.Result<MembershipImpl, Error>) -> Void)? = nil) {
    target.invite(
      user: user,
      completion: completion
    )
  }

  public func inviteMultiple(users: [UserImpl], completion: ((Swift.Result<[MembershipImpl], Error>) -> Void)? = nil) {
    target.inviteMultiple(
      users: users,
      completion: completion
    )
  }

  public func getMembers(
    limit: Int? = nil,
    page: PubNubHashedPage? = nil,
    filter: String? = nil,
    sort: [PubNub.MembershipSortField] = [],
    completion: ((Swift.Result<(memberships: [MembershipImpl], page: PubNubHashedPage?), Error>) -> Void)? = nil
  ) {
    target.getMembers(
      limit: limit,
      page: page,
      filter: filter,
      sort: sort,
      completion: completion
    )
  }

  public func connect(callback: @escaping (MessageImpl) -> Void) -> AutoCloseable {
    target.connect(
      callback: callback
    )
  }

  public func join(
    custom: [String: JSONCodableScalar]? = nil,
    callback: ((MessageImpl) -> Void)? = nil,
    completion: ((Swift.Result<(membership: MembershipImpl, disconnect: AutoCloseable?), Error>) -> Void)? = nil
  ) {
    target.join(
      custom: custom,
      callback: callback,
      completion: completion
    )
  }

  public func leave(completion: ((Swift.Result<Void, Error>) -> Void)? = nil) {
    target.leave(
      completion: completion
    )
  }

  public func getPinnedMessage(completion: ((Swift.Result<MessageImpl?, Error>) -> Void)? = nil) {
    target.getPinnedMessage(
      completion: completion
    )
  }

  public func getMessage(
    timetoken: Timetoken,
    completion: ((Swift.Result<MessageImpl?, Error>) -> Void)? = nil
  ) {
    target.getMessage(
      timetoken: timetoken,
      completion: completion
    )
  }

  public func registerForPush(completion: ((Swift.Result<Void, Error>) -> Void)? = nil) {
    target.registerForPush(
      completion: completion
    )
  }

  public func unregisterFromPush(completion: ((Swift.Result<Void, Error>) -> Void)? = nil) {
    target.unregisterFromPush(
      completion: completion
    )
  }

  public func pinMessage(message: MessageImpl, completion: ((Swift.Result<ThreadChannelImpl, Error>) -> Void)? = nil) {
    target.pinMessage(message: message) {
      switch $0 {
      case let .success(channel):
        completion?(.success(ThreadChannelImpl(channel: channel.channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func unpinMessage(completion: ((Swift.Result<ThreadChannelImpl, Error>) -> Void)? = nil) {
    target.unpinMessage {
      switch $0 {
      case let .success(channel):
        completion?(.success(ThreadChannelImpl(channel: channel.channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func streamUpdates(callback: @escaping (ChannelImpl?) -> Void) -> AutoCloseable {
    target.streamUpdates(
      callback: callback
    )
  }

  public func streamReadReceipts(callback: @escaping (([Timetoken: [String]]) -> Void)) -> AutoCloseable {
    target.streamReadReceipts(
      callback: callback
    )
  }

  public func getFiles(
    limit: Int = 100,
    next: String? = nil,
    completion: ((Swift.Result<(files: [GetFileItem], page: PubNubHashedPage?), Error>) -> Void)? = nil
  ) {
    target.getFiles(
      limit: limit,
      next: next,
      completion: completion
    )
  }

  public func deleteFile(id: String, name: String, completion: ((Swift.Result<Void, Error>) -> Void)? = nil) {
    target.deleteFile(
      id: id,
      name: name,
      completion: completion
    )
  }

  public func streamPresence(callback: @escaping (Set<String>) -> Void) -> AutoCloseable {
    target.streamPresence(
      callback: callback
    )
  }

  public func getUserSuggestions(
    text: String,
    limit: Int = 10,
    completion: ((Swift.Result<[MembershipImpl], Error>) -> Void)? = nil
  ) {
    target.getUserSuggestions(
      text: text,
      limit: limit,
      completion: completion
    )
  }

  public func getMessageReportsHistory(
    startTimetoken: Timetoken? = nil,
    endTimetoken: Timetoken? = nil,
    count: Int = 25,
    completion: ((Swift.Result<(events: [EventWrapper<EventContent>], isMore: Bool), Error>) -> Void)?
  ) {
    target.getMessageReportsHistory(
      startTimetoken: startTimetoken,
      endTimetoken: endTimetoken,
      count: count,
      completion: completion
    )
  }

  public func streamMessageReports(callback: @escaping (any Event<EventContent.Report>) -> Void) -> AutoCloseable {
    target.streamMessageReports(
      callback: callback
    )
  }

  public func createMessageDraft(
    userSuggestionSource: UserSuggestionSource = .channel,
    isTypingIndicatorTriggered: Bool = true,
    userLimit: Int = 10,
    channelLimit: Int = 10
  ) -> MessageDraftImpl {
    target.createMessageDraft(
      userSuggestionSource: userSuggestionSource,
      isTypingIndicatorTriggered: isTypingIndicatorTriggered,
      userLimit: userLimit,
      channelLimit: channelLimit
    )
  }

  // swiftlint:disable:next file_length
}
