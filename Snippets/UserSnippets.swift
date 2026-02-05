//
//  UserSnippets.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import PubNubSDK
import PubNubSwiftChatSDK

var chat: ChatImpl!
var channel: ChannelImpl!
var user: UserImpl!
var message: MessageImpl!
var messageDraft: MessageDraftImpl!
var autoCloseable: AutoCloseable!

// MARK: - Create User

func createUser() {
  // snippet.users.create
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let customAttributes: [String: JSONCodableScalar] = [
      "title": "Support Agent",
      "linkedin": "https://www.linkedin.com/in/support_agent_15"
    ]
    let user = try await chat.createUser(
      id: "support_agent_15",
      name: "John Doe",
      externalId: nil,
      profileUrl: nil,
      email: nil,
      custom: customAttributes,
      status: nil,
      type: nil
    )
  }
  // snippet.end
}

// MARK: - Get User Details

func getUser() {
  // snippet.users.getUser
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      debugPrint("Fetched user metadata with ID: \(user.id)")
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

func getCurrentUser() {
  // snippet.users.getCurrentUser
  // Assumes a "ChatImpl" reference named "chat"
  // Access the "currentUser" property to get details of the current chat user
  let currentUser = chat.currentUser
  // snippet.end
}

// MARK: - List Users

func getUsers() {
  // snippet.users.getUsers
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    // Fetch the first set of users.
    // There's no need to pass the "page" parameter, as it's nil by default, indicating the first page
    let getUsersResult = try await chat.getUsers()
    debugPrint("Fetched channels: \(getUsersResult.users)")
    debugPrint("Next page: \(String(describing: getUsersResult.page))")
    
    // The example below shows how to read the next page from the previous response and pass it to a subsequent call.
    // You can recursively keep fetching using the page objects from previous responses until the returned array is empty
    if let nextPage = getUsersResult.page, !getUsersResult.users.isEmpty {
      let resultsFromNextPage = try await chat.getUsers(page: nextPage)
    }
  }
  // snippet.end
}

func getUsersWithPagination() {
  // snippet.users.getUsers.pagination
  // Assumes a "ChatImpl" reference named "chat" and the "page" reference of "PubNubHashedPage" type
  Task {
    let getUsersResult = try await chat.getUsers(limit: 25, page: page)
    debugPrint("Fetched channels: \(getUsersResult.users)")
    debugPrint("Next page: \(String(describing: getUsersResult.page))")
    
    // The example below shows how to read the next page and pass it to a subsequent call.
    // You can recursively keep fetching using the page objects from previous responses until the returned array is empty
    if let nextPage = getUsersResult.page, !getUsersResult.users.isEmpty {
      let resultsFromNextPage = try await chat.getUsers(limit: 25, page: nextPage)
    }
  }
  // snippet.end
}

func getArchivedUsers() {
  // snippet.users.getUsers.archived
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    // Fetch the first set of users.
    // There's no need to pass the "page" parameter, as it's nil by default, indicating the first page
    let getUsersResult = try await chat.getUsers(filter: "status == 'deleted'", limit: 25)
    debugPrint("Fetched channels: \(getUsersResult.users)")
    debugPrint("Next page: \(String(describing: getUsersResult.page))")
    
    // The example below shows how to read the next page and pass it to a subsequent call.
    // You can recursively keep fetching using the page objects from previous responses until the returned array is empty
    if let nextPage = getUsersResult.page, !getUsersResult.users.isEmpty {
      let resultsFromNextPage = try await chat.getUsers(filter: "status == 'deleted'", limit: 25, page: nextPage)
    }
  }
  // snippet.end
}

// MARK: - Update User

func updateUser() {
  // snippet.users.update
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      let updatedUser = try await user.update(profileUrl: "https://www.linkedin.com/mkelly_vp2")
      debugPrint("User profile updated on User object: \(updatedUser)")
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

func updateUserOnChat() {
  // snippet.users.updateUser
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let updatedUser = try await chat.updateUser(
      id: "support_agent_15",
      profileUrl: "https://www.linkedin.com/mkelly_vp2"
    )
    debugPrint("Updated user object: \(updatedUser)")
  }
  // snippet.end
}

// MARK: - Delete User

func deleteUser() {
  // snippet.users.delete
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      try await user.delete(soft: false)
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

func deleteUserOnChat() {
  // snippet.users.deleteUser
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    try await chat.deleteUser(id: "support_agent_15")
  }
  // snippet.end
}

func softDeleteUser() {
  // snippet.users.delete.soft
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      let updatedUser = try await user.delete(soft: true)
      debugPrint("User marked as deleted")
      debugPrint("Updated user object: \(String(describing: updatedUser))")
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

func softDeleteUserOnChat() {
  // snippet.users.deleteUser.soft
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    try await chat.deleteUser(id: "support_agent_15", soft: true)
  }
  // snippet.end
}

// MARK: - Stream User Updates

func streamUserUpdatesAsyncStream() {
  // snippet.users.streamUpdates.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      for await updatedUser in user.streamUpdates() {
        // The stream returns the entire updated User object each time a change occurs.
        if let updatedUser = updatedUser {
          debugPrint("Updated user object: \(updatedUser)")
        } else {
          debugPrint("User was deleted")
        }
      }
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

func streamUserUpdatesClosure() {
  // snippet.users.streamUpdates.closure
  // Assumes a "UserImpl" reference named "support_agent_15" representing previously fetched user object with the `support_agent_15` identifier
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive new updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = support_agent_15.streamUpdates { updatedUser in
    // The closure receives the entire updated User object each time a change occurs.
    if let updatedUser = updatedUser {
      debugPrint("User updated: \(updatedUser)")
    } else {
      debugPrint("User was deleted")
    }
  }
  // snippet.end
}

func streamUpdatesOnUsersAsyncStream() {
  // snippet.users.streamUpdatesOn.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let firstUser = try await chat.getUser(userId: "support_agent_15"), let secondUser = try await chat.getUser(userId: "support_manager") {
      for await updatedUsers in UserImpl.streamUpdatesOn(users: [firstUser, secondUser]) {
        // The stream returns the complete list of all users you're monitoring
        // each time any change occurs.
        debugPrint("Updated users: \(String(describing: updatedUsers))")
      }
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

func streamUpdatesOnUsersClosure() {
  // snippet.users.streamUpdatesOn.closure
  // Assumes a "ChatImpl" reference named "chat"
  // Assumes "UserImpl" references named "support_agent_15" and "support_manager"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive new updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = UserImpl.streamUpdatesOn(users: [support_agent_15, support_manager]) { updatedUsers in
    // The closure receives the complete list of all users you're monitoring
    // each time any change occurs.
    debugPrint("Users updated: \(updatedUsers.map { $0.id })")
  }
  // snippet.end
}

// MARK: - Channel Presence

func wherePresent() {
  // snippet.users.wherePresent
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      let channels = try await user.wherePresent()
      debugPrint("User is present in the following channels: \(channels)")
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

func wherePresentOnChat() {
  // snippet.users.wherePresent.chat
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let channels = try await chat.wherePresent(userId: "support_agent_15")
    debugPrint("User \"support_agent_15\" is present in the following channels: \(channels)")
  }
  // snippet.end
}

func isPresentOn() {
  // snippet.users.isPresentOn
  // Assumes a "ChatImpl" reference named "chat"
  let userId = "support_agent_15"
  let channelId = "support_channel_123"
  Task {
    if let user = try await chat.getUser(userId: userId) {
      let isPresent = try await user.isPresentOn(channelId: channelId)
      debugPrint("User is present on the channel \(channelId): \(isPresent)")
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

func isPresentOnChannel() {
  // snippet.users.isPresent.channel
  // Assumes a "ChatImpl" reference named "chat"
  let userId = "support_agent_15"
  let channelId = "support_channel_123"
  Task {
    if let channel = try await chat.getChannel(channelId: channelId) {
      let isPresent = try await channel.isPresent(userId: userId)
      debugPrint("User \(userId) is present on the channel \(channelId): \(isPresent)")
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

func isPresentOnChat() {
  // snippet.users.isPresent.chat
  // Assumes a "ChatImpl" reference named "chat"
  let userId = "support_agent_15"
  let channelId = "support_channel_123"
  Task {
    let isPresent = try await chat.isPresent(userId: userId, channelId: channelId)
    debugPrint("User \(userId) is present on the channel \(channelId): \(isPresent)")
  }
  // snippet.end
}

func whoIsPresentOnChannel() {
  // snippet.users.whoIsPresent.channel
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support_channel_123") {
      let userIds = try await channel.whoIsPresent()
      debugPrint("Users present on the channel: \(userIds)")
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

func whoIsPresentOnChat() {
  // snippet.users.whoIsPresent.chat
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    let userIds = try await chat.whoIsPresent(channelId: "support_channel_123")
    debugPrint("Users present on the channel: \(userIds)")
  }
  // snippet.end
}

func streamPresence() {
  // snippet.users.streamPresence
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      for await userIds in channel.streamPresence() {
        debugPrint("Current users present on 'support' channel: \(userIds)")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Channel Membership

func isMemberOf() {
  // snippet.users.isMemberOf
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      let isMember = try await user.isMemberOf(channelId: "support")
      if isMember {
        debugPrint("User 'support_agent_15' is a member of the 'support' channel")
      } else {
        debugPrint("User 'support_agent_15' is not a member of the 'support' channel")
      }
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

func getMembership() {
  // snippet.users.getMembership
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      if let membership = try await user.getMembership(channelId: "support") {
        debugPrint("Found membership in channel: \(membership.channel.id)")
        debugPrint("Membership custom data: \(String(describing: membership.custom))")
      } else {
        debugPrint("User 'support_agent_15' is not a member of the 'support' channel")
      }
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

// MARK: - Global Presence

func checkUserActive() {
  // snippet.users.active
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      if user.active {
        debugPrint("User \(user.id) is currently active.")
      } else {
        debugPrint("User \(user.id) is currently not active.")
      }
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

func checkLastActiveTimestamp() {
  // snippet.users.lastActiveTimestamp
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      debugPrint("Fetched user metadata with ID: \(user.id)")
      debugPrint("Last active timestamp: \(user.lastActiveTimestamp)")
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

// MARK: - User Mentions

func addUserMention() {
  // snippet.users.mentions.add
  // Assumes a "ChannelImpl" reference named "channel"
  // Create a message draft.
  let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel.type != .public)
  // Update the text of the message draft
  messageDraft.update(text: "Hello Alex! I have sent you this link on the #offtopic channel.")
  // Add a user mention to the string "Alex"
  messageDraft.addMention(offset: 6, length: 4, target: MentionTarget.user(userId: "alex_d"))
  
  // Additional logic can be implemented as needed
  // For example, sending the draft or adding listeners
  // snippet.end
}

func removeUserMention() {
  // snippet.users.mentions.remove
  // Assumes a "MessageDraftImpl" reference named "messageDraft"
  // Assume the message reads: "Hello Alex! I have sent you this link on the #offtopic channel."
  // Remove the user reference
  messageDraft.removeMention(offset: 6)
  // snippet.end
}

func getUserMentionSuggestions() {
  // snippet.users.mentions.suggestions
  // Assumes a "ChannelImpl" reference named "channel"
  // Define the listener conforming to MessageDraftChangeListener protocol.
  // You can also use our ClosureMessageDraftChangeListener class to reduce the need for your custom types to implement the MessageDraftChangeListener protocol
  class UserMentionListener: MessageDraftChangeListener {
    func onChange(messageElements: [MessageElement], suggestedMentions: any FutureObject<[SuggestedMention]>) {
      // Update UI with message elements
      updateUI(with: messageElements) // updateUI is your own function for updating UI
      
      // Asynchronously process suggested user mentions
      suggestedMentions.async { result in
        switch result {
        case .success(let mentions):
          updateUserMentionList(with: mentions) // updateUserMentionList is your own function for updating user mention suggestions
        case .failure(let error):
          print("Error retrieving user mention suggestions: \(error)")
        }
      }
    }
  }
  
  // Create a message draft
  let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel.type != .public)
  // Instantiate the listener
  let listener = UserMentionListener()
  // Add the listener to the message draft
  messageDraft.addChangeListener(listener)
  // snippet.end
}

func getMentionedUsers() {
  // snippet.users.mentions.getMessageElements
  // Assumes a "MessageImpl" reference named "message"
  // Retrieve the message elements
  let messageElements = message.getMessageElements()
  
  // Check if any of the message elements are mentions
  let containsMentions = messageElements.contains {
    switch $0 {
    case let .link(text, target):
      if case let .user(userId) = target {
        return true
      } else {
        return false
      }
    default:
      return false
    }
  }
  
  if containsMentions {
    print("The message contains mentions.")
  } else {
    print("The message does not contain any mentions.")
  }
  // snippet.end
}

func getCurrentUserMentions() {
  // snippet.users.mentions.getCurrentUserMentions
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    // Fetch the first set of users.
    // Since no 'startTimetoken' parameter is provided, we fetch the items starting from the current time
    let response = try await chat.getCurrentUserMentions(count: 10)
    
    response.mentions.forEach { mentionData in
      debugPrint("Mention event: \(mentionData.userMentionData.event)")
      debugPrint("Mentioned user: \(mentionData.userMentionData.userId)")
    }
    
    // The code below demonstrates how to fetch the next set of historical mentions. Skip it if you're only
    // interested in the initial set.
    
    // Retrieves the timetoken of the oldest mention from the previous response
    let theOldestMentionTimetoken = response.mentions.compactMap { $0.userMentionData.message?.timetoken ?? nil }.min()
    
    // Fetch the next historical mentions by using the timetoken of the oldest mention from the previous response
    // as the 'startTimetoken:' parameter for the subsequent call. Continue fetching in this way to retrieve
    // all items until the resulting array is empty
    if let theOldestMentionTimetoken, response.isMore {
      let nextHistoryResults = try await chat.getCurrentUserMentions(startTimetoken: theOldestMentionTimetoken)
    }
  }
  // snippet.end
}

func listenForMentionEvents() {
  // snippet.users.mentions.listenForEvents
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      for await update in chat.listenForEvents(type: EventContent.Mention.self, channelId: "support_agent_15") {
        debugPrint("Mention payload: \(update.event.payload)")
      }
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

// MARK: - Client-Side Mute (Moderation as User)

func muteUserAsyncAwait() {
  // snippet.users.mute.asyncAwait
  let userToMute = "user_rks"
  Task {
    do {
      try await chat.mutedUsersManager.muteUser(userId: userToMute)
      print("User muted successfully")
    } catch {
      print("Failed to mute user: \(error)")
    }
  }
  // snippet.end
}

func muteUserClosure() {
  // snippet.users.mute.closure
  // Assumes a "ChatImpl" reference named "chat"
  let userToMute = "user_rks"
  chat.mutedUsersManager.muteUser(userId: userToMute) { result in
    switch result {
    case .success:
      print("User muted successfully")
    case .failure(let error):
      print("Failed to mute user: \(error)")
    }
  }
  // snippet.end
}

func unmuteUserAsyncAwait() {
  // snippet.users.unmute.asyncAwait
  let userToUnmute = "user_rks"
  Task {
    do {
      try await chat.mutedUsersManager.unmuteUser(userId: userToUnmute)
      print("User unmuted successfully")
    } catch {
      print("Failed to unmute user: \(error)")
    }
  }
  // snippet.end
}

func unmuteUserClosure() {
  // snippet.users.unmute.closure
  // Assumes a "ChatImpl" reference named "chat"
  let userToUnmute = "user_rks"
  chat.mutedUsersManager.unmuteUser(userId: userToUnmute) { result in
    switch result {
    case .success:
      print("User unmuted successfully")
    case .failure(let error):
      print("Failed to unmute user: \(error)")
    }
  }
  // snippet.end
}

func checkMutedUsers() {
  // snippet.users.mutedUsers
  // Assumes a "ChatImpl" reference named "chat"
  for userId in chat.mutedUsersManager.mutedUsers {
    print("Muted user: \(userId)")
  }
  // snippet.end
}

// MARK: - Helper Variables (for compilation)

var support_agent_15: UserImpl!
var support_manager: UserImpl!
var page: PubNubHashedPage!

// Helper functions referenced in snippets
func updateUI(with elements: [MessageElement]) {}
func updateUserMentionList(with mentions: [SuggestedMention]) {}
