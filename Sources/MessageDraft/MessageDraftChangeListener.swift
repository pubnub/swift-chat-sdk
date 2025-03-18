//
//  MessageDraftChangeListener.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

/// A listener that can be used with ``MessageDraft/addChangeListener(_:)`` to listen for changes to the message draft
/// text and get current mention suggestions.
public protocol MessageDraftChangeListener: AnyObject {
  /// Called when there is a change in the message elements or suggested mentions.
  ///
  /// - Parameters:
  ///   - messageElements: An array of `MessageElement` representing current elements within the message
  ///   - suggestedMentions: A  future object that will return the result of suggested mentions after calling its ``FutureObject/async(completion:)`` method
  func onChange(messageElements: [MessageElement], suggestedMentions: any FutureObject<[SuggestedMention]>)
}

/// A closure-based implementation of the ``MessageDraftChangeListener`` protocol.
///
/// This class allows you to handle delegate events by passing a closure, reducing the need to implement the ``MessageDraftChangeListener`` protocol.
/// This is useful when you want to quickly handle messages without writing additional boilerplate code.
public final class ClosureMessageDraftChangeListener: MessageDraftChangeListener {
  let onChangeClosure: ([MessageElement], any FutureObject<[SuggestedMention]>) -> Void

  init(onChange: @escaping ([MessageElement], any FutureObject<[SuggestedMention]>) -> Void) {
    onChangeClosure = onChange
  }

  public func onChange(messageElements: [MessageElement], suggestedMentions: any FutureObject<[SuggestedMention]>) {
    onChangeClosure(messageElements, suggestedMentions)
  }
}

/// A custom future-like object representing a value that will be provided asynchronously in the future.
public protocol FutureObject<T> {
  /// An associaded type representing the success value associated with this protocol or class. Defined by a conforming type
  associatedtype T
  /// Registers a completion handler to be called asynchronously with the result (success or failure).
  ///
  /// - Parameters:
  ///    - completion: The async result of the call
  ///     - **Success**: A successful value
  ///     - **Failure**: An `Error` describing the failure
  func async(completion: @escaping (Swift.Result<T, Error>) -> Void)
}

///
/// Extension providing `async-await` support for ``FutureObject``.
///
public extension FutureObject {
  func async() async throws -> T {
    try await withCheckedThrowingContinuation { continuation in
      async {
        switch $0 {
        case let .success(result):
          continuation.resume(returning: result)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}

class SuggestedMentionsFuture: FutureObject {
  let future: PubNubChat.PNFuture

  init(future: PubNubChat.PNFuture) {
    self.future = future
  }

  func async(completion: @escaping (Swift.Result<[SuggestedMention], Error>) -> Void) {
    future.async(caller: self) { (result: FutureResult<SuggestedMentionsFuture, [PubNubChat.SuggestedMention]>) in
      switch result.result {
      case let .success(suggestedMentions):
        completion(.success(suggestedMentions.compactMap { SuggestedMention.from(mention: $0) }))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
}
