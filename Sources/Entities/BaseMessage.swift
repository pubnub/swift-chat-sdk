//
//  BaseMessage.swift
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

final class BaseMessage<M: PubNubChat.Message> {
  let message: M

  init(message: M) {
    self.message = message
  }

  convenience init?(message: M?) {
    if let message {
      self.init(message: message)
    } else {
      return nil
    }
  }
}

extension BaseMessage: Message {
  public var chat: ChatImpl { ChatAdapter.map(chat: message.chat).chat }
  public var timetoken: Timetoken { Timetoken(message.timetoken_) }
  public var content: EventContent.TextMessageContent { message.content.transform() }
  public var channelId: String { message.channelId }
  public var userId: String { message.userId }
  public var actions: [String: [String: [Action]]]? { message.actions?.transform() }
  public var meta: [String: JSONCodable]? { message.meta?.compactMapValues { AnyJSON($0) } }
  public var mentionedUsers: MessageMentionedUsers? { message.mentionedUsers?.transform() }
  public var referencedChannels: MessageReferencedChannels? { message.referencedChannels?.transform() }
  public var quotedMessage: QuotedMessage? { message.quotedMessage?.transform() }
  public var text: String { message.text }
  public var deleted: Bool { message.deleted }
  public var hasThread: Bool { message.hasThread }
  public var type: String { message.type }
  public var files: [File] { message.files.transform() }
  public var reactions: [String: [Action]] { message.reactions.transform() }
  public var textLinks: [TextLink]? { message.textLinks?.transform() }
  public var error: Error? { message.error }

  static func streamUpdatesOn(
    messages: [BaseMessage],
    callback: @escaping (([BaseMessage]) -> Void)
  ) -> AutoCloseable {
    AutoCloseableImpl(
      PubNubChat.BaseMessageCompanion.shared.streamUpdatesOn(messages: messages.map(\.message)) {
        if let messages = $0 as? [M] {
          callback(messages.map {
            BaseMessage(message: $0)
          })
        }
      }
    )
  }

  public func hasUserReaction(reaction: String) -> Bool {
    message.hasUserReaction(
      reaction: reaction
    )
  }

  public func editText(
    newText: String,
    completion: ((Swift.Result<MessageImpl, Error>) -> Void)?
  ) {
    message.editText(
      newText: newText
    ).async(caller: self) { (result: FutureResult<BaseMessage, M>) in
      switch result.result {
      case let .success(message):
        completion?(.success(MessageImpl(message: message)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func delete(
    soft: Bool = false,
    preserveFiles: Bool = false,
    completion: ((Swift.Result<MessageImpl?, Error>) -> Void)?
  ) {
    message.delete(
      soft: soft,
      preserveFiles: preserveFiles
    ).async(caller: self) { (result: FutureResult<BaseMessage, M?>) in
      switch result.result {
      case let .success(message):
        completion?(.success(MessageImpl(message: message)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func getThread(completion: ((Swift.Result<ThreadChannelImpl, Error>) -> Void)?) {
    message.getThread().async(caller: self) { (result: FutureResult<BaseMessage, PubNubChat.ThreadChannel>) in
      switch result.result {
      case let .success(threadChannel):
        completion?(.success(ThreadChannelImpl(channel: threadChannel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func forward(
    channelId: String,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  ) {
    message.forward(
      channelId: channelId
    ).async(caller: self) { (result: FutureResult<BaseMessage, PubNubChat.PNPublishResult>) in
      switch result.result {
      case let .success(result):
        completion?(.success(Timetoken(result.timetoken)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func pin(completion: ((Swift.Result<ChannelImpl, Error>) -> Void)?) {
    message.pin().async(caller: self) { (result: FutureResult<BaseMessage<M>, PubNubChat.Channel_>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func report(
    reason: String,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  ) {
    message.report(
      reason: reason
    ).async(caller: self) { (result: FutureResult<BaseMessage, PubNubChat.PNPublishResult>) in
      switch result.result {
      case let .success(result):
        completion?(.success(Timetoken(result.timetoken)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func createThread(completion: ((Swift.Result<ThreadChannelImpl, Error>) -> Void)? = nil) {
    message.createThread().async(caller: self) { (result: FutureResult<BaseMessage, PubNubChat.ThreadChannel>) in
      switch result.result {
      case let .success(threadChannel):
        completion?(.success(ThreadChannelImpl(channel: threadChannel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func createThread(
    text: String,
    meta: [String: JSONCodable]?,
    shouldStore: Bool,
    usePost: Bool,
    ttl: Int?,
    quotedMessage: MessageImpl?,
    files: [InputFile]?,
    usersToMention: [String]?,
    customPushData: [String: String]?,
    completion: ((Swift.Result<ThreadChannelImpl, Error>) -> Void)?
  ) {
    message.createThread(
      text: text,
      meta: meta?.compactMapValues { $0.rawValue },
      shouldStore: shouldStore,
      usePost: usePost,
      ttl: ttl?.asKotlinInt,
      quotedMessage: quotedMessage?.target.message,
      files: files?.compactMap { $0.transform() },
      usersToMention: usersToMention,
      customPushData: customPushData
    ).async(caller: self) { (result: FutureResult<BaseMessage, PubNubChat.ThreadChannel>) in
      switch result.result {
      case let .success(threadChannel):
        completion?(.success(ThreadChannelImpl(channel: threadChannel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func removeThread(completion: ((Swift.Result<ChannelImpl?, Error>) -> Void)?) {
    message.removeThread().async(
      caller: self
    ) { (result: FutureResult<BaseMessage, KotlinPair<PNRemoveMessageActionResult, PubNubChat.ThreadChannel>>) in
      switch result.result {
      case let .success(pair):
        completion?(.success(ChannelImpl(channel: pair.second)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func toggleReaction(
    reaction: String,
    completion: ((Swift.Result<BaseMessage<M>, Error>) -> Void)?
  ) {
    message.toggleReaction(
      reaction: reaction
    ).async(caller: self) { (result: FutureResult<BaseMessage, M>) in
      switch result.result {
      case let .success(message):
        completion?(.success(BaseMessage(message: message)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func streamUpdates(completion: @escaping ((BaseMessage<M>) -> Void)) -> AutoCloseable {
    AutoCloseableImpl(
      message.streamUpdates { [weak self] in
        if let message = $0 as? M, self != nil {
          completion(BaseMessage(message: message))
        }
      },
      owner: self
    )
  }

  func restore(completion: ((Swift.Result<BaseMessage<M>, Error>) -> Void)?) {
    message.restore().async(caller: self) { (result: FutureResult<BaseMessage, M>) in
      switch result.result {
      case let .success(message):
        completion?(.success(BaseMessage(message: message)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func getMessageElements() -> [MessageElement] {
    MediatorsKt.getMessageElements(message).compactMap { MessageElement.from(element: $0) }
  }

  func createThreadMessageDraft(
    userSuggestionSource: UserSuggestionSource,
    isTypingIndicatorTriggered: Bool,
    userLimit: Int,
    channelLimit: Int,
    completion: ((Swift.Result<MessageDraftImpl, Error>) -> Void)?
  ) {
    MediatorsKt.createThreadMessageDraft(
      message,
      userSuggestionSource: userSuggestionSource.transform(),
      isTypingIndicatorTriggered: isTypingIndicatorTriggered,
      userLimit: Int32(userLimit),
      channelLimit: Int32(channelLimit)
    ).async(caller: self) { (result: FutureResult<BaseMessage, PubNubChat.MessageDraft>) in
      switch result.result {
      case let .success(messageDraft):
        completion?(.success(MessageDraftImpl(messageDraft: messageDraft)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }
}
