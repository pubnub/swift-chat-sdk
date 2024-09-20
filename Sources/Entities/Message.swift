//
//  Message.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

public protocol Message {
  associatedtype ChatType: Chat

  var chat: ChatType { get }
  var timetoken: Timetoken { get }
  var content: EventContent.TextMessageContent { get }
  var channelId: String { get }
  var userId: String { get }
  var actions: [String: [String: [Action]]]? { get }
  var meta: [String: JSONCodable]? { get }
  var mentionedUsers: MessageMentionedUsers? { get }
  var referencedChannels: MessageReferencedChannels? { get }
  var quotedMessage: QuotedMessage? { get }
  var text: String { get }
  var deleted: Bool { get }
  var hasThread: Bool { get }
  var type: String { get }
  var files: [File] { get }
  var reactions: [String: [Action]] { get }
  var textLinks: [TextLink]? { get }

  static func streamUpdatesOn(
    messages: [Self],
    callback: @escaping (([Self]) -> Void)
  ) -> AutoCloseable

  func hasUserReaction(
    reaction: String
  ) -> Bool

  func editText(
    newText: String,
    completion: ((Swift.Result<ChatType.ChatMessageType, Error>) -> Void)?
  )

  func delete(
    soft: Bool,
    preserveFiles: Bool,
    completion: ((Swift.Result<(ChatType.ChatMessageType)?, Error>) -> Void)?
  )

  func getThread(
    completion: ((Swift.Result<ChatType.ChatThreadChannelType, Error>) -> Void)?
  )

  func forward(
    channelId: String,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  func pin(
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  func report(
    reason: String,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )

  func createThread(
    completion: ((Swift.Result<ChatType.ChatThreadChannelType, Error>) -> Void)?
  )

  func removeThread(
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  func toggleReaction(
    reaction: String,
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )

  func streamUpdates(
    completion: @escaping ((Self) -> Void)
  ) -> AutoCloseable

  func restore(
    completion: ((Swift.Result<Self, Error>) -> Void)?
  )
}

public protocol ThreadMessage: Message {
  var parentChannelId: String { get }

  func pinToParentChannel(
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  func unpinFromParentChannel(
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )
}
