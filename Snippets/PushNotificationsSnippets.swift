//
//  PushNotificationsSnippets.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import PubNubSwiftChatSDK

var chat: ChatImpl!

// MARK: - Register For Push

func registerForPush() {
  // snippet.pushNotifications.registerForPush
  // Register the "support" channel for push notifications.
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      try await channel.registerForPush()
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

func registerPushChannels() {
  // snippet.pushNotifications.registerPushChannels
  // Register the list of channels for push notifications.
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    try await chat.registerPushChannels(channels: ["support", "incident-management"])
  }
  // snippet.end
}

// MARK: - List Push Channels

func getPushChannels() {
  // snippet.pushNotifications.getPushChannels
  // Get all channels registered for push notifications.
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let pushChannels = try await chat.getPushChannels()
    debugPrint("Push notifications are registered for the following channels:")
    debugPrint(pushChannels)
  }
  // snippet.end
}

// MARK: - Unregister From Push

func unregisterFromPush() {
  // snippet.pushNotifications.unregisterFromPush
  // Unregister the "support" channel for push notifications.
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      try await channel.unregisterFromPush()
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

func unregisterPushChannels() {
  // snippet.pushNotifications.unregisterPushChannels
  // Unregister the list of channels from push notifications.
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    try await chat.unregisterPushChannels(channels: ["support", "incident-management"])
  }
  // snippet.end
}

func unregisterAllPushChannels() {
  // snippet.pushNotifications.unregisterAllPushChannels
  // Unregister all channels for push notifications.
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    try await chat.unregisterAllPushChannels()
  }
  // snippet.end
}
