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

/// A concrete implementation of the ``MessageDraft`` protocol.
///
/// This class provides a ready-to-use solution for most use cases requiring
/// the features defined by the ``MessageDraft`` protocol, offering default behavior for
/// associated types and default parameter values where applicable.
///
/// It inherits all the documentation for methods defined in the ``MessageDraft`` protocol.
/// Refer to the ``MessageDraft`` protocol for detailed information on how individual methods work.
public class MessageDraftImpl {
  private let messageDraft: PubNubChat.MessageDraft
  private var listeners: [(KMPMessageDraftChangeListener, MessageDraftChangeListener)] = []

  init(messageDraft: PubNubChat.MessageDraft) {
    self.messageDraft = messageDraft
  }
}

extension MessageDraftImpl: MessageDraft {
  public typealias C = ChannelImpl
  public typealias M = MessageImpl

  public var channel: C {
    ChannelImpl(channel: messageDraft.channel)
  }

  public var isTypingIndicatorTriggered: Bool {
    messageDraft.isTypingIndicatorTriggered
  }

  public var userLimit: Int {
    Int(messageDraft.userLimit)
  }

  public var channelLimit: Int {
    Int(messageDraft.channelLimit)
  }

  public var quotedMessage: M? {
    get {
      MessageImpl(message: messageDraft.quotedMessage)
    } set {
      messageDraft.quotedMessage = newValue?.target.message
    }
  }

  public var files: [InputFile] {
    get {
      messageDraft.files.compactMap { $0 as? PubNubChat.InputFile }.compactMap { InputFile.from(input: $0) }
    } set {
      messageDraft.files.add(newValue.compactMap { $0.transform() })
    }
  }

  public func addChangeListener(_ listener: any MessageDraftChangeListener) {
    let underlyingListener = KMPMessageDraftChangeListener() { elements, mentions in
      listener.onChange(
        messageElements: elements.compactMap { MessageElement.from(element: $0) },
        suggestedMentions: SuggestedMentionsFutureImpl(future: mentions)
      )
    }

    listeners.append((underlyingListener, listener))
    messageDraft.addChangeListener(listener: underlyingListener)
  }

  public func removeChangeListener(_ listener: any MessageDraftChangeListener) {
    for currentPair in listeners where currentPair.1 === listener {
      messageDraft.removeChangeListener(listener: currentPair.0)
    }
    listeners.removeAll {
      $0.0 === listener
    }
  }

  public func insertText(offset: Int, text: String) {
    messageDraft.insertText(offset: Int32(offset), text: text)
  }

  public func removeText(offset: Int, length: Int) {
    messageDraft.removeText(offset: Int32(offset), length: Int32(length))
  }

  public func insertSuggestedMention(mention: SuggestedMention, text: String) {
    messageDraft.insertSuggestedMention(mention: mention.transform(), text: text)
  }

  public func addMention(offset: Int, length: Int, target: MentionTarget) {
    messageDraft.addMention(offset: Int32(offset), length: Int32(length), target: target.transform())
  }

  public func removeMention(offset: Int) {
    messageDraft.removeMention(offset: Int32(offset))
  }

  public func update(text: String) {
    messageDraft.update(text: text)
  }

  public func send(
    meta: [String: JSONCodable]? = nil,
    shouldStore: Bool = true,
    usePost: Bool = false,
    ttl: Int? = nil,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)? = nil
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

class KMPMessageDraftChangeListener: PubNubChat.MessageDraftChangeListener {
  let onChange: ([PubNubChat.MessageElement], PubNubChat.PNFuture) -> Void

  init(onChange: @escaping ([PubNubChat.MessageElement], PubNubChat.PNFuture) -> Void) {
    self.onChange = onChange
  }

  func onChange(messageElements: [PubNubChat.MessageElement], suggestedMentions: any PNFuture) {
    onChange(messageElements, suggestedMentions)
  }
}
