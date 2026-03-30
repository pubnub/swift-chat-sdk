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

// MARK: - Emit Custom Event (Documentation Sample)

func emitCustomEventSample() {
  // snippet.customEvents.emitSample
  // Emit the custom event to the "CUSTOMER-SATISFACTION-CREW" channel.
  // Assuming you have a reference of type "ChannelImpl" named "channel".
  Task {
    try await channel.emitCustomEvent(
      payload: [
        "chatID": "chat1234",
        "timestamp": "2022-04-30T10:30:00Z",
        "customerID": "customer5678",
        "triggerWord": "frustrated"
      ],
      messageType: "customer-satisfaction",
      storeInHistory: true
    )
  }
  // snippet.end
}

// MARK: - Listen for Custom Events (Documentation Sample)

func onCustomEventSample() {
  // snippet.customEvents.onCustomEventSample
  // Function to handle the "frustrated" event and respond to the customer
  func handleFrustratedEvent(customerID: String, triggerWord: String) {
    let response = "Thank you for reaching out. We're sorry to hear that you're \(triggerWord). Our team is here to help."
    // Send the response back to the customer's chat (mocked function)
    sendResponseToCustomerChat(customerID: customerID, response: response)
  }

  // Mocked function to send a response back to the customer's chat
  func sendResponseToCustomerChat(customerID: String, response: String) {
    debugPrint("Sent response to customer \(customerID): \(response)")
  }

  // Listen for custom events on the "CUSTOMER-SATISFACTION-CREW" channel.
  // Assuming you have a reference of type "ChannelImpl" named "channel".
  // Hold a strong reference to the returned "AutoCloseable"; otherwise, it will be canceled.
  let stopCustomEvents = channel.onCustomEvent(messageType: "customer-satisfaction") { event in
    if let triggerWord = event.payload["triggerWord"]?.rawValue as? String {
      if triggerWord == "frustrated" {
        if let customerID = event.payload["customerID"]?.rawValue as? String {
          handleFrustratedEvent(customerID: customerID, triggerWord: triggerWord)
        }
      }
    }
  }

  // AsyncStream equivalent
  Task {
    for await event in channel.stream.customEvents(messageType: "customer-satisfaction") {
      if let triggerWord = event.payload["triggerWord"]?.rawValue as? String {
        debugPrint("Trigger word received: \(triggerWord)")
      }
    }
  }

  // To stop listening:
  stopCustomEvents.close()
  // snippet.end
}

// MARK: - Get Historical Events (Documentation Sample)

func getEventsHistorySample() {
  // snippet.customEvents.historySample
  // Pull historical events from the "CUSTOMER-SATISFACTION-CREW" channel with count of 10.
  // Assuming you have a reference of type "ChatImpl" named "chat"
  Task {
    let historyResponse = try await chat.getEventsHistory(
      channelId: "CUSTOMER-SATISFACTION-CREW",
      count: 10
    )
    historyResponse.events.forEach { wrapper in
      debugPrint("Event at \(wrapper.event.timetoken) by \(wrapper.event.userId)")
      debugPrint("Payload: \(wrapper.event.payload)")
    }
    if historyResponse.isMore {
      debugPrint("More events available")
    }
  }
  // snippet.end
}
