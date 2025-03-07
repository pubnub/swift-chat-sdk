//
//  ChatImpl.swift
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

/// A concrete implementation of the ``Chat`` protocol.
///
/// This class should be used as a ready-to-use solution for most use cases requiring the features defined by the ``Chat`` protocol. After creating an instance,
/// make sure to call the `initialize(completion:)` method to properly set up the instance before use.
///
/// This class inherits all the documentation for methods defined in the ``Chat`` protocol.
/// Refer to the ``Chat`` protocol for details on how individual methods work.
public final class ChatImpl {
  public let pubNub: PubNub
  public let config: ChatConfiguration
  public let mutedUsersManager: any MutedUsersManagerInterface

  let chat: PubNubChat.ChatImpl

  /// Initializes a new instance with the given chat and `PubNub` configurations.
  ///
  /// This initializer sets up the object using the provided chat configuration and `PubNub` configuration.
  /// After creating an instance, you must call the ``initialize(completion:)`` method before using the object.
  ///
  /// - Parameters:
  ///   - chatConfiguration: A configuration object of type ``ChatConfiguration`` that defines the chat settings
  ///   - pubNubConfiguration: A configuration object of type `PubNubConfiguration` that defines the `PubNub` settings
  public init(chatConfiguration: ChatConfiguration, pubNubConfiguration: PubNubConfiguration) {
    pubNub = PubNub(configuration: pubNubConfiguration)
    config = chatConfiguration
    chat = ChatImpl.createKMPChat(from: pubNub, config: chatConfiguration)
    mutedUsersManager = MutedUsersManagerImpl(underlying: chat.mutedUsersManager)

    pubNub.setConsumer(identifier: "chat-sdk", value: "CA-SWIFT/\(pubNubSwiftChatSDKVersion)")
    // Creates an association between KMP chat and the current instance
    ChatAdapter.associate(chat: self, rawChat: chat)
  }

  init(pubNub: PubNub, configuration: ChatConfiguration) {
    self.pubNub = pubNub
    config = configuration
    chat = ChatImpl.createKMPChat(from: pubNub, config: configuration)
    mutedUsersManager = MutedUsersManagerImpl(underlying: chat.mutedUsersManager)

    pubNub.setConsumer(identifier: "chat-sdk", value: "CA-SWIFT/\(pubNubSwiftChatSDKVersion)")
    // Creates an association between KMP chat and the current instance
    ChatAdapter.associate(chat: self, rawChat: chat)
  }

  deinit {
    destroy()
    ChatAdapter.clean()
  }
}

extension ChatImpl {
  static func createKMPChat(
    from pubnub: PubNub,
    config: ChatConfiguration
  ) -> PubNubChat.ChatImpl {
    PubNubChat.ChatImpl(
      config: config.transform(),
      pubNub: PubNubImpl.Companion.shared.create(kmpPubNub: KMPPubNub(pubnub: pubnub)),
      editMessageActionName: config.customPayloads?.editMessageActionName ?? MessageActionType.edited.rawValue,
      deleteMessageActionName: config.customPayloads?.deleteMessageActionName ?? MessageActionType.deleted.rawValue,
      reactionsActionName: config.customPayloads?.reactionsActionName ?? MessageActionType.reactions.rawValue,
      timerManager: TimerManagerImpl()
    )
  }

  func createChannel(
    id: String,
    name: String? = nil,
    description: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    type: ChannelType? = nil,
    status: String? = nil,
    completion: ((Swift.Result<ChannelImpl, Error>) -> Void)? = nil
  ) {
    chat.createChannel(
      id: id,
      name: name,
      description: description,
      custom: custom?.asCustomObject(),
      type: type?.transform(),
      status: status
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.Channel_>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func createUser(
    user: UserImpl,
    completion: ((Swift.Result<UserImpl, Error>) -> Void)?
  ) {
    chat.createUser(
      user: user.user
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.User>) in
      switch result.result {
      case let .success(createdUser):
        completion?(.success(UserImpl(user: createdUser)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }
}

extension ChatImpl: Chat {
  public typealias ChatUserType = UserImpl
  public typealias ChatMessageType = MessageImpl
  public typealias ChatThreadMessageType = ThreadMessageImpl
  public typealias ChatMembershipType = MembershipImpl
  public typealias ChatChannelType = ChannelImpl
  public typealias ChatThreadChannelType = ThreadChannelImpl

  public var currentUser: UserImpl { UserImpl(user: chat.currentUser) }
  public var editMessageActionName: String { chat.editMessageActionName }
  public var deleteMessageActionName: String { chat.deleteMessageActionName }
  public var reactionsActionName: String { chat.reactionsActionName }

  public func initialize(completion: ((Swift.Result<ChatImpl, Error>) -> Void)? = nil) {
    chat.initialize().weakAsync(caller: self) { (result: WeakFutureResult<ChatImpl, PubNubChat.Chat>) in
      switch result.result {
      case .success:
        if let caller = result.caller {
          completion?(.success(caller))
        } else {
          completion?(.failure(ChatError(message: chatNoLongerExists)))
        }
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func createUser(
    id: String,
    name: String? = nil,
    externalId: String? = nil,
    profileUrl: String? = nil,
    email: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    status: String? = nil,
    type: String? = nil,
    completion: ((Swift.Result<UserImpl, Error>) -> Void)? = nil
  ) {
    chat.createUser(
      id: id,
      name: name,
      externalId: externalId,
      profileUrl: profileUrl,
      email: email,
      custom: custom?.asCustomObject(),
      status: status,
      type: type
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.User>) in
      switch result.result {
      case let .success(user):
        completion?(.success(UserImpl(user: user)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func getUser(
    userId: String,
    completion: ((Swift.Result<UserImpl?, Error>) -> Void)? = nil
  ) {
    chat.getUser(
      userId: userId
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.User?>) in
      switch result.result {
      case let .success(user):
        completion?(.success(UserImpl(user: user)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func getUsers(
    filter: String? = nil,
    sort: [PubNub.ObjectSortField] = [],
    limit: Int?,
    page: PubNubHashedPage? = nil,
    completion: ((Swift.Result<(users: [UserImpl], page: PubNubHashedPage?), Error>) -> Void)? = nil
  ) {
    chat.getUsers(
      filter: filter,
      sort: sort.compactMap { $0.transform() },
      limit: limit?.asKotlinInt,
      page: page?.transform()
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.GetUsersResponse>) in
      switch result.result {
      case let .success(getUserResponse):
        completion?(
          .success((
            users: getUserResponse.users.compactMap {
              UserImpl(user: $0)
            },
            page: PubNubHashedPageBase(
              start: getUserResponse.next?.pageHash,
              end: getUserResponse.prev?.pageHash,
              totalCount: Int(getUserResponse.total)
            )
          ))
        )
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func updateUser(
    id: String,
    name: String? = nil,
    externalId: String? = nil,
    profileUrl: String? = nil,
    email: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    status: String? = nil,
    type: String? = nil,
    completion: ((Swift.Result<UserImpl, Error>) -> Void)? = nil
  ) {
    chat.updateUser(
      id: id,
      name: name,
      externalId: externalId,
      profileUrl: profileUrl,
      email: email,
      custom: custom?.asCustomObject(),
      status: status,
      type: type
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.User>) in
      switch result.result {
      case let .success(user):
        completion?(.success(UserImpl(user: user)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func deleteUser(
    id: String,
    soft: Bool = false,
    completion: ((Swift.Result<UserImpl?, Error>) -> Void)? = nil
  ) {
    chat.deleteUser(
      id: id,
      soft: soft
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.User?>) in
      switch result.result {
      case let .success(user):
        completion?(.success(UserImpl(user: user)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func wherePresent(
    userId: String,
    completion: ((Swift.Result<[String], Error>) -> Void)? = nil
  ) {
    chat.wherePresent(
      userId: userId
    ).async(caller: self) { (result: FutureResult<ChatImpl, [String]>) in
      switch result.result {
      case let .success(channelIds):
        completion?(.success(channelIds))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func isPresent(
    userId: String,
    channelId: String,
    completion: ((Swift.Result<Bool, Error>) -> Void)? = nil
  ) {
    chat.isPresent(
      userId: userId,
      channelId: channelId
    ).async(caller: self) { (result: FutureResult<ChatImpl, Bool>) in
      switch result.result {
      case let .success(isPresent):
        completion?(.success(isPresent))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func getChannel(
    channelId: String,
    completion: ((Swift.Result<ChannelImpl?, Error>) -> Void)? = nil
  ) {
    chat.getChannel(
      channelId: channelId
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.Channel_?>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func getChannels(
    filter: String? = nil,
    sort: [PubNub.ObjectSortField] = [],
    limit: Int? = nil,
    page: PubNubHashedPage? = nil,
    completion: ((Swift.Result<(channels: [ChannelImpl], page: PubNubHashedPage?), Error>) -> Void)? = nil
  ) {
    chat.getChannels(
      filter: filter,
      sort: sort.compactMap { $0.transform() },
      limit: limit?.asKotlinInt,
      page: page?.transform()
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.GetChannelsResponse>) in
      switch result.result {
      case let .success(getChannelsResponse):
        completion?(
          .success((
            channels: getChannelsResponse.channels.compactMap {
              ChannelImpl(channel: $0)
            },
            page: PubNubHashedPageBase(
              start: getChannelsResponse.next?.pageHash,
              end: getChannelsResponse.prev?.pageHash,
              totalCount: Int(getChannelsResponse.total)
            )
          ))
        )
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func updateChannel(
    id: String,
    name: String? = nil,
    custom: [String: JSONCodableScalar]? = nil,
    description: String? = nil,
    status: String? = nil,
    type: ChannelType? = nil,
    completion: ((Swift.Result<ChannelImpl, Error>) -> Void)? = nil
  ) {
    chat.updateChannel(
      id: id,
      name: name,
      custom: custom?.asCustomObject(),
      description: description,
      status: status,
      type: type?.transform()
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.Channel_>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func deleteChannel(
    id: String,
    soft: Bool = false,
    completion: ((Swift.Result<ChannelImpl?, Error>) -> Void)? = nil
  ) {
    chat.deleteChannel(
      id: id,
      soft: soft
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.Channel_?>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func whoIsPresent(
    channelId: String,
    completion: ((Swift.Result<[String], Error>) -> Void)? = nil
  ) {
    chat.whoIsPresent(
      channelId: channelId
    ).async(caller: self) { (result: FutureResult<ChatImpl, [String]>) in
      switch result.result {
      case let .success(ids):
        completion?(.success(ids))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func emitEvent(
    channelId: String,
    payload: some EventContent,
    mergePayloadWith otherPayload: [String: JSONCodable]? = nil,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)? = nil
  ) {
    chat.emitEvent(
      channelId: channelId,
      payload: EventContent.transform(content: payload),
      mergePayloadWith: otherPayload?.compactMapValues { $0.rawValue }
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.PNPublishResult>) in
      switch result.result {
      case let .success(result):
        completion?(.success(Timetoken(result.timetoken)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func createPublicConversation(
    channelId: String? = nil,
    channelName: String? = nil,
    channelDescription: String? = nil,
    channelCustom: [String: JSONCodableScalar]? = nil,
    channelStatus: String? = nil,
    completion: ((Swift.Result<ChannelImpl, Error>) -> Void)? = nil
  ) {
    chat.createPublicConversation(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      channelCustom: channelCustom?.asCustomObject(),
      channelStatus: channelStatus
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.Channel_>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func createDirectConversation(
    invitedUser: UserImpl,
    channelId: String? = nil,
    channelName: String? = nil,
    channelDescription: String? = nil,
    channelCustom: [String: JSONCodableScalar]? = nil,
    channelStatus: String? = nil,
    membershipCustom: [String: JSONCodableScalar]? = nil,
    completion: ((Swift.Result<CreateDirectConversationResult<ChannelImpl, MembershipImpl>, Error>) -> Void)? = nil
  ) {
    chat.createDirectConversation(
      invitedUser: invitedUser.user,
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      channelCustom: channelCustom?.asCustomObject(),
      channelStatus: channelStatus,
      membershipCustom: membershipCustom?.asCustomObject()
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.CreateDirectConversationResult>) in
      switch result.result {
      case let .success(response):
        completion?(.success(CreateDirectConversationResult(
          channel: ChannelImpl(channel: response.channel),
          hostMembership: MembershipImpl(membership: response.hostMembership),
          inviteeMembership: MembershipImpl(membership: response.inviteeMembership)
        )))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func createGroupConversation(
    invitedUsers: [UserImpl],
    channelId: String? = nil,
    channelName: String? = nil,
    channelDescription: String? = nil,
    channelCustom: [String: JSONCodableScalar]? = nil,
    channelStatus: String? = nil,
    membershipCustom: [String: JSONCodableScalar]? = nil,
    completion: ((Swift.Result<CreateGroupConversationResult<ChannelImpl, MembershipImpl>, Error>) -> Void)? = nil
  ) {
    chat.createGroupConversation(
      invitedUsers: invitedUsers.compactMap { $0.user },
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      channelCustom: channelCustom?.asCustomObject(),
      channelStatus: channelStatus,
      membershipCustom: membershipCustom?.asCustomObject()
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.CreateGroupConversationResult>) in
      switch result.result {
      case let .success(response):
        completion?(.success(CreateGroupConversationResult(
          channel: ChannelImpl(channel: response.channel),
          hostMembership: MembershipImpl(membership: response.hostMembership),
          inviteeMemberships: transformKotlinArray(response.inviteeMemberships) { MembershipImpl(membership: $0) }
        )))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func listenForEvents<T: EventContent>(
    type: T.Type,
    channelId: String,
    customMethod: EmitEventMethod = .publish,
    callback: @escaping ((EventWrapper<T>) -> Void)
  ) -> AutoCloseable {
    AutoCloseableImpl(
      chat.listenForEvents(
        type: T.classIdentifier(type: type),
        channelId: channelId,
        customMethod: customMethod == .publish ? .publish : .signal,
        callback: { [weak self] in
          if let selfRef = self, let payload = $0.payload.map() as? T {
            callback(
              EventWrapper(
                event: EventImpl(
                  chat: selfRef,
                  timetoken: Timetoken($0.timetoken_),
                  payload: payload,
                  channelId: $0.channelId,
                  userId: $0.userId
                )
              )
            )
          }
        }
      ),
      owner: self
    )
  }

  public func registerPushChannels(
    channels: [String],
    completion: ((Swift.Result<Void, Error>) -> Void)? = nil
  ) {
    chat.registerPushChannels(
      channels: channels
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.PNPushAddChannelResult>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func unregisterPushChannels(
    channels: [String],
    completion: ((Swift.Result<Void, Error>) -> Void)? = nil
  ) {
    chat.unregisterPushChannels(
      channels: channels
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.PNPushRemoveChannelResult>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func unregisterAllPushChannels(completion: ((Swift.Result<Void, Error>) -> Void)? = nil) {
    chat.unregisterAllPushChannels().async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.KotlinUnit>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func getUnreadMessagesCount(
    limit: Int? = nil,
    page: PubNubHashedPage? = nil,
    filter: String? = nil,
    sort: [PubNub.MembershipSortField] = [],
    completion: ((Swift.Result<[GetUnreadMessagesCount<ChannelImpl, MembershipImpl>], Error>) -> Void)? = nil
  ) {
    chat.getUnreadMessagesCounts(
      limit: limit?.asKotlinInt,
      page: page?.transform(),
      filter: filter,
      sort: sort.compactMap { $0.transform() }
    ).async(caller: self) { (result: FutureResult<ChatImpl, [PubNubChat.GetUnreadMessagesCounts]>) in
      switch result.result {
      case let .success(response):
        completion?(.success(response.map {
          GetUnreadMessagesCount(
            channel: ChannelImpl(channel: $0.channel),
            membership: MembershipImpl(membership: $0.membership),
            count: UInt64($0.count)
          )
        }))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func markAllMessagesAsRead(
    limit: Int? = nil,
    page: PubNubHashedPage? = nil,
    filter: String? = nil,
    sort: [PubNub.MembershipSortField] = [],
    completion: ((Swift.Result<(memberships: [MembershipImpl], page: PubNubHashedPage?), Error>) -> Void)? = nil
  ) {
    chat.markAllMessagesAsRead(
      limit: limit?.asKotlinInt,
      page: page?.transform(),
      filter: filter,
      sort: sort.compactMap { $0.transform() }
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.MarkAllMessageAsReadResponse>) in
      switch result.result {
      case let .success(response):
        completion?(.success(
          (
            memberships: response.memberships.compactMap {
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

  public func getPushChannels(completion: ((Swift.Result<[String], Error>) -> Void)? = nil) {
    chat.getPushChannels().async(caller: self) { (result: FutureResult<ChatImpl, [String]>) in
      switch result.result {
      case let .success(channelIds):
        completion?(.success(channelIds))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func getEventsHistory(
    channelId: String,
    startTimetoken: Timetoken? = nil,
    endTimetoken: Timetoken? = nil,
    count: Int = 100,
    completion: ((Swift.Result<(events: [EventWrapper<EventContent>], isMore: Bool), Error>) -> Void)? = nil
  ) {
    chat.getEventsHistory(
      channelId: channelId,
      startTimetoken: startTimetoken?.asKotlinLong(),
      endTimetoken: endTimetoken?.asKotlinLong(),
      count: Int32(count)
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.GetEventsHistoryResult>) in
      switch result.result {
      case let .success(response):
        let eventImplArray = response.events.compactMap {
          EventWrapper(event: EventImpl(
            chat: result.caller,
            timetoken: Timetoken($0.timetoken_),
            payload: EventContent.from(rawValue: $0.payload),
            channelId: $0.channelId,
            userId: $0.userId
          ))
        }
        completion?(.success((
          events: eventImplArray,
          isMore: response.isMore
        )))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func getCurrentUserMentions(
    startTimetoken: Timetoken? = nil,
    endTimetoken: Timetoken? = nil,
    count: Int = 100,
    completion: ((Swift.Result<(mentions: [UserMentionDataWrapper<MessageImpl>], isMore: Bool), Error>) -> Void)?
  ) {
    chat.getCurrentUserMentions(
      startTimetoken: startTimetoken?.asKotlinLong(),
      endTimetoken: endTimetoken?.asKotlinLong(),
      count: Int32(count)
    ).async(caller: self) { (result: FutureResult<ChatImpl, PubNubChat.GetCurrentUserMentionsResult>) in
      switch result.result {
      case let .success(response):
        let userMentions = response.enhancedMentionsData.compactMap { mention -> (UserMentionDataWrapper?) in
          if let payload = mention.event.payload.map() as? EventContent.Mention {
            let mentionEvent = EventContent.Mention(
              messageTimetoken: Timetoken(payload.messageTimetoken),
              channel: payload.channel,
              parentChannel: payload.parentChannel
            )
            if let mentionData = mention as? PubNubChat.ChannelMentionData {
              return UserMentionDataWrapper(
                userMentionData: ChannelMentionData(
                  event: mentionEvent,
                  message: MessageImpl(message: mentionData.message),
                  userId: mentionData.userId,
                  channelId: mentionData.channelId
                )
              )
            } else if let mentionData = mention as? PubNubChat.ThreadMentionData {
              return UserMentionDataWrapper(
                userMentionData: ThreadMentionData(
                  event: mentionEvent,
                  message: MessageImpl(message: mentionData.message),
                  userId: mentionData.userId,
                  parentChannelId: mentionData.parentChannelId,
                  threadChannelId: mentionData.threadChannelId
                )
              )
            } else {
              return nil
            }
          } else {
            return nil
          }
        }
        completion?(.success((
          mentions: userMentions,
          isMore: response.isMore
        )))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func destroy() {
    chat.destroy()
  }

  // swiftlint:disable:next file_length
}
