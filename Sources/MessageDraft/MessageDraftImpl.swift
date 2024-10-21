//
//  MessageDraftImpl.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK
import PubNubChat

class MessageDraftImpl {
  private let messageDraft: PubNubChat.MessageDraft
  private var listeners: [(KMPMessageDraftStateListener, MessageDraftStateListener)] = []

  init(messageDraft: PubNubChat.MessageDraft) {
    self.messageDraft = messageDraft
  }
}

extension MessageDraftImpl: MessageDraft {
  typealias C = ChannelImpl
  typealias M = MessageImpl

  var channel: C {
    ChannelImpl(channel: messageDraft.channel)
  }

  var isTypingIndicatorTriggered: Bool {
    messageDraft.isTypingIndicatorTriggered
  }

  var userLimit: Int {
    Int(messageDraft.userLimit)
  }

  var channelLimit: Int {
    Int(messageDraft.channelLimit)
  }

  var quotedMessage: M? {
    MessageImpl(message: messageDraft.quotedMessage)
  }

  var files: [InputFile] {
    messageDraft.files.compactMap { $0 as? PubNubChat.InputFile }.compactMap { InputFile.from(input: $0) }
  }

  func addMessageElementsListener(_ listener: any MessageDraftStateListener) {
    let underlyingListener = KMPMessageDraftStateListener { elements, mentions in
      listener.onChange(
        messageElements: elements.compactMap { MessageElement.from(element: $0) },
        suggestedMentions: SuggestedMentionsFuture(future: mentions)
      )
    }

    listeners.append((underlyingListener, listener))
    messageDraft.addMessageElementsListener(callback: underlyingListener)
  }

  func removeMessageElementsListener(_ listener: any MessageDraftStateListener) {
    for currentPair in listeners where currentPair.1 === listener {
      messageDraft.removeMessageElementsListener(callback: currentPair.0)
    }
    listeners.removeAll {
      $0.0 === listener
    }
  }

  func insertText(offset: Int, text: String) {
    messageDraft.insertText(offset: Int32(offset), text: text)
  }

  func removeText(offset: Int, length: Int) {
    messageDraft.removeText(offset: Int32(offset), length: Int32(length))
  }

  func insertSuggestedMention(mention: SuggestedMention, text: String) {
    messageDraft.insertSuggestedMention(mention: mention.transform(), text: text)
  }

  func addMention(offset: Int, length: Int, target: MentionTarget) {
    messageDraft.addMention(offset: Int32(offset), length: Int32(length), target: target.transform())
  }

  func removeMention(offset: Int) {
    messageDraft.removeMention(offset: Int32(offset))
  }

  func update(text: String) {
    messageDraft.update(text: text)
  }

  func send(
    meta: [String: JSONCodable]? = nil,
    shouldStore: Bool = true,
    usePost: Bool = false,
    ttl: Int? = nil,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  ) {
    messageDraft.send(
      meta: meta?.compactMapValues { $0.rawValue },
      shouldStore: shouldStore,
      usePost: usePost,
      ttl: ttl?.asKotlinInt
    ).async(caller: self) { (result: FutureResult<MessageDraftImpl, PNPublishResult>) in
      switch result.result {
      case let .success(result):
        completion?(.success(Timetoken(result.timetoken)))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }
}

class KMPMessageDraftStateListener: PubNubChat.MessageDraftStateListener {
  let onChange: ([PubNubChat.MessageElement], PubNubChat.PNFuture) -> Void

  init(onChange: @escaping ([PubNubChat.MessageElement], PubNubChat.PNFuture) -> Void) {
    self.onChange = onChange
  }

  func onChange(messageElements: [PubNubChat.MessageElement], suggestedMentions: any PNFuture) {
    onChange(messageElements, suggestedMentions)
  }
}
