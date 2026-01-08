//
//  InviteSnippets.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import PubNubSwiftChatSDK

var chat: ChatImpl!

// MARK: - Invite One User

func inviteOneUser() {
  // snippet.invite.inviteOne
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let supportAgent = try await chat.getUser(userId: "support-agent-15")
    let channel = try await chat.getChannel(channelId: "high-prio-incidents")
    
    if let supportAgent, let channel {
      let channelMembership = try await channel.invite(user: supportAgent)
      debugPrint("Updated membership: \(channelMembership)")
      debugPrint("Membership channel id: \(channelMembership.channel.id)")
    } else {
      debugPrint("User or channel not found")
    }
  }
  // snippet.end
}

// MARK: - Invite Multiple Users

func inviteMultipleUsers() {
  // snippet.invite.inviteMultiple
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let supportAgent15 = try await chat.getUser(userId: "support-agent-15")
    let supportAgent16 = try await chat.getUser(userId: "support-agent-16")
    let channel = try await chat.getChannel(channelId: "high-prio-incidents")
    
    if let supportAgent15, let supportAgent16, let channel {
      let channelMembership = try await channel.inviteMultiple(users: [supportAgent15, supportAgent16])
      debugPrint("Updated memberships: \(channelMembership)")
    } else {
      debugPrint("Channel or users not found")
    }
  }
  // snippet.end
}

// MARK: - Listen to Invite Events

func listenForInviteEvents() {
  // snippet.invite.listenForEvents
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    for await event in chat.listenForEvents(type: EventContent.Invite.self, channelId: "userId") {
      debugPrint("Received an invitation on channel ID: \(event.event.payload.channelId)")
      debugPrint("Channel type: \(event.event.payload.channelType)")
    }
  }
  // snippet.end
}
