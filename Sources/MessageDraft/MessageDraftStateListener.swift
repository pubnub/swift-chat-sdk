//
//  MessageDraftStateListener.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

/// A listener that can be used with ``MessageDraft/addMessageElementsListener(_:)`` to listen for changes to the message draft
/// text and get current mention suggestions.
public protocol MessageDraftStateListener: AnyObject {
  func onChange(messageElements: [MessageElement], suggestedMentions: SuggestedMentionsFuture)
}

/// A closure-based implementation of the ``MessageDraftStateListener`` protocol.
///
/// This class allows you to handle delegate events by passing a closure, reducing the need to implement the ``MessageDraftStateListener`` protocol.
/// This is useful when you want to quickly handle messages without writing additional boilerplate code.
final public class ClosureMessageDraftStateListener: MessageDraftStateListener {
  let onChangeClosure: (([MessageElement], SuggestedMentionsFuture) -> Void)
  
  init(onChange: @escaping ([MessageElement], SuggestedMentionsFuture) -> Void) {
    self.onChangeClosure = onChange
  }
  
  public func onChange(messageElements: [MessageElement], suggestedMentions: SuggestedMentionsFuture) {
    onChangeClosure(messageElements, suggestedMentions)
  }
}

/// A protocol representing a `[SuggestedMention]` value  that will be available in the future.
public protocol SuggestedMentionsFuture {
  /// Starts an asynchronous operation and provides the result upon completion.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The successful result of the operation
  ///     - **Failure**: An `Error` describing the failure
  func async(completion: @escaping (Swift.Result<[SuggestedMention], Error>) -> Void)
}

class SuggestedMentionsFutureImpl: SuggestedMentionsFuture {
  let future: PubNubChat.PNFuture

  init(future: PubNubChat.PNFuture) {
    self.future = future
  }

  func async(completion: @escaping (Swift.Result<[SuggestedMention], Error>) -> Void) {
    future.async(caller: self, callback: { (result: FutureResult<SuggestedMentionsFutureImpl, [PubNubChat.SuggestedMention]>) in
      switch result.result {
      case let .success(suggestedMentions):
        completion(.success(suggestedMentions.compactMap { SuggestedMention.from(mention: $0) }))
      case let .failure(error):
        completion(.failure(error))
      }
    })
  }
}
