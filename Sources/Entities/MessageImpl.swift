//
//  MessageImpl.swift
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

/// A concrete implementation of the ``Message`` protocol.
///
/// This class provides a ready-to-use solution for most use cases requiring
/// the features defined by the ``Message`` protocol, offering default behavior for
/// associated types and default parameter values where applicable.
///
/// It inherits all the documentation for methods defined in the ``Message`` protocol.
/// Refer to the ``Message`` protocol for detailed information on how individual methods work.
public final class MessageImpl {
  let target: BaseMessage<PubNubChat.Message>

  /// Creates a new ``MessageImpl`` instance
  ///
  /// - Parameters:
  ///   - chat: Reference to the main Chat object
  ///   - timetoken: Timetoken for the message
  ///   - content: Original text content of the message
  ///   - channelId: Unique identifier for the channel in which the message was sent
  ///   - userId: Unique ID of the user who sent the message
  ///   - actions: Any actions associated with the message, such as reactions, replies, or other interactive elements
  ///   - meta: Extra information added to the message giving additional context
  ///   - mentionedUsers: List of mentioned users with IDs and names
  ///   - referencedChannels: List of referenced channels with IDs and names
  ///   - quotedMessage: Access the original quoted message
  public convenience init(
    chat: ChatImpl,
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
    let underlyingMessage = PubNubChat.MessageImpl(
      chat: chat.chat,
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
      message: underlyingMessage
    )
  }

  convenience init?(message: PubNubChat.Message?) {
    if let message {
      self.init(message: message)
    } else {
      return nil
    }
  }

  init(message: PubNubChat.Message) {
    target = BaseMessage(message: message)
  }
}

extension MessageImpl: Message {
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

  public static func streamUpdatesOn(
    messages: [MessageImpl],
    callback: @escaping (([MessageImpl]) -> Void)
  ) -> AutoCloseable {
    AutoCloseableImpl(
      PubNubChat.MessageCompanion.shared.streamUpdatesOn(messages: messages.map(\.target.message)) {
        if let messages = $0 as? [PubNubChat.Message] {
          callback(messages.map {
            MessageImpl(message: $0)
          })
        }
      }
    )
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
    completion: ((Swift.Result<MessageImpl, Error>) -> Void)? = nil
  ) {
    target.toggleReaction(reaction: reaction) {
      switch $0 {
      case let .success(message):
        completion?(.success(MessageImpl(message: message.message)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func streamUpdates(completion: @escaping ((MessageImpl) -> Void)) -> AutoCloseable {
    target.streamUpdates { [weak self] in
      if self != nil {
        completion(MessageImpl(message: $0.message))
      }
    }
  }

  public func restore(completion: ((Swift.Result<MessageImpl, Error>) -> Void)? = nil) {
    target.restore {
      switch $0 {
      case let .success(message):
        completion?(.success(MessageImpl(message: message.message)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }
}
