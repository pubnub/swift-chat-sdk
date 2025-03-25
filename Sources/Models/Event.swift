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
public protocol Event<C, T> {
  associatedtype C: Chat
  associatedtype T: EventContentProtocol

  /// Reference to the main Chat object
  var chat: C { get }
  /// Timetoken of the message that triggered an event
  var timetoken: Timetoken { get }
  /// Data passed in an event (of ``EventContentProtocol`` subtype) that differs depending on the emitted event type
  var payload: T { get }
  /// Target channel where this event is delivered
  var channelId: String { get }
  /// Unique ID of the user that triggered the event
  var userId: String { get }
}

/// A struct representing any ``Event`` and abstracting the concrete ``Event/payload`` type.
public struct AnyEvent<C: Chat> {
  /// Reference to the main Chat object
  public var chat: C
  /// Timetoken of the message that triggered an event
  public var timetoken: Timetoken
  /// Data passed in an event (of ``EventContentProtocol`` subtype) that differs depending on the emitted event type
  public var payload: any EventContentProtocol
  /// Target channel where this event is delivered
  public var channelId: String
  /// Unique ID of the user that triggered the event
  public var userId: String
}

/// A concrete implementation of ``Event`` protocol with strongly typed ``payload`` property.
public struct EventImpl<C: Chat, T: EventContentProtocol>: Event {
  /// Reference to the main Chat object
  public var chat: C
  /// Timetoken of the message that triggered an event
  public var timetoken: Timetoken
  /// Data passed in an event (of ``EventContentProtocol`` subtype) that differs depending on the emitted event type
  public var payload: T
  /// Target channel where this event is delivered
  public var channelId: String
  /// Unique ID of the user that triggered the event
  public var userId: String
}
