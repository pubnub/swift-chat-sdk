//
//  Event.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

/// An object that refers to a single piece of information emitted when someone is typing, receiving a message, mentioning others in a message, or reporting a message/user to the admin.
/// Contrary to other Chat SDK entities, this object provides no methods. Its only purpose is to pass payloads of different types emitted when certain chat operations occur.
public protocol Event<T> {
  associatedtype C: Chat
  associatedtype T: EventContent

  /// Reference to the main Chat object
  var chat: C { get }
  /// Timetoken of the message that triggered an event
  var timetoken: Timetoken { get }
  /// Data passed in an event (of ``EventContent`` subtype) that differs depending on the emitted event type
  var payload: T { get }
  /// Target channel where this event is delivered
  var channelId: String { get }
  /// Unique ID of the user that triggered the event
  var userId: String { get }
}

// This class was introduced due to the lack of support for runtime parameterized protocols, which are available starting from iOS 16.
// We will be able to remove this class once we increase the deployment target.

/// An object that wraps an ``Event``.
public struct EventWrapper<T: EventContent> {
  /// Stores the underlying ``Event`` object
  public var event: any Event<T>
}

struct EventImpl<ChatType: Chat, T: EventContent>: Event {
  let chat: ChatType
  let timetoken: Timetoken
  let payload: T
  let channelId: String
  let userId: String
}
