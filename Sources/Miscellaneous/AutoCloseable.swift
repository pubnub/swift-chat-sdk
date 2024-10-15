//
//  AutoCloseable.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

/// A resource that can be closed or released.
public protocol AutoCloseable {
  /// Closes this resource.
  func close()
}

class AutoCloseableImpl {
  private let underlying: PubNubChat.KotlinAutoCloseable

  init?(_ underlying: PubNubChat.KotlinAutoCloseable?) {
    if let underlying {
      self.underlying = underlying
    } else {
      return nil
    }
  }

  init(_ underlying: PubNubChat.KotlinAutoCloseable) {
    self.underlying = underlying
  }

  deinit {
    underlying.close()
  }
}

extension AutoCloseableImpl: AutoCloseable {
  func close() {
    underlying.close()
  }
}
