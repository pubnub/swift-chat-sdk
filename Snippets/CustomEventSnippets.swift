//
//  CustomEventSnippets.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSwiftChatSDK
import PubNubSDK

var chat: ChatImpl!
var channel: ChannelImpl!
var autoCloseable: AutoCloseable!

// MARK: - Emit Custom Event

func emitCustomEvent() {
  // snippet.customEvents.emit
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let timetoken = try await channel.emitCustomEvent(
        payload: [
          "action": "confetti",
          "sender": "user-123"
        ]
      )
      debugPrint("Custom event emitted at timetoken: \(timetoken)")
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Emit Custom Event with Message Type

func emitCustomEventWithMessageType() {
  // snippet.customEvents.emitWithType
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let timetoken = try await channel.emitCustomEvent(
        payload: [
          "action": "confetti",
          "sender": "user-123"
        ],
        messageType: "celebration"
      )
      debugPrint("Custom event emitted at timetoken: \(timetoken)")
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Listen for Custom Events (AsyncStream)

func listenForCustomEventsAsyncStream() {
  // snippet.customEvents.listen.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      for await customEvent in channel.stream.customEvents() {
        debugPrint("Custom event received from user \(customEvent.userId)")
        debugPrint("Payload: \(customEvent.payload)")
        if let type = customEvent.type {
          debugPrint("Message type: \(type)")
        }
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Listen for Custom Events (Closure)

func listenForCustomEventsClosure() {
  // snippet.customEvents.listen.closure
  // Assumes a "ChannelImpl" reference named "channel"

  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive events. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving events manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = channel.onCustomEvent { customEvent in
    debugPrint("Custom event received from user \(customEvent.userId)")
    debugPrint("Payload: \(customEvent.payload)")
    if let type = customEvent.type {
      debugPrint("Message type: \(type)")
    }
  }
  // snippet.end
}

// MARK: - Get Historical Events

func getEventsHistory() {
  // snippet.customEvents.history
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let result = try await chat.getEventsHistory(
      channelId: "support",
      count: 25
    )
    result.events.forEach { eventWrapper in
      debugPrint("Event at \(eventWrapper.event.timetoken) by \(eventWrapper.event.userId)")
      debugPrint("Payload: \(eventWrapper.event.payload)")
    }
    if result.isMore {
      debugPrint("More events available")
    }
  }
  // snippet.end
}
