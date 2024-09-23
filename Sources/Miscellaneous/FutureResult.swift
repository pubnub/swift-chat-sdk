//
//  FutureResult.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

class FutureResult<C: AnyObject, T> {
  let caller: C
  let result: Swift.Result<T, Error>

  init(result: Swift.Result<T, Error>, caller: C) {
    self.result = result
    self.caller = caller
  }
}

class WeakFutureResult<C: AnyObject, T> {
  weak var caller: C?
  let result: Swift.Result<T, Error>

  init(result: Swift.Result<T, Error>, caller: C?) {
    self.result = result
    self.caller = caller
  }
}

class BaseFutureConsumer<T>: PubNubChat.Consumer {
  func extractValueFromKotlinResult(p: Any?) -> Swift.Result<T, Error> {
    if let result = p as? PubNubChat.Result<AnyObject> {
      if let exception = result.exceptionOrNull() {
        return .failure(ChatError(underlying: exception.asError(), message: exception.message ?? ""))
      } else if let value = result.getOrNull() as? T {
        return .success(value)
      }
    }
    
    return .failure(ChatError(message: "Unexpected argument of type \(type(of: T.self))"))
  }

  func accept(p: Any?) {
    notifyCaller(with: extractValueFromKotlinResult(p: p))
  }

  func notifyCaller(with _: Swift.Result<T, Error>) {
    // Provide implementation in each subclasses
  }
}

class StrongFutureConsumer<C: AnyObject, T>: BaseFutureConsumer<T> {
  private var caller: C?
  private var callback: ((FutureResult<C, T>) -> Void)?

  init(caller: C, callback: @escaping (FutureResult<C, T>) -> Void) {
    self.caller = caller
    self.callback = callback
  }

  override func notifyCaller(with swiftResult: Swift.Result<T, Error>) {
    switch swiftResult {
    case let .success(value):
      // swiftlint:disable:next force_unwrapping
      callback?(.init(result: .success(value), caller: caller!))
    case let .failure(failure):
      // swiftlint:disable:next force_unwrapping
      callback?(.init(result: .failure(failure), caller: caller!))
    }

    caller = nil
    callback = nil
  }
}

class WeakFutureConsumer<C: AnyObject, T>: BaseFutureConsumer<T> {
  private weak var caller: C?
  private var callback: ((WeakFutureResult<C, T>) -> Void)?

  init(caller: C, callback: @escaping (WeakFutureResult<C, T>) -> Void) {
    self.caller = caller
    self.callback = callback
  }

  override func notifyCaller(with swiftResult: Swift.Result<T, Error>) {
    if let caller {
      switch swiftResult {
      case let .success(value):
        callback?(.init(result: .success(value), caller: caller))
      case let .failure(failure):
        callback?(.init(result: .failure(failure), caller: caller))
      }
    } else {
      callback?(.init(result: .failure(ChatError(message: "The caller object does not exists")), caller: nil))
    }

    callback = nil
    caller = nil
  }
}

extension PNFuture {
  func async<C: AnyObject, T>(caller: C, callback: @escaping ((FutureResult<C, T>) -> Void)) {
    async(callback: StrongFutureConsumer(caller: caller, callback: callback))
  }

  func weakAsync<C: AnyObject, T>(caller: C, callback: @escaping ((WeakFutureResult<C, T>) -> Void)) {
    async(callback: WeakFutureConsumer(caller: caller, callback: callback))
  }
}
