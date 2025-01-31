//
//  BaseChannel.swift
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

final class BaseChannel<C: PubNubChat.Channel_, M: PubNubChat.Message>: Channel {
  var chat: ChatImpl { ChatAdapter.map(chat: channel.chat).chat }
  var id: String { channel.id }
  var name: String? { channel.name }
  var custom: [String: JSONCodableScalar]? { channel.custom?.mapToScalars() }
  var description: String? { channel.description_ }
  var updated: String? { channel.updated }
  var status: String? { channel.status }
  var type: ChannelType? { channel.type?.transform() }
  var rawChannel: PubNubChat.Channel_ { channel }

  let channel: C

  init(channel: C) {
    self.channel = channel
  }

  static func streamUpdatesOn(
    channels: [BaseChannel],
    callback: @escaping (([BaseChannel]) -> Void)
  ) -> AutoCloseable {
    AutoCloseableImpl(
      PubNubChat.BaseChannelCompanion.shared.streamUpdatesOn(channels: channels.map(\.channel)) {
        if let channels = $0 as? [C] {
          callback(channels.map {
            BaseChannel(channel: $0)
          })
        }
      }
    )
  }

  func update(
    name: String?,
    custom: [String: JSONCodableScalar]?,
    description: String?,
    status: String?,
    type: ChannelType?,
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  ) {
    channel.update(
      name: name,
      custom: custom?.asCustomObject(),
      description: description,
      status: status,
      type: type?.transform()
    ).async(caller: self) { (result: FutureResult<BaseChannel, C>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func delete(soft: Bool, completion: ((Swift.Result<ChatType.ChatChannelType?, Error>) -> Void)?) {
    channel.delete(
      soft: soft
    ).async(caller: self) { (result: FutureResult<BaseChannel, C?>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func forward(message: ChatType.ChatMessageType, completion: ((Swift.Result<Timetoken, Error>) -> Void)?) {
    channel.forwardMessage(
      message: message.target.message
    ).async(caller: self) { (result: FutureResult<BaseChannel, PNPublishResult>) in
      switch result.result {
      case let .success(res):
        completion?(.success(Timetoken(res.timetoken)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func startTyping(completion: ((Swift.Result<Timetoken?, Error>) -> Void)?) {
    channel.startTyping().async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.PNPublishResult?>) in
      switch result.result {
      case let .success(publishRes):
        completion?(.success(publishRes?.timetoken.asTimetoken()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func stopTyping(completion: ((Swift.Result<Timetoken?, Error>) -> Void)?) {
    channel.stopTyping().async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.PNPublishResult?>) in
      switch result.result {
      case let .success(publishRes):
        completion?(.success(publishRes?.timetoken.asTimetoken()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func getTyping(callback: @escaping (([String]) -> Void)) -> AutoCloseable {
    AutoCloseableImpl(
      channel.getTyping { [weak self] in
        if let typingUserIdentifiers = $0 as? [String], self != nil {
          callback(typingUserIdentifiers)
        }
      }
    )
  }

  func whoIsPresent(completion: ((Swift.Result<[String], Error>) -> Void)?) {
    channel.whoIsPresent().async(caller: self) { (result: FutureResult<BaseChannel, [String]>) in
      switch result.result {
      case let .success(userIdentifiers):
        completion?(.success(userIdentifiers))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func isPresent(userId: String, completion: ((Swift.Result<Bool, Error>) -> Void)?) {
    channel.isPresent(
      userId: userId
    ).async(caller: self) { (result: FutureResult<BaseChannel, Bool>) in
      switch result.result {
      case let .success(isPresent):
        completion?(.success(isPresent))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func getHistory(
    startTimetoken: Timetoken?,
    endTimetoken: Timetoken?,
    count: Int,
    completion: ((Swift.Result<(messages: [BaseMessage<M>], isMore: Bool), Error>) -> Void)?
  ) {
    channel.getHistory(
      startTimetoken: startTimetoken?.asKotlinLong(),
      endTimetoken: endTimetoken?.asKotlinLong(),
      count: Int32(count)
    ).async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.HistoryResponse<M>>) in
      switch result.result {
      case let .success(response):
        completion?(.success((
          messages: (response.messages.map { BaseMessage(message: $0) }),
          isMore: response.isMore
        )))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

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
  ) {
    channel.sendText(
      text: text,
      meta: meta?.compactMapValues { $0.rawValue },
      shouldStore: shouldStore,
      usePost: usePost,
      ttl: ttl?.asKotlinInt,
      mentionedUsers: mentionedUsers?.transform(),
      referencedChannels: referencedChannels?.transform(),
      textLinks: textLinks?.compactMap { $0.transform() },
      quotedMessage: quotedMessage?.target.message,
      files: files?.compactMap { $0.transform() }
    ).async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.PNPublishResult>) in
      switch result.result {
      case let .success(response):
        completion?(.success(Timetoken(response.timetoken)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func sendText(
    text: String,
    meta: [String: JSONCodable]?,
    shouldStore: Bool,
    usePost: Bool,
    ttl: Int?,
    quotedMessage: MessageImpl?,
    files: [InputFile]?,
    usersToMention: [String]? = nil,
    completion: ((Swift.Result<Timetoken, any Error>) -> Void)?
  ) {
    channel.sendText(
      text: text,
      meta: meta?.compactMapValues { $0.rawValue },
      shouldStore: shouldStore,
      usePost: usePost,
      ttl: ttl?.asKotlinInt,
      quotedMessage: quotedMessage?.target.message,
      files: files?.compactMap { $0.transform() },
      usersToMention: usersToMention
    ).async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.PNPublishResult>) in
      switch result.result {
      case let .success(response):
        completion?(.success(Timetoken(response.timetoken)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func invite(user: ChatType.ChatUserType, completion: ((Swift.Result<MembershipImpl, Error>) -> Void)?) {
    channel.invite(
      user: user.user
    ).async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.Membership>) in
      switch result.result {
      case let .success(membership):
        completion?(.success(MembershipImpl(membership: membership)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func inviteMultiple(users: [ChatType.ChatUserType], completion: ((Swift.Result<[ChatType.ChatMembershipType], Error>) -> Void)?) {
    channel.inviteMultiple(
      users: users.compactMap { $0.user }
    ).async(caller: self) { (result: FutureResult<BaseChannel, [PubNubChat.Membership]>) in
      switch result.result {
      case let .success(memberships):
        completion?(.success(memberships.compactMap { MembershipImpl(membership: $0) }))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func getMembers(
    limit: Int?,
    page: PubNubHashedPage?,
    filter: String?,
    sort: [PubNub.MembershipSortField],
    completion: ((Swift.Result<(memberships: [ChatType.ChatMembershipType], page: PubNubHashedPage?), Error>) -> Void)?
  ) {
    channel.getMembers(
      limit: limit?.asKotlinInt,
      page: page?.transform(),
      filter: filter,
      sort: sort.compactMap { $0.transform() }
    ).async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.MembersResponse>) in
      switch result.result {
      case let .success(response):
        completion?(.success(
          (
            memberships: response.members.map {
              MembershipImpl(membership: $0)
            },
            page: PubNubHashedPageBase(
              start: response.next?.pageHash,
              end: response.prev?.pageHash,
              totalCount: Int(response.total)
            )
          )
        ))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func connect(callback: @escaping (ChatType.ChatMessageType) -> Void) -> AutoCloseable {
    AutoCloseableImpl(channel.connect { [weak self] in
      if self != nil, let message = $0 as? M {
        callback(MessageImpl(message: message))
      }
    })
  }

  func join(
    custom: [String: JSONCodableScalar]?,
    callback: ((ChatType.ChatMessageType) -> Void)? = nil,
    completion: ((Swift.Result<(membership: MembershipImpl, disconnect: AutoCloseable?), Error>) -> Void)?
  ) {
    channel.join(custom: custom?.asCustomObject(), callback: { [weak self] in
      if self != nil {
        callback?(MessageImpl(message: $0))
      }
    }).async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.JoinResult>) in
      switch result.result {
      case let .success(joinRes):
        completion?(.success((
          membership: MembershipImpl(membership: joinRes.membership),
          disconnect: AutoCloseableImpl(joinRes.disconnect)
        )))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func leave(completion: ((Swift.Result<Void, Error>) -> Void)?) {
    channel.leave().async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.KotlinUnit>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func getPinnedMessage(completion: ((Swift.Result<(ChatType.ChatMessageType)?, Error>) -> Void)?) {
    channel.getPinnedMessage().async(caller: self) { (result: FutureResult<BaseChannel, M?>) in
      switch result.result {
      case let .success(message):
        if let message {
          completion?(.success(MessageImpl(message: message)))
        } else {
          completion?(.success(nil))
        }
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func getMessage(
    timetoken: Timetoken,
    completion: ((Swift.Result<ChatType.ChatMessageType?, Error>) -> Void)? = nil
  ) {
    channel.getMessage(
      timetoken: Int64(timetoken)
    ).async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.Message?>) in
      switch result.result {
      case let .success(message):
        if let message {
          completion?(.success(MessageImpl(message: message)))
        } else {
          completion?(.success(nil))
        }
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func registerForPush(completion: ((Swift.Result<Void, Error>) -> Void)?) {
    channel.registerForPush().async(
      caller: self
    ) { (result: FutureResult<BaseChannel, PubNubChat.PNPushAddChannelResult>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func unregisterFromPush(completion: ((Swift.Result<Void, Error>) -> Void)?) {
    channel.unregisterFromPush().async(
      caller: self
    ) { (result: FutureResult<BaseChannel, PubNubChat.PNPushRemoveChannelResult>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func pinMessage(message: MessageImpl, completion: ((Swift.Result<BaseChannel<C, M>, Error>) -> Void)?) {
    channel.pinMessage(
      message: message.target.message
    ).async(caller: self) { (result: FutureResult<BaseChannel, C>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(BaseChannel<C, M>(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func unpinMessage(completion: ((Swift.Result<BaseChannel<C, M>, Error>) -> Void)?) {
    channel.unpinMessage().async(caller: self) { (result: FutureResult<BaseChannel, C>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(BaseChannel<C, M>(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func streamUpdates(callback: @escaping ((ChatType.ChatChannelType)?) -> Void) -> AutoCloseable {
    AutoCloseableImpl(
      channel.streamUpdates { [weak self] in
        if self != nil {
          if let channel = $0 {
            callback(ChannelImpl(channel: channel))
          } else {
            callback(nil)
          }
        }
      }
    )
  }

  func streamReadReceipts(callback: @escaping (([Timetoken: [String]]) -> Void)) -> AutoCloseable {
    AutoCloseableImpl(
      channel.streamReadReceipts { [weak self] in
        if self != nil {
          callback(
            $0.reduce(into: [Timetoken: [String]]()) { res, currentItem in
              res[Timetoken(currentItem.key.uint64Value)] = currentItem.value
            }
          )
        }
      }
    )
  }

  func getFiles(
    limit: Int,
    next: String?,
    completion: ((Swift.Result<(files: [GetFileItem], page: PubNubHashedPage?), Error>) -> Void)?
  ) {
    channel.getFiles(
      limit: Int32(limit),
      next: next
    ).async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.GetFilesResult>) in
      switch result.result {
      case let .success(response):
        completion?(
          .success((
            files: (response.files as? [PubNubChat.GetFileItem] ?? []).compactMap {
              GetFileItem(
                name: $0.name,
                id: $0.id,
                url: $0.url
              )
            },
            page: PubNubHashedPageBase(
              start: response.next,
              end: nil,
              totalCount: Int(response.total)
            )
          ))
        )
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func deleteFile(id: String, name: String, completion: ((Swift.Result<Void, Error>) -> Void)?) {
    channel.deleteFile(
      id: id,
      name: name
    ).async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.PNDeleteFileResult>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func streamPresence(callback: @escaping (Set<String>) -> Void) -> AutoCloseable {
    AutoCloseableImpl(
      channel.streamPresence { [weak self] in
        if let userIds = $0 as? Set<String>, self != nil {
          callback(userIds)
        }
      }
    )
  }

  func getUserSuggestions(
    text: String,
    limit: Int,
    completion: ((Swift.Result<[ChatType.ChatMembershipType], Error>) -> Void)?
  ) {
    channel.getUserSuggestions(
      text: text,
      limit: Int32(limit)
    ).async(caller: self) { (result: FutureResult<BaseChannel, [PubNubChat.Membership]>) in
      switch result.result {
      case let .success(userIds):
        completion?(.success(userIds.compactMap {
          MembershipImpl(membership: $0)
        }))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func getMessageReportsHistory(
    startTimetoken: Timetoken? = nil,
    endTimetoken: Timetoken? = nil,
    count: Int = 25,
    completion: ((Swift.Result<(events: [EventWrapper<EventContent>], isMore: Bool), Error>) -> Void)?
  ) {
    channel.getMessageReportsHistory(
      startTimetoken: startTimetoken?.asKotlinLong(),
      endTimetoken: endTimetoken?.asKotlinLong(),
      count: Int32(count)
    ).async(caller: self) { (result: FutureResult<BaseChannel, PubNubChat.GetEventsHistoryResult>) in
      switch result.result {
      case let .success(response):
        completion?(.success((
          events: response.events.compactMap { (event: PubNubChat.Event) -> EventWrapper? in
            EventWrapper(
              event: EventImpl(
                chat: result.caller.chat,
                timetoken: Timetoken(event.timetoken_),
                payload: event.payload.map(),
                channelId: event.channelId,
                userId: event.userId
              )
            )
          },
          isMore: response.isMore
        )))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func streamMessageReports(callback: @escaping (any Event<EventContent.Report>) -> Void) -> AutoCloseable {
    AutoCloseableImpl(
      channel.streamMessageReports { [weak self] in
        if let selfRef = self, let payload = $0.payload.map() as? EventContent.Report {
          callback(
            EventImpl(
              chat: selfRef.chat,
              timetoken: Timetoken($0.timetoken_),
              payload: payload,
              channelId: $0.channelId,
              userId: $0.userId
            )
          )
        }
      }
    )
  }

  func createMessageDraft(
    userSuggestionSource: UserSuggestionSource = .channel,
    isTypingIndicatorTriggered: Bool = true,
    userLimit: Int = 10,
    channelLimit: Int = 10
  ) -> MessageDraftImpl {
    MessageDraftImpl(
      messageDraft: MediatorsKt.createMessageDraft(
        channel,
        userSuggestionSource: userSuggestionSource.transform(),
        isTypingIndicatorTriggered: isTypingIndicatorTriggered,
        userLimit: Int32(userLimit),
        channelLimit: Int32(channelLimit)
      )
    )
  }

  // swiftlint:disable:next file_length
}
