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

public protocol Event<T> {
  associatedtype C: Chat
  associatedtype T: EventContent

  var chat: C { get }
  var timetoken: Timetoken { get }
  var payload: T { get }
  var channelId: String { get }
  var userId: String { get }
}

public struct EventWrapper<T: EventContent> {
  public var event: any Event<T>
}

public struct EventImpl<ChatType: Chat, T: EventContent>: Event {
  public let chat: ChatType
  public let timetoken: Timetoken
  public let payload: T
  public let channelId: String
  public let userId: String
}
