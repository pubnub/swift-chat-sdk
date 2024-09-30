//
//  ThreadMessage.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// Represents a single message in a thread
///
/// ``ThreadMessage`` inherits all the functionalities provided by the ``Message`` protocol, and include additional behaviors and properties specific to threaded conversations
public protocol ThreadMessage: Message {
  /// Unique identifier of the main channel on which you create a subchannel (thread channel) and thread messages
  var parentChannelId: String { get }

  /// Pins the thread message to the parent channel.
  ///
  /// This action updates the parent channel's metadata with the following fields:
  ///
  ///  * `pinnedMessageTimetoken`: The timetoken marking when the message was pinned
  ///  * `pinnedMessageChannelID`: The ID of the channel where the message was pinned (either the parent channel or a thread channel)
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**:  The updated ``Channel`` with the pinned message metadata
  ///     - **Failure**: An `Error` describing the failure
  func pinToParentChannel(
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  /// Unpins the thread message from the parent channel.
  ///
  /// This action updates the parent channel's metadata, removing the pinned message information:
  ///
  ///  * `pinnedMessageTimetoken`: The timetoken marking when the message was pinned
  ///  * `pinnedMessageChannelID`: The ID of the channel where the message was pinned (either the parent channel or a thread channel)
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**:  The updated Channel after the message is unpinned
  ///     - **Failure**: An `Error` describing the failure
  func unpinFromParentChannel(
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )
}
