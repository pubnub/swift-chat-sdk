//
//  ThreadChannel+AsyncAwait.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

///
/// Extension providing `async-await` support for ``ThreadChannel``.
///
public extension ThreadChannel {
  /// Pins a selected thread message to the thread channel.
  ///
  /// - Parameter message: A message you want to pin to the selected thread channel
  /// - Returns: An updated `ThreadChannel`
  func pinMessageToParentChannel(message: ChatType.ChatThreadMessageType) async throws -> ChatType.ChatChannelType {
    try await withCheckedThrowingContinuation { continuation in
      pinMessageToParentChannel(message: message) {
        switch $0 {
        case let .success(channel):
          continuation.resume(returning: channel)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Unpins the previously pinned thread message from the thread channel.
  ///
  /// - Returns: An updated `ThreadChannel`
  func unpinMessageFromParentChannel() async throws -> ChatType.ChatChannelType {
    try await withCheckedThrowingContinuation { continuation in
      unpinMessageFromParentChannel {
        switch $0 {
        case let .success(channel):
          continuation.resume(returning: channel)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
