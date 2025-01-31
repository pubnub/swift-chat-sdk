//
//  ThreadChannel.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat
import PubNubSDK

/// Represents an object that refers to a single thread (channel) in a chat.
///
/// ``ThreadChannel`` inherits all the functionalities provided by the ``Channel`` protocol, and include additional behaviors and properties specific to threaded conversations.
/// This type allows for finer control and representation of threads within a parent channel.
public protocol ThreadChannel: Channel {
  /// Unique identifier of the main channel on which you create a subchannel (thread channel) and thread messages
  var parentChannelId: String { get }
  /// Message for which the thread was created
  var parentMessage: ChatType.ChatMessageType { get }

  /// Pins a selected thread message to the thread channel.
  ///
  /// - Parameters:
  ///   - message: A message you want to pin to the selected thread channel
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: An updated `ThreadChannel`
  ///     - **Failure**: An `Error` describing the failure
  func pinMessageToParentChannel(
    message: ChatType.ChatThreadMessageType,
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )

  /// Unpins the previously pinned thread message from the thread channel.
  ///
  /// - Parameters:
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: An updated `ThreadChannel`
  ///     - **Failure**: An `Error` describing the failure
  func unpinMessageFromParentChannel(
    completion: ((Swift.Result<ChatType.ChatChannelType, Error>) -> Void)?
  )
}
