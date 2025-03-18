//
//  ThreadMessage+AsyncAwait.swift
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
/// Extension providing `async-await` support for ``ThreadMessage``.
///
public extension ThreadMessage {
  /// Pins the thread message to the parent channel.
  ///
  /// This action updates the parent channel's metadata with the following fields:
  ///
  ///  * `pinnedMessageTimetoken`: The timetoken marking when the message was pinned
  ///  * `pinnedMessageChannelID`: The ID of the channel where the message was pinned (either the parent channel or a thread channel)
  ///
  /// - Returns: The updated ``Channel`` with the pinned message metadata
  @discardableResult
  func pinToParentChannel() async throws -> ChatType.ChatChannelType {
    try await withCheckedThrowingContinuation { continuation in
      pinToParentChannel {
        switch $0 {
        case let .success(channel):
          continuation.resume(returning: channel)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Unpins the thread message from the parent channel.
  ///
  /// This action updates the parent channel's metadata, removing the pinned message information:
  ///
  ///  * `pinnedMessageTimetoken`: The timetoken marking when the message was pinned
  ///  * `pinnedMessageChannelID`: The ID of the channel where the message was pinned (either the parent channel or a thread channel)
  ///
  /// - Returns: The updated Channel after the message is unpinned
  @discardableResult
  func unpinFromParentChannel() async throws -> ChatType.ChatChannelType {
    try await withCheckedThrowingContinuation { continuation in
      unpinFromParentChannel {
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
