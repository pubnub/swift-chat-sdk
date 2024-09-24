//
//  ThreadMessageImpl.swift
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

public final class ThreadMessageImpl {
  let target: BaseMessage<PubNubChat.ThreadMessage>

  public convenience init(
    chat: ChatImpl,
    parentChannelId: String,
    timetoken: Timetoken,
    content: EventContent.TextMessageContent,
    channelId: String,
    userId: String,
    actions: [String: [String: [Action]]]? = nil,
    meta: [String: JSONCodable]? = nil,
    mentionedUsers: MessageMentionedUsers? = nil,
    referencedChannels: MessageReferencedChannels? = nil,
    quotedMessage: QuotedMessage? = nil
  ) {
    let underlyingThreadMessage = PubNubChat.ThreadMessageImpl(
      chat: chat.chat,
      parentChannelId: parentChannelId,
      timetoken: Int64(timetoken),
      content: content.transform(),
      channelId: channelId,
      userId: userId,
      actions: actions?.transform(),
      meta: meta?.compactMapValues { $0.rawValue },
      mentionedUsers: mentionedUsers?.transform(),
      referencedChannels: referencedChannels?.transform(),
      quotedMessage: quotedMessage?.transform()
    )
    self.init(
      message: underlyingThreadMessage
    )
  }

  convenience init?(message: PubNubChat.ThreadMessage?) {
    if let message {
      self.init(message: message)
    } else {
      return nil
    }
  }

  init(message: PubNubChat.ThreadMessage) {
    target = BaseMessage(message: message)
  }
}

extension ThreadMessageImpl {
  func asMessage() -> MessageImpl {
    MessageImpl(message: target.message)
  }
}

extension ThreadMessageImpl: ThreadMessage {
  public var chat: ChatImpl { target.chat }
  public var timetoken: Timetoken { target.timetoken }
  public var content: EventContent.TextMessageContent { target.content }
  public var channelId: String { target.channelId }
  public var userId: String { target.userId }
  public var actions: [String: [String: [Action]]]? { target.actions }
  public var meta: [String: JSONCodable]? { target.meta }
  public var mentionedUsers: MessageMentionedUsers? { target.mentionedUsers }
  public var referencedChannels: MessageReferencedChannels? { target.referencedChannels }
  public var quotedMessage: QuotedMessage? { target.quotedMessage }
  public var text: String { target.text }
  public var deleted: Bool { target.deleted }
  public var hasThread: Bool { target.hasThread }
  public var type: String { target.type }
  public var files: [File] { target.files }
  public var reactions: [String: [Action]] { target.reactions }
  public var textLinks: [TextLink]? { target.textLinks }
  public var parentChannelId: String { target.message.parentChannelId }

  public static func streamUpdatesOn(
    messages: [ThreadMessageImpl],
    callback: @escaping (([ThreadMessageImpl]) -> Void)
  ) -> AutoCloseable {
    AutoCloseableImpl(
      PubNubChat.ThreadMessageCompanion.shared.streamUpdatesOn(messages: messages.map(\.target.message)) {
        if let messages = $0 as? [PubNubChat.ThreadMessage] {
          callback(messages.map {
            ThreadMessageImpl(message: $0)
          })
        }
      }
    )
  }

  public func pinToParentChannel(completion: ((Swift.Result<ChannelImpl, Error>) -> Void)?) {
    target.message.pinToParentChannel().async(
      caller: self
    ) { (result: FutureResult<ThreadMessageImpl, PubNubChat.Channel_>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func unpinFromParentChannel(completion: ((Swift.Result<ChannelImpl, Error>) -> Void)?) {
    target.message.unpinFromParentChannel().async(
      caller: self
    ) { (result: FutureResult<ThreadMessageImpl, PubNubChat.Channel_>) in
      switch result.result {
      case let .success(channel):
        completion?(.success(ChannelImpl(channel: channel)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func hasUserReaction(reaction: String) -> Bool {
    target.hasUserReaction(
      reaction: reaction
    )
  }

  public func editText(
    newText: String,
    completion: ((Swift.Result<MessageImpl, Error>) -> Void)? = nil
  ) {
    target.editText(
      newText: newText,
      completion: completion
    )
  }

  public func delete(
    soft: Bool = false,
    preserveFiles: Bool = false,
    completion: ((Swift.Result<MessageImpl?, Error>) -> Void)? = nil
  ) {
    target.delete(
      soft: soft,
      preserveFiles: preserveFiles,
      completion: completion
    )
  }

  public func getThread(completion: ((Swift.Result<ThreadChannelImpl, Error>) -> Void)? = nil) {
    target.getThread(
      completion: completion
    )
  }

  public func forward(channelId: String, completion: ((Swift.Result<Timetoken, Error>) -> Void)?) {
    target.forward(
      channelId: channelId,
      completion: completion
    )
  }

  public func pin(completion: ((Swift.Result<ChannelImpl, Error>) -> Void)? = nil) {
    target.pin(
      completion: completion
    )
  }

  public func report(
    reason: String,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)? = nil
  ) {
    target.report(
      reason: reason,
      completion: completion
    )
  }

  public func createThread(completion: ((Swift.Result<ThreadChannelImpl, Error>) -> Void)? = nil) {
    target.createThread(
      completion: completion
    )
  }

  public func removeThread(completion: ((Swift.Result<ChannelImpl, Error>) -> Void)? = nil) {
    target.removeThread(
      completion: completion
    )
  }

  public func toggleReaction(
    reaction: String,
    completion: ((Swift.Result<ThreadMessageImpl, Error>) -> Void)? = nil
  ) {
    target.toggleReaction(reaction: reaction) {
      switch $0 {
      case let .success(message):
        completion?(.success(ThreadMessageImpl(message: message.message)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func streamUpdates(completion: @escaping ((ThreadMessageImpl) -> Void)) -> AutoCloseable {
    target.streamUpdates { [weak self] in
      if self != nil {
        completion(ThreadMessageImpl(message: $0.message))
      }
    }
  }

  public func restore(completion: ((Swift.Result<ThreadMessageImpl, Error>) -> Void)? = nil) {
    target.restore {
      switch $0 {
      case let .success(message):
        completion?(.success(ThreadMessageImpl(message: message.message)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }
}
