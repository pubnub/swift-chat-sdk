//
//  TypingIndicatorSnippets.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import PubNubSwiftChatSDK

var chat: ChatImpl!
var channel: ChannelImpl!
var autoCloseable: AutoCloseable!

// MARK: - Start Typing

func startTyping() {
  // snippet.typingIndicator.start
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      try await channel.startTyping()
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Stop Typing

func stopTyping() {
  // snippet.typingIndicator.stop
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      try await channel.stopTyping()
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - On Typing Changed (AsyncStream)

func onTypingChangedAsyncStream() {
  // snippet.typingIndicator.onTypingChanged.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      for await typingUsers in channel.stream.typingChanges() {
        debugPrint("Typing users: \(typingUsers)")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - On Typing Changed (Closure)

func onTypingChangedClosure() {
  // snippet.typingIndicator.onTypingChanged.closure
  // Assumes a "ChannelImpl" reference named "channel"

  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = channel.onTypingChanged { typingUsers in
    debugPrint("Typing users: \(typingUsers)")
  }
  // snippet.end
}

// MARK: - Get Typing Events (AsyncStream) [Deprecated]

func getTypingAsyncStream() {
  // snippet.typingIndicator.getTyping.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      for await typingUsers in channel.getTyping() {
        debugPrint("Typing users: \(typingUsers)")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get Typing Events (Closure) [Deprecated]

func getTypingClosure() {
  // snippet.typingIndicator.getTyping.closure
  // Assumes a "ChannelImpl" reference named "channel"

  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = channel.getTyping { typingUsers in
    debugPrint("Typing users: \(typingUsers)")
  }
  // snippet.end
}
