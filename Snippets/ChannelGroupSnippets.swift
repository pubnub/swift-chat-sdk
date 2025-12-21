//
//  ChannelGroupSnippets.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import PubNubSwiftChatSDK

var chat: ChatImpl!
var channelGroup: ChannelGroupImpl!
var supportChannel: ChannelImpl!
var generalChannel: ChannelImpl!
var autoCloseable: AutoCloseable!

// MARK: - Get Channel Group Reference

func getChannelGroupReference() {
  // snippet.channelGroups.getReference
  // Assumes a "ChatImpl" reference named "chat"
  let channelGroup = chat.getChannelGroup(id: "my-channel-group")
  // snippet.end
}

// MARK: - Remove Channel Group

func removeChannelGroup() {
  // snippet.channelGroups.remove
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    try await chat.removeChannelGroup(id: "my-channel-group")
    debugPrint("Channel group removed successfully")
  }
  // snippet.end
}

// MARK: - List Channels

func listChannelsInGroup() {
  // snippet.channelGroups.listChannels
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let channelGroup = chat.getChannelGroup(id: "my-channel-group")
    let result = try await channelGroup.listChannels()
    
    for channel in result.channels {
      debugPrint("Channel: \(channel.id)")
    }
  }
  // snippet.end
}

// MARK: - Add Channels

func addChannelsToGroup() {
  // snippet.channelGroups.addChannels
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let channelGroup = chat.getChannelGroup(id: "my-channel-group")
    let supportChannel = try await chat.getChannel(channelId: "support-channel")
    let generalChannel = try await chat.getChannel(channelId: "general-channel")
    
    if let supportChannel, let generalChannel {
      try await channelGroup.add(channels: [supportChannel, generalChannel])
      debugPrint("Channels added successfully")
    }
  }
  // snippet.end
}

// MARK: - Add Channel Identifiers

func addChannelIdentifiersToGroup() {
  // snippet.channelGroups.addChannelIdentifiers
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let channelGroup = chat.getChannelGroup(id: "my-channel-group")
    try await channelGroup.addChannelIdentifiers(["support-channel", "general-channel"])
    debugPrint("Channel identifiers added successfully")
  }
  // snippet.end
}

// MARK: - Remove Channels

func removeChannelsFromGroup() {
  // snippet.channelGroups.removeChannels
  // Assumes a "ChatImpl" reference named "chat"
  // Assumes "ChannelImpl" references named "supportChannel" and "generalChannel"
  Task {
    let channelGroup = chat.getChannelGroup(id: "my-channel-group")
    try await channelGroup.remove(channels: [supportChannel, generalChannel])
    debugPrint("Channels removed successfully")
  }
  // snippet.end
}

// MARK: - Remove Channel Identifiers

func removeChannelIdentifiersFromGroup() {
  // snippet.channelGroups.removeChannelIdentifiers
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let channelGroup = chat.getChannelGroup(id: "my-channel-group")
    try await channelGroup.removeChannelIdentifiers(["support-channel", "general-channel"])
    debugPrint("Channel identifiers removed successfully")
  }
  // snippet.end
}

// MARK: - Watch Channel Group (Connect)

func watchChannelGroupAsyncStream() {
  // snippet.channelGroups.connect.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let channelGroup = chat.getChannelGroup(id: "my-channel-group")
    
    for await message in channelGroup.connect() {
      debugPrint("Received message on channel \(message.channelId): \(message.text)")
    }
  }
  // snippet.end
}

func watchChannelGroupClosure() {
  // snippet.channelGroups.connect.closure
  // Assumes a "ChannelGroupImpl" reference named "channelGroup"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving messages manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = channelGroup.connect { message in
    debugPrint("Received message on channel \(message.channelId): \(message.text)")
  }
  // snippet.end
}

// MARK: - Get Present Users

func getPresentUsersInGroup() {
  // snippet.channelGroups.whoIsPresent
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let channelGroup = chat.getChannelGroup(id: "my-channel-group")
    let presenceByChannel = try await channelGroup.whoIsPresent()
    
    for (channelId, userIds) in presenceByChannel {
      debugPrint("Channel \(channelId) has users: \(userIds)")
    }
  }
  // snippet.end
}

// MARK: - Stream Presence

func streamPresenceAsyncStream() {
  // snippet.channelGroups.streamPresence.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let channelGroup = chat.getChannelGroup(id: "my-channel-group")
    
    for await presenceByChannel in channelGroup.streamPresence() {
      for (channelId, userIds) in presenceByChannel {
        debugPrint("Channel \(channelId) now has users: \(userIds)")
      }
    }
  }
  // snippet.end
}

func streamPresenceClosure() {
  // snippet.channelGroups.streamPresence.closure
  // Assumes a "ChannelGroupImpl" reference named "channelGroup"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving presence updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = channelGroup.streamPresence { presenceByChannel in
    for (channelId, userIds) in presenceByChannel {
      debugPrint("Channel \(channelId) now has users: \(userIds)")
    }
  }
  // snippet.end
}
