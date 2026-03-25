//
//  ChannelSnippets.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import PubNubSwiftChatSDK
import PubNubSDK

var chat: ChatImpl!
var channel: ChannelImpl!
var channels: [ChannelImpl]!
var membership: MembershipImpl!
var memberships: [MembershipImpl]!
var messageDraft: MessageDraftImpl!
var autoCloseable: AutoCloseable!
var page: PubNubHashedPage!
var message: MessageImpl!

// MARK: - Create Direct Channel

func createDirectConversation() {
  // snippet.channels.createDirect
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let agent007 = try await chat.getUser(userId: "agent-007") {
      let conversation = try await chat.createDirectConversation(invitedUser: agent007, channelCustom: ["purpose": "customer XYZ"])
      debugPrint("Direct conversation created with channel ID: \(conversation.channel.id)")
      debugPrint("Host membership: \(conversation.hostMembership)")
      debugPrint("Invitee membership: \(conversation.inviteeMembership)")
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

// MARK: - Create Group Channel

func createGroupConversation() {
  // snippet.channels.createGroup
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let agent007 = try await chat.getUser(userId: "agent-007")
    let agent008 = try await chat.getUser(userId: "agent-008")
    
    if let agent007, let agent008 {
      let conversation = try await chat.createGroupConversation(invitedUsers: [agent007, agent008], channelCustom: ["purpose": "customer XYZ"])
      debugPrint("Group conversation created with channel ID: \(conversation.channel.id)")
      debugPrint("Host membership: \(conversation.hostMembership)")
      debugPrint("Invitee memberships: \(conversation.inviteeMemberships)")
    } else {
      debugPrint("One or more users not found")
    }
  }
  // snippet.end
}

// MARK: - Create Public Channel

func createPublicConversation() {
  // snippet.channels.createPublic
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let publicChannel = try await chat.createPublicConversation(channelName: "ask-support")
    debugPrint("Public conversation created with channel ID: \(publicChannel.id)")
    debugPrint("Channel custom fields: \(String(describing: publicChannel.custom))")
  }
  // snippet.end
}

// MARK: - Delete Channel (Hard)

func deleteChannel() {
  // snippet.channels.delete
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      try await channel.delete()
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get Channel Details

func getChannel() {
  // snippet.channels.getChannel
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      debugPrint("Fetched channel metadata with ID: \(channel.id)")
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Join Channel

func joinChannel() {
  // snippet.channels.join
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let joinResult = try await channel.join(custom: ["support_plan": "premium"])
      debugPrint("Channel membership: \(joinResult.membership)")
      debugPrint("Membership channel ID: \(joinResult.membership.channel.id)")
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Join Channel and Listen (AsyncStream)

func joinChannelAsyncStream() {
  // snippet.channels.join.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      // Join the channel
      let joinResult = try await channel.join(custom: ["support_plan": "premium"])
      // Continuously fetch and process values from the stream
      for await message in joinResult.messagesStream {
        debugPrint("Received a new message: \(message)")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Join Channel and Listen (Closure)

func joinChannelClosure() {
  // snippet.channels.join.closure
  // Assumes a "ChannelImpl" reference named "channel"
  channel.join(custom: ["support_plan": "premium"]) { message in
    debugPrint("Received a new message: \(message)")
  } completion: { result in
    switch result {
    case let .success((_, disconnect)):
      // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
      // to receive new messages. If the "AutoCloseable" is deallocated, the stream will be cancelled,
      // and no further items will be produced. You can also stop receiving messages manually
      // by calling the "close()" method on the "AutoCloseable" object.
      autoCloseable = disconnect
    case let .failure(error):
      debugPrint("An error occurred: \(error)")
    }
  }
  // snippet.end
}

// MARK: - Leave Channel

func leaveChannel() {
  // snippet.channels.leave
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      try await channel.leave()
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Watch Channel (AsyncStream)

func watchChannelAsyncStream() {
  // snippet.channels.connect.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      for await message in channel.connect() {
        debugPrint("Received message: \(message)")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Watch Channel (Closure)

func watchChannelClosure() {
  // snippet.channels.connect.closure
  // Assumes a "ChannelImpl" reference named "channel"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving messages manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = channel.connect { message in
    debugPrint("Received message: \(message.content)")
  }
  // snippet.end
}

// MARK: - List All Channels

func getChannels() {
  // snippet.channels.getChannels
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    // Fetch the first set of channels.
    // There's no need to pass the "page" parameter, as it's nil by default, indicating the first page
    let getChannelsResult = try await chat.getChannels()
    debugPrint("Fetched channels: \(getChannelsResult.channels)")
    debugPrint("Next page: \(String(describing: getChannelsResult.page))")
    
    // The example below shows how to read the next page and pass it to a subsequent call.
    // You can recursively keep fetching using the page objects from previous responses until the returned array is empty
    if let nextPage = getChannelsResult.page, !getChannelsResult.channels.isEmpty {
      let resultsFromNextPage = try await chat.getChannels(page: nextPage)
    }
  }
  // snippet.end
}

// MARK: - List Channels with Pagination

func getChannelsPagination() {
  // snippet.channels.getChannels.pagination
  // Assumes a "ChatImpl" reference named "chat"
  // Assumes a "PubNubHashedPage" reference named "page"
  Task {
    let getChannelsResult = try await chat.getChannels(limit: 25, page: page)
    debugPrint("Fetched channels: \(getChannelsResult.channels)")
    debugPrint("Next page: \(String(describing: getChannelsResult.page))")
    
    // The example below shows how to read the next page and pass it to a subsequent call.
    // You can recursively keep fetching using the page objects from previous responses until the returned array is empty
    if let nextPage = getChannelsResult.page, !getChannelsResult.channels.isEmpty {
      let resultsFromNextPage = try await chat.getChannels(limit: 25, page: nextPage)
    }
  }
  // snippet.end
}

// MARK: - List Archived Channels

func getChannelsArchived() {
  // snippet.channels.getChannels.archived
  // Assumes a "ChatImpl" reference named "chat"
  // Assumes a "PubNubHashedPage" reference named "page"
  Task {
    let getChannelsResult = try await chat.getChannels(filter: "status == 'deleted'", limit: 25, page: page)
    debugPrint("Fetched channels: \(getChannelsResult.channels)")
    debugPrint("Next page: \(String(describing: getChannelsResult.page))")
    
    // The example below shows how to read the next page and pass it to a subsequent call.
    // You can recursively keep fetching using the page objects from previous responses until the returned array is empty
    if let nextPage = getChannelsResult.page, !getChannelsResult.channels.isEmpty {
      let resultsFromNextPage = try await chat.getChannels(page: nextPage)
    }
  }
  // snippet.end
}

// MARK: - Get Channel Members

func getMembers() {
  // snippet.channels.getMembers
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    // Fetch the metadata of the "support" channel
    if let channel = try await chat.getChannel(channelId: "support") {
      // Check if the channel's custom data includes the "premium" support plan
      if let customData = channel.custom, customData["supportPlan"]?.stringOptional == "premium" {
        // List all members of the "support" channel
        let members = try await channel.getMembers()
        debugPrint("Fetched members: \(members)")
        debugPrint("Next page (if any): \(String(describing: members.page))")
      } else {
        debugPrint("Channel not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get User Memberships

func getMemberships() {
  // snippet.channels.getMemberships
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      let memberships = try await user.getMemberships()
      let channelIds = memberships.memberships.map { $0.channel.id }
      debugPrint("User 'support_agent_15' is a member of channels: \(channelIds)")
      debugPrint("Next page (if any): \(String(describing: memberships.page))")
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Membership Updates (AsyncStream)

func streamMembershipUpdatesAsyncStream() {
  // snippet.membership.streamUpdates.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let membership = try await chat.currentUser.getMemberships(limit: 1).memberships.first {
      for await updatedMembership in membership.streamUpdates() {
        // The stream returns the entire updated Membership object each time a change occurs.
        if let updatedMembership {
          debugPrint("Received update for membership: \(updatedMembership)")
        } else {
          debugPrint("Membership was deleted")
        }
      }
    } else {
      debugPrint("Membership not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Membership Updates (Closure)

func streamMembershipUpdatesClosure() {
  // snippet.membership.streamUpdates.closure
  // Assumes a "MembershipImpl" reference named "membership"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive new updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = membership.streamUpdates { updatedMembership in
    // The closure receives the entire updated Membership object each time a change occurs.
    if let updatedMembership = updatedMembership {
      debugPrint("Received update for membership with ID: \(updatedMembership.user.id)")
    } else {
      debugPrint("Membership has been deleted")
    }
  }
  // snippet.end
}

// MARK: - Stream Multiple Memberships Updates (AsyncStream)

func streamMembershipsUpdatesOnAsyncStream() {
  // snippet.membership.streamUpdatesOn.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let getMembershipsRes = try await chat.currentUser.getMemberships(limit: 10)
    let memberships = getMembershipsRes.memberships
    
    for await updatedMemberships in MembershipImpl.streamUpdatesOn(memberships: memberships) {
      // The stream returns the complete list of all memberships you're monitoring
      // each time any change occurs.
      debugPrint("Received updates for memberships: \(updatedMemberships)")
    }
  }
  // snippet.end
}

// MARK: - Stream Multiple Memberships Updates (Closure)

func streamMembershipsUpdatesOnClosure() {
  // snippet.membership.streamUpdatesOn.closure
  // Assumes an array of "MembershipImpl" objects named "memberships"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive new updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = MembershipImpl.streamUpdatesOn(memberships: memberships) { updatedMemberships in
    // The closure receives the complete list of all memberships you're monitoring
    // each time any change occurs.
    for updatedMembership in updatedMemberships {
      debugPrint("Received update for membership with channel ID: \(updatedMembership.channel.id)")
    }
  }
  // snippet.end
}

// MARK: - Update Membership

func updateMembership() {
  // snippet.membership.update
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      if let membership = try await user.getMemberships(filter: "channel.id == 'high-priority-incidents'").memberships.first {
        let updatedMembership = try await membership.update(custom: ["role": "premium-support"])
        debugPrint("Updated membership: \(updatedMembership)")
      } else {
        debugPrint("No memberships found")
      }
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

// MARK: - Update Channel Details

func updateChannel() {
  // snippet.channels.update
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let updatedChannel = try await channel.update(name: "This is the updated description for the support channel")
      debugPrint("Updated channel: \(updatedChannel)")
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Channel Updates (AsyncStream)

func streamChannelUpdatesAsyncStream() {
  // snippet.channels.streamUpdates.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      for await updatedChannel in channel.streamUpdates() {
        // The stream returns the entire updated Channel object each time a change occurs.
        if let updatedChannel = updatedChannel {
          debugPrint("Updated channel: \(updatedChannel)")
        } else {
          debugPrint("Channel was deleted")
        }
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Channel Updates (Closure)

func streamChannelUpdatesClosure() {
  // snippet.channels.streamUpdates.closure
  // Assumes a "ChannelImpl" reference named "channel"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = channel.streamUpdates { updatedChannel in
    // The closure receives the entire updated Channel object each time a change occurs.
    if let updatedChannel = updatedChannel {
      debugPrint("Received update for channel with ID: \(updatedChannel.id)")
    } else {
      debugPrint("Channel was deleted")
    }
  }
  // snippet.end
}

// MARK: - Stream Multiple Channels Updates (AsyncStream)

func streamChannelsUpdatesOnAsyncStream() {
  // snippet.channels.streamUpdatesOn.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      for await updatedChannels in ChannelImpl.streamUpdatesOn(channels: [channel]) {
        // The stream returns the complete list of all channels you're monitoring
        // each time any change occurs.
        debugPrint("Updated channels: \(String(describing: updatedChannels))")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Multiple Channels Updates (Closure)

func streamChannelsUpdatesOnClosure() {
  // snippet.channels.streamUpdatesOn.closure
  // Assumes an array of "ChannelImpl" objects named "channels"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = ChannelImpl.streamUpdatesOn(channels: channels) { updatedChannels in
    // The closure receives the complete list of all channels you're monitoring
    // each time any change occurs.
    for updatedChannel in updatedChannels {
      debugPrint("Received update for channel with ID: \(updatedChannel.id)")
    }
  }
  // snippet.end
}

// MARK: - Add Channel Reference

func addChannelReference() {
  // snippet.channels.addReference
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "messages") {
      let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: true)
      messageDraft.update(text: "Hello Alex! I have sent you this link on the #offtopic channel.")
      messageDraft.addMention(offset: 45, length: 9, target: MentionTarget.channel(channelId: "group.offtopic"))
      try await messageDraft.send()
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Remove Channel Reference

func removeChannelReference() {
  // snippet.channels.removeReference
  // Assumes a "MessageDraftImpl" reference named "messageDraft"
  
  // Assume the message reads: "Hello Alex! I have sent you this link on the #offtopic channel."
  // Remove the channel reference
  messageDraft.removeMention(offset: 45)
  // snippet.end
}

// MARK: - Get Channel Suggestions

func getChannelSuggestions() {
  // snippet.channels.getSuggestions
  // Assumes a "ChannelImpl" reference named "channel"
  
  // Create a message draft
  let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel.type != .public)
  
  // Define the listener conforming to MessageDraftChangeListener protocol.
  // You can also use our ClosureMessageDraftChangeListener class to reduce the need for your custom types to implement the MessageDraftChangeListener protocol
  class DraftChangeListener: MessageDraftChangeListener {
    func onChange(messageElements: [MessageElement], suggestedMentions: any FutureObject<[SuggestedMention]>) {
      // Update UI with message elements. This is your own function for updating UI
      updateUI(with: messageElements)
      // Asynchronously process suggested mentions
      suggestedMentions.async { result in
        switch result {
        case .success(let mentions):
          // This is your own function for updating suggestions
          updateMentionList(with: mentions)
        case .failure(let error):
          print("Error retrieving suggestions: \(error)")
        }
      }
    }
  }
  
  // Instantiate the listener
  let listener = DraftChangeListener()
  // Add the listener to the message draft
  messageDraft.addChangeListener(listener)
  
  func updateUI(with: [MessageElement]) {}
  func updateMentionList(with: [SuggestedMention]) {}
  // snippet.end
}

// MARK: - Get Message Elements

func getMessageElements() {
  // snippet.channels.getMessageElements
  // Assumes a "MessageImpl" reference named "message"
  
  // Retrieve the message elements
  let messageElements = message.getMessageElements()
  
  // Check if any of the message elements reference a channel
  let containsChannelReference = messageElements.contains {
    switch $0 {
    case let .link(text, target):
      if case let .channel(channelId) = target {
        // Replace this with your condition for checking if the element is a channel reference
        // This is a placeholder condition
        return true
      } else {
        return false
      }
    default:
      return false
    }
  }
  
  if containsChannelReference {
    print("The message contains channel references.")
  } else {
    print("The message does not contain any channel references.")
  }
  // snippet.end
}

// MARK: - Get Referenced Channels (Deprecated)

func getReferencedChannels() {
  // snippet.channels.getReferencedChannels
  // Assumes a "ChannelImpl" reference named "channel"

  // Get the specific message using its timetoken
  Task {
    if let message = try await channel.getMessage(timetoken: 16200000000000000) {
      if let referencedChannels = message.referencedChannels, !referencedChannels.isEmpty {
        for referencedChannel in referencedChannels {
          debugPrint("Referenced channel name: \(referencedChannel.value.name)")
        }
      } else {
        debugPrint("Message does not contain any channel references.")
      }
    } else {
      debugPrint("Message not found")
    }
  }
  // snippet.end
}

// MARK: - Pin Message to Channel

func pinMessageToChannel() {
  // snippet.channels.pinMessage
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "incident-management") {
      if let message = try await channel.getHistory(count: 1).messages.first {
        let pinnedChannel = try await channel.pinMessage(message: message)
        debugPrint("A message was pinned to the channel: \(pinnedChannel)")
      } else {
        debugPrint("The channel history is empty. No message to pin.")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Check if User is Channel Member

func hasMember() {
  // snippet.channels.hasMember
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let isMember = try await channel.hasMember(userId: "support_agent_15")
      if isMember {
        debugPrint("User 'support_agent_15' is a member of the 'support' channel")
      } else {
        debugPrint("User 'support_agent_15' is not a member of the 'support' channel")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get Specific Channel Member

func getMember() {
  // snippet.channels.getMember
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let membership = try await channel.getMember(userId: "support_agent_15") {
        debugPrint("Found membership for user: \(membership.user.id)")
        debugPrint("Membership custom data: \(String(describing: membership.custom))")
      } else {
        debugPrint("User 'support_agent_15' is not a member of the 'support' channel")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}
