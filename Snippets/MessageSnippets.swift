//
//  MessageSnippets.swift
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
var message: MessageImpl!
var messages: [MessageImpl]!
var membership: MembershipImpl!
var threadChannel: ThreadChannelImpl!
var anotherThreadChannel: ThreadChannelImpl!
var threadMessage: ThreadMessageImpl!
var threadChannels: [ThreadChannelImpl]!
var messageDraft: MessageDraftImpl!
var autoCloseable: AutoCloseable!

// MARK: - Send Text

func sendText() {
  // snippet.messages.sendText
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let timetoken = try await channel.sendText(
        text: "Hi Everyone",
        params: SendTextParams(
          meta: ["messageImportance": "high"],
          shouldStore: true,
          ttl: 15
        )
      )
      debugPrint("Message sent successfully at \(timetoken)")
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get Message Details

func getMessage() {
  // snippet.messages.getMessage
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let timetoken: Timetoken = 16200000000000001
      if let message = try await channel.getMessage(timetoken: timetoken) {
        debugPrint("Message fetched successfully: \(message.text)")
      } else {
        debugPrint("No message found with this timetoken.")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get Message Content

func getMessageContent() {
  // snippet.messages.getContent
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let timetoken: Timetoken = 16200000000000000
      if let message = try await channel.getMessage(timetoken: timetoken) {
        debugPrint("Message fetched successfully: \(message.text)")
      } else {
        debugPrint("No message found with this timetoken.")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Check Deletion Status

func checkDeletionStatus() {
  // snippet.messages.checkDeleted
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let timetoken: Timetoken = 16200000000000000
      if let message = try await channel.getMessage(timetoken: timetoken) {
        if message.deleted {
          debugPrint("The message was deleted.")
        } else {
          debugPrint("Message fetched successfully: \(message.text)")
        }
      } else {
        debugPrint("No message found with this timetoken.")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get History

func getHistory() {
  // snippet.messages.getHistory
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let response = try await channel.getHistory(startTimetoken: 15343325214676133, count: 10)
      debugPrint("Messages: \(response.messages)")
      debugPrint("Has more items to fetch: \(response.isMore)")
      
      let theOldestTimetoken = response.messages.compactMap { $0.timetoken }.min()
      
      if let theOldestTimetoken, response.isMore {
        let nextHistoryResults = try await channel.getHistory(startTimetoken: theOldestTimetoken, count: 10)
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Delete Message (Hard)

func deleteMessage() {
  // snippet.messages.delete
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getMessage(timetoken: 16200000000000001) {
        try await message.delete()
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Delete Message (Soft)

func deleteMessageSoft() {
  // snippet.messages.deleteSoft
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getMessage(timetoken: 16200000000000001) {
        try await message.delete(soft: true)
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Restore Message

func restoreMessage() {
  // snippet.messages.restore
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getMessage(timetoken: 16200000000000001) {
        let restoredMessage = try await message.restore()
        debugPrint("Message restored successfully: \(restoredMessage.text)")
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Edit Message

func editMessage() {
  // snippet.messages.edit
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let timetoken: Timetoken = 16200000000000000
      if let message = try await channel.getMessage(timetoken: timetoken) {
        let updatedMessage = try await message.editText(newText: "Your ticket number is 78398")
        debugPrint("Message updated successfully")
        debugPrint("Updated message: \(updatedMessage)")
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Message Updates (AsyncStream)

func streamMessageUpdatesAsyncStream() {
  // snippet.messages.streamUpdates.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  let timetoken: Timetoken = 16200000000000000
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getMessage(timetoken: timetoken) {
        for await updatedMessage in message.streamUpdates() {
          debugPrint("Received update for message with timetoken: \(updatedMessage.timetoken)")
        }
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Message Updates (Closure)

func streamMessageUpdatesClosure() {
  // snippet.messages.streamUpdates.closure
  // Assumes a "MessageImpl" reference named "message"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = message.streamUpdates { updatedMessage in
    debugPrint("Received update for message with timetoken: \(updatedMessage.timetoken)")
  }
  // snippet.end
}

// MARK: - Stream Multiple Messages Updates (AsyncStream)

func streamMessagesUpdatesOnAsyncStream() {
  // snippet.messages.streamUpdatesOn.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let messages = try await channel.getHistory().messages
      if !messages.isEmpty {
        for await updatedMessages in MessageImpl.streamUpdatesOn(messages: messages) {
          updatedMessages.forEach { updatedMessage in
            debugPrint("Message with timetoken \(updatedMessage.timetoken) updated")
          }
        }
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Multiple Messages Updates (Closure)

func streamMessagesUpdatesOnClosure() {
  // snippet.messages.streamUpdatesOn.closure
  // Assumes an array of "MessageImpl" objects named "messages"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive new updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = MessageImpl.streamUpdatesOn(messages: messages) { updatedMessages in
    debugPrint("Received updates for messages")
    for updatedMessage in updatedMessages {
      debugPrint("Message with timetoken \(updatedMessage.timetoken) updated")
    }
  }
  // snippet.end
}

// MARK: - Toggle Reaction

func toggleReaction() {
  // snippet.messages.toggleReaction
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getHistory(count: 1).messages.first {
        let updatedMessage = try await message.toggleReaction(reaction: "\u{1F44D}")
        debugPrint("Reaction added successfully to message: \(updatedMessage)")
      } else {
        debugPrint("No messages found in history")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get Reactions

func getReactions() {
  // snippet.messages.getReactions
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getHistory(count: 1).messages.first {
        debugPrint("Reactions for the latest message: \(message.reactions)")
      } else {
        debugPrint("No messages found in history")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Check User Reaction

func hasUserReaction() {
  // snippet.messages.hasUserReaction
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getHistory(count: 1).messages.first {
        if message.hasUserReaction(reaction: "\u{1F44D}") {
          print("The current user has added the 'thumb up' emoji to the latest message.")
        } else {
          print("The current user has not added the 'thumb up' emoji to the latest message.")
        }
      } else {
        debugPrint("No messages found in history")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Forward Message (on Message)

func forwardMessageOnMessage() {
  // snippet.messages.forward.onMessage
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getHistory(count: 1).messages.first {
        let timetoken = try await message.forward(channelId: "incident-management")
        debugPrint("Message forwarded successfully with timetoken: \(timetoken)")
      } else {
        debugPrint("No messages found in history")
      }
    } else {
      debugPrint("No channel found")
    }
  }
  // snippet.end
}

// MARK: - Forward Message (on Channel)

func forwardMessageOnChannel() {
  // snippet.messages.forward.onChannel
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getHistory(count: 1).messages.first {
        if let incidentChannel = try await chat.getChannel(channelId: "incident-management") {
          let timetoken = try await incidentChannel.forward(message: message)
          debugPrint("Message forwarded successfully with timetoken: \(timetoken)")
        }
      } else {
        debugPrint("No messages found in history")
      }
    }
  }
  // snippet.end
}

// MARK: - Quote Message

func quoteMessage() {
  // snippet.messages.quote
  // Assumes a "ChatImpl" reference named "chat"
  let timetoken: Timetoken = 16200000000000001
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getMessage(timetoken: timetoken) {
        // Create a message draft and set the quoted message
        let messageDraft = channel.createMessageDraft()
        messageDraft.update(text: "Quoting the message with timetoken \(timetoken)")
        messageDraft.quotedMessage = message
        try await messageDraft.send()
      } else {
        debugPrint("Message with the specified timetoken not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get Quoted Message

func getQuotedMessage() {
  // snippet.messages.getQuoted
  // Assumes a "ChatImpl" reference named "chat"
  let timetoken: Timetoken = 16200000000000001
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getMessage(timetoken: timetoken) {
        debugPrint("Quoted message: \(String(describing: message.quotedMessage))")
      } else {
        debugPrint("Message with the specified timetoken not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Pin Message

func pinMessage() {
  // snippet.messages.pin
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "incident-management") {
      if let message = try await channel.getHistory(count: 1).messages.first {
        let pinnedChannel = try await message.pin()
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

// MARK: - Get Pinned Message

func getPinnedMessage() {
  // snippet.messages.getPinned
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "incident-management") {
      if let message = try await channel.getPinnedMessage() {
        print("Pinned message content: \(message.content)")
      } else {
        debugPrint("No pinned message found in the channel.")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Unpin Message

func unpinMessage() {
  // snippet.messages.unpin
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "incident-management") {
      let updatedChannel = try await channel.unpinMessage()
      debugPrint("Updated channel object: \(updatedChannel)")
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Send Files

func sendFiles() {
  // snippet.messages.sendFiles
  // Assumes a "ChannelImpl" reference named "channel"
  Task {
    let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel.type != .public)
    messageDraft.update(text: "Here's some important documents:")
    
    let textFileStream = InputFile(
      name: "txtFileStream.txt",
      type: "text/plain",
      source: .stream(InputStream(fileAtPath: "filename.txt")!, contentType: "text/plain", contentLength: 14578)
    )
    let pdfFileStream = InputFile(
      name: "pdfFileStream.pdf",
      type: "application/pdf",
      source: .stream(InputStream(fileAtPath: "/path/to/document.pdf")!, contentType: "application/pdf", contentLength: 12578)
    )
    
    messageDraft.files.append(contentsOf: [textFileStream, pdfFileStream])
    try await messageDraft.send()
  }
  // snippet.end
}

// MARK: - Get Message Files

func getMessageFiles() {
  // snippet.messages.getMessageFiles
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getMessage(timetoken: 16200000000000000) {
        if !message.files.isEmpty {
          for file in message.files {
            debugPrint("File Name: \(file.name), File Type: \(String(describing: file.type)), File URL: \(file.url)")
          }
        } else {
          debugPrint("The message does not contain any files.")
        }
      } else {
        debugPrint("Message does not exist")
      }
    }
  }
  // snippet.end
}

// MARK: - Get Channel Files

func getChannelFiles() {
  // snippet.messages.getChannelFiles
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let getFilesResult = try await channel.getFiles()
      debugPrint("Fetched files: \(getFilesResult.files)")
      debugPrint("Next page: \(String(describing: getFilesResult.page))")
      
      if let nextPage = getFilesResult.page, !getFilesResult.files.isEmpty {
        let resultsFromNextPage = try await channel.getFiles(next: nextPage.next)
      }
    }
  }
  // snippet.end
}

// MARK: - Delete File

func deleteFile() {
  // snippet.messages.deleteFile
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      try await channel.deleteFile(
        id: "file-id-to-delete",
        name: "error-screenshot.png"
      )
    }
  }
  // snippet.end
}

// MARK: - Create Thread

func createThread() {
  // snippet.messages.createThread
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let timetoken: Timetoken = 16200000000000001
      if let message = try await channel.getMessage(timetoken: timetoken) {
        // Create a thread by sending the first reply
        let result = try await message.createThread(text: "Starting a thread on this topic")
        debugPrint("Thread created successfully with ID: \(result.threadChannel.id)")
        debugPrint("Parent channel ID: \(result.threadChannel.parentChannelId)")
        debugPrint("Updated parent message: \(result.parentMessage.hasThread)")
      } else {
        debugPrint("No message found with this timetoken")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Send Thread Message

func sendThreadMessage() {
  // snippet.messages.sendThreadMessage
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let timetoken: Timetoken = 16200000000000001
      if let message = try await channel.getMessage(timetoken: timetoken) {
        let threadChannel = try await message.getThread()
        let replyInThreadTimetoken = try await threadChannel.sendText(text: "Good job, guys!")
        debugPrint("Reply in a thread successfuly sent at \(replyInThreadTimetoken)")
      } else {
        debugPrint("No message found with this timetoken")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get Thread

func getThread() {
  // snippet.messages.getThread
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let timetoken: Timetoken = 16200000000000001
      if let message = try await channel.getMessage(timetoken: timetoken) {
        let threadChannel = try await message.getThread()
        debugPrint("Thread channel ID: \(threadChannel.id)")
        debugPrint("Parent channel ID: \(threadChannel.parentChannelId)")
      } else {
        debugPrint("No message found with this timetoken")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Check Has Thread

func hasThread() {
  // snippet.messages.hasThread
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let timetoken: Timetoken = 16200000000000001
      if let message = try await channel.getMessage(timetoken: timetoken) {
        debugPrint("Message fetched successfully: \(message.text)")
        debugPrint("Does this message have a thread: \(message.hasThread)")
      } else {
        debugPrint("No message found with this timetoken")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Remove Thread

func removeThread() {
  // snippet.messages.removeThread
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getHistory(count: 1).messages.first {
        let updatedChannel = try await message.removeThread()
        debugPrint("Thread removed successfully.")
        debugPrint("Updated Channel: \(String(describing: updatedChannel))")
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get Thread History

func getThreadHistory() {
  // snippet.messages.getThreadHistory
  // Assumes a "ThreadChannelImpl" reference named "threadChannel"
  Task {
    let response = try await threadChannel.getHistory(
      startTimetoken: 15343325214676133,
      count: 10
    )
    response.messages.forEach { message in
      debugPrint("Thread message: \(message.channelId) - \(message.text)")
    }
    
    let theOldestTimetoken = response.messages.compactMap { $0.timetoken }.min()
    
    if let theOldestTimetoken, !response.messages.isEmpty && response.isMore {
      let nextHistoryResults = try await threadChannel.getHistory(startTimetoken: theOldestTimetoken, count: 10)
    }
  }
  // snippet.end
}

// MARK: - Get Last Read Message

func getLastReadMessage() {
  // snippet.messages.getLastRead
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      if let membership = try await user.getMemberships(filter: "channel.id == 'support'").memberships.first {
        debugPrint("Last read message timetoken: \(String(describing: membership.lastReadMessageTimetoken))")
      } else {
        debugPrint("No memberships found for the \"support\" channel")
      }
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

// MARK: - Get Unread Messages Count (One Channel)

func getUnreadMessagesCountOneChannel() {
  // snippet.messages.getUnreadCount
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      if let membership = try await user.getMemberships(filter: "channel.id == 'support'").memberships.first {
        if let noOfUnreadMessages = try await membership.getUnreadMessagesCount() {
          print("Unread messages count: \(noOfUnreadMessages)")
        } else {
          print("No unread messages count available")
        }
      } else {
        debugPrint("No memberships found for the \"support\" channel")
      }
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

// MARK: - Fetch Unread Messages Count (All Channels)

func fetchUnreadMessagesCounts() {
  // snippet.messages.fetchUnreadCounts
  // Assumes a "ChatImpl" reference named "chat"
  chat.fetchUnreadMessagesCounts { result in
    switch result {
    case let .success(response):
      let countsByChannel = response.countsByChannel
      
      countsByChannel.forEach { unreadCount in
        print("Channel: \(unreadCount.channel.id)")
        print("Unread messages count: \(unreadCount.count)")
      }
      
      let page = response.page
      
    case let .failure(error):
      print("Error fetching unread message counts: \(error)")
    }
  }
  // snippet.end
}

// MARK: - Set Last Read Message

func setLastReadMessage() {
  // snippet.messages.setLastReadMessage
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      if let membership = try await user.getMemberships(filter: "channel.id == 'support'").memberships.first {
        if let message = try await membership.channel.getMessage(timetoken: 16200000000000001) {
          let updatedMembership = try await membership.setLastReadMessage(message: message)
          debugPrint("Successfully set the last read message")
          debugPrint("Updated membership object: \(updatedMembership)")
        } else {
          debugPrint("Message not found")
        }
      }
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

// MARK: - Set Last Read Message Timetoken

func setLastReadMessageTimetoken() {
  // snippet.messages.setLastReadTimetoken
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let user = try await chat.getUser(userId: "support_agent_15") {
      if let membership = try await user.getMemberships(filter: "channel.id == 'support'").memberships.first {
        let updatedMembership = try await membership.setLastReadMessageTimetoken(16200000000000001)
        debugPrint("Successfully set the last read message timetoken")
        debugPrint("Updated membership object: \(updatedMembership)")
      }
    } else {
      debugPrint("User not found")
    }
  }
  // snippet.end
}

// MARK: - Mark All Messages As Read

func markAllMessagesAsRead() {
  // snippet.messages.markAllAsRead
  // Assumes a "ChatImpl" reference named "chat"
  let nextPageString = "your_next_page_string"
  
  Task {
    let response = try await chat.markAllMessagesAsRead(
      limit: 50,
      page: PubNubHashedPageBase(start: nextPageString)
    )
    response.memberships.forEach { membership in
      debugPrint("Channel: \(membership.channel.id) marked as read.")
    }
    debugPrint(String(describing: response.page))
  }
  // snippet.end
}

// MARK: - Create Message Draft

func createMessageDraft() {
  // snippet.messages.createDraft
  // Assumes a "ChannelImpl" reference named "channel"
  let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel.type != .public)
  // snippet.end
}

// MARK: - Create Thread Message Draft

func createThreadMessageDraft() {
  // snippet.messages.createThreadMessageDraft
  // Assuming you have a reference of type "MessageImpl" named "message"
  let threadDraft = message.createThreadMessageDraft(
      isTypingIndicatorTriggered: true
  )

  threadDraft.update(text: "This is my thread reply draft")

  let timetoken = try await threadDraft.send()
  // snippet.end
}

// MARK: - Add Message Draft Change Listener

func addMessageDraftChangeListener() {
  // snippet.messages.addDraftChangeListener
  // Assumes a "ChannelImpl" reference named "channel"
  let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel.type != .public)
  let listener = ClosureMessageDraftChangeListener { elements, suggestedMentions in
    // updateUI(with:) is your own function for updating UI
    updateUI(with: elements)
    
    suggestedMentions.async { result in
      switch result {
      case .success(let mentions):
        // updateSuggestions(with:) is your own function for displaying suggestions
        updateSuggestions(with: mentions)
      case .failure(let error):
        print("Error retrieving suggestions: \(error)")
      }
    }
  }
  
  messageDraft.addChangeListener(listener)
  
  func updateUI(with elements: [MessageElement]) {}
  func updateSuggestions(with: [SuggestedMention]) {}
  // snippet.end
}

// MARK: - Remove Message Draft Change Listener

func removeMessageDraftChangeListener() {
  // snippet.messages.removeDraftChangeListener
  // Create a message draft.
  // Assuming you have a reference of type "ChannelImpl" named "channel"
  let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel.type != .public)
  // Define the listener
  let listener = ClosureMessageDraftChangeListener() { elements, suggestedMentions in
    // updateUI(with:) is your own function for updating UI
    updateUI(with: elements)

    suggestedMentions.async { result in
      switch result {
      case .success(let mentions):
        // updateSuggestions(with:) is your own function for displaying suggestions
        updateSuggestions(with: mentions)
      case .failure(let error):
        print("Error retrieving suggestions: \(error)")
      }
    }
  }

  // Add the listener to the message draft
  messageDraft.addChangeListener(listener)
  // Remove the listener from the message draft
  messageDraft.removeChangeListener(listener)

  func updateUI(with elements: [MessageElement]) {}
  func updateSuggestions(with: [SuggestedMention]) {}
  // snippet.end
}

// MARK: - Add Mention

func addMention() {
  // snippet.messages.addMention
  // Assumes a "ChannelImpl" reference named "channel"
  let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel.type != .public)
  messageDraft.update(text: "Hello Alex!")
  messageDraft.addMention(offset: 6, length: 4, target: .user(userId: "alex_d"))
  messageDraft.update(text: "Hello Alex! I have sent you this link on the #offtopic channel.")
  messageDraft.addMention(offset: 33, length: 4, target: .url(url: "www.pubnub.com"))
  messageDraft.addMention(offset: 45, length: 9, target: .channel(channelId: "group.offtopic"))
  // snippet.end
}

// MARK: - Remove Mention

func removeMention() {
  // snippet.messages.removeMention
  // Assumes a "MessageDraftImpl" reference named "messageDraft"
  
  // Assume the message reads: "Hello Alex! I have sent you this link on the #offtopic channel."
  // Remove the link mention
  messageDraft.removeMention(offset: 33)
  // snippet.end
}

// MARK: - Insert Suggested Mention

func insertSuggestedMention() {
  // snippet.messages.insertSuggestedMention
  // Create a message draft.
  // Assuming you have a reference of type "ChannelImpl" named "channel"
  let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel?.type != .public)
  // Create the listener
  let listener = ClosureMessageDraftChangeListener() { elements, suggestedMentions in
    // updateUI() is your own function for updating the UI:
    updateUI(elements)
    suggestedMentions.async { result in
      switch result {
      case .success(let mentions):
        // updateSuggestions() is your own function for displaying suggestions
        updateSuggestions(mentions)
      case .failure(let error):
        print("Error retrieving suggestions: \(error)")
      }
    }
  }

  messageDraft.addChangeListener(listener)

  // Assuming that getSelectedSuggestion() is your own function that returns a suggestion selected by the user.
  // When the user selects a suggestion in the UI:
  if let suggestion = getSelectedSuggestion() {
      messageDraft.insertSuggestedMention(mention: suggestion, text: suggestion.replaceWith)
  }

  func updateUI(_ elements: [MessageElement]) {}
  func updateSuggestions(_ mentions: [SuggestedMention]) {}
  func getSelectedSuggestion() -> SuggestedMention? { nil }
  // snippet.end
}

// MARK: - Update Message Draft Text

func updateMessageDraftText() {
  // snippet.messages.updateDraftText
  // Assumes a "MessageDraftImpl" reference named "messageDraft"
  
  // The message reads: "I sent [Alex] this picture."
  // Where [Alex] is a user mention
  messageDraft.update(text: "I did not send Alex this picture.")
  // The message now reads: "I did not send [Alex] this picture."
  // The mention is preserved because its text wasn't changed
  // snippet.end
}

// MARK: - Insert Message Draft Text

func insertMessageDraftText() {
  // snippet.messages.insertText
  // Assumes a "MessageDraftImpl" reference named "messageDraft"
  
  // The message reads: "Check this support article https://www.support-article.com/."
  messageDraft.insertText(offset: 6, text: "out ")
  // The message now reads: "Check out this support article https://www.support-article.com/"
  // snippet.end
}

// MARK: - Remove Message Draft Text

func removeMessageDraftText() {
  // snippet.messages.removeText
  // Assumes a "MessageDraftImpl" reference named "messageDraft"
  
  // The message reads: "Check out this support article https://www.support-article.com/."
  messageDraft.removeText(offset: 5, length: 4)
  // The message now reads: "Check this support article https://www.support-article.com/."
  // snippet.end
}

// MARK: - Send Message Draft

func sendMessageDraft() {
  // snippet.messages.sendDraft
  // Assumes a "ChannelImpl" reference named "channel"
  Task {
    let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel.type != .public)
    messageDraft.update(text: "Hello!")
    try await messageDraft.send()
  }
  // snippet.end
}

// MARK: - Add Link

func addLink() {
  // snippet.messages.links.add
  // Assumes a "ChannelImpl" reference named "channel"
  // Create a message draft.
  let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel.type != .public)
  // Update the text of the message draft
  messageDraft.update(text: "Hello Alex! I have sent you this link on the #offtopic channel.")
  // Add a URL mention to the word "link"
  messageDraft.addMention(offset: 33, length: 4, target: MentionTarget.url(url: "https://example.com"))

  // Additional logic can be implemented as needed
  // For example, sending the draft or adding listeners
  // snippet.end
}

// MARK: - Remove Link

func removeLink() {
  // snippet.messages.links.remove
  // Assumes a "MessageDraftImpl" reference named "messageDraft"

  // Assume the message reads: "Hello Alex! I have sent you this link on the #offtopic channel."
  // Remove the link mention
  messageDraft.removeMention(offset: 33)
  // snippet.end
}

// MARK: - Get Link Suggestions

func getLinkSuggestions() {
  // snippet.messages.links.suggestions
  // Define the listener conforming to MessageDraftChangeListener protocol.
  // You can also use our ClosureMessageDraftChangeListener class to reduce the need for your custom types to implement the MessageDraftChangeListener protocol
  class LinkSuggestionListener: MessageDraftChangeListener {
    func onChange(messageElements: [MessageElement], suggestedMentions: any FutureObject<[SuggestedMention]>) {
      // Update UI with message elements
      // This function is your own function for updating UI
      updateUI(with: messageElements)
      // Asynchronously process suggested URL mentions
      suggestedMentions.async { result in
        switch result {
        case .success(let mentions):
          // This is your own function for updating URL suggestions
          updateLinkSuggestions(with: mentions)
        case .failure(let error):
          print("Error retrieving URL suggestions: \(error)")
        }
      }
    }
  }

  // Create a message draft.
  // Assumes a "ChannelImpl" reference named "channel"
  let messageDraft = channel.createMessageDraft(isTypingIndicatorTriggered: channel.type != .public)
  // Instantiate the listener
  let listener = LinkSuggestionListener()
  // Add the listener to the message draft
  messageDraft.addChangeListener(listener)

  func updateUI(with: [MessageElement]) {}
  func updateLinkSuggestions(with: [SuggestedMention]) {}
  // snippet.end
}

// MARK: - Get Text Links

func getTextLinks() {
  // snippet.messages.links.get
  // Assumes a "MessageImpl" reference named "message"
  // Retrieve the message elements
  let messageElements = message.getMessageElements()

  // Filter the message elements to get only text links
  let textLinks = messageElements.compactMap {
    switch $0 {
    case let .link(text, target):
      if case let .url(url) = target {
        return URL(string: url)
      } else {
        return nil
      }
    default:
      return nil
    }
  }

  // Print the text links found, if any
  if !textLinks.isEmpty {
    print("The message contains the following text links:")
    textLinks.forEach { link in
      print(link.absoluteString)
    }
  } else {
    print("The message does not contain any text links.")
  }
  // snippet.end
}

// MARK: - Get Text Links (Deprecated)

func getTextLinksDeprecated() {
  // snippet.messages.links.getDeprecated
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "your-channel") {
      if let message = try await channel.getMessage(timetoken: 16200000000000000) {
        if let textLinks = message.textLinks, !textLinks.isEmpty {
          for textLink in textLinks {
            debugPrint("Link: \(textLink.link), Start Index: \(textLink.startIndex), End Index: \(textLink.endIndex)")
          }
        } else {
          debugPrint("The message does not contain any text links.")
        }
      } else {
        debugPrint("Message does not exist")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Thread Message Updates (AsyncStream)

func streamThreadMessageUpdatesOnAsyncStream() {
  // snippet.messages.threadMessage.streamUpdatesOn.asyncStream
  // Assumes a "ThreadChannelImpl" reference named "threadChannel"
  Task {
    if let threadMessage = try await threadChannel.getHistory(count: 1).messages.first {
      for await receivedThreadMessages in ThreadMessageImpl.streamUpdatesOn(messages: [threadMessage]) {
        // The stream returns the complete list of all thread messages you're monitoring
        // (including all reactions) each time any change occurs.
        debugPrint("Received elements: \(receivedThreadMessages)")
      }
    } else {
      debugPrint("Message not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Thread Message Updates (Closure)

func streamThreadMessageUpdatesOnClosure() {
  // snippet.messages.threadMessage.streamUpdatesOn.closure
  // Assumes a "ThreadMessageImpl" reference named "threadMessage"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = ThreadMessageImpl.streamUpdatesOn(messages: [threadMessage]) { updatedThreadMessages in
    // The closure receives the complete list of all thread messages you're monitoring
    // (including all reactions) each time any change occurs.
    updatedThreadMessages.forEach { updatedThreadMessage in
      debugPrint("-=Updated thread message: \(updatedThreadMessage)")
    }
  }
  // snippet.end
}

// MARK: - Stream Thread Channel Updates (AsyncStream)

func streamThreadChannelUpdatesOnAsyncStream() {
  // snippet.messages.threadChannel.streamUpdatesOn.asyncStream
  // Assumes two "ThreadChannelImpl" references named "threadChannel" and "anotherThreadChannel"
  Task {
    for await updatedThreadChannels in ThreadChannelImpl.streamUpdatesOn(channels: [threadChannel, anotherThreadChannel]) {
      // The stream returns the complete list of all thread channels you're monitoring
      // each time any change occurs.
      debugPrint("Updated thread channels: \(updatedThreadChannels)")
    }
  }
  // snippet.end
}

// MARK: - Stream Thread Channel Updates (Closure)

func streamThreadChannelUpdatesOnClosure() {
  // snippet.messages.threadChannel.streamUpdatesOn.closure
  // Assumes an array of "ThreadChannelImpl" objects named "threadChannels"
  
  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive new updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = ThreadChannelImpl.streamUpdatesOn(channels: threadChannels) { updatedThreadChannels in
    // The closure receives the complete list of all thread channels you're monitoring
    // each time any change occurs.
    updatedThreadChannels.forEach { updatedThreadChannel in
      debugPrint("Updated thread channel: \(updatedThreadChannel)")
    }
  }
  // snippet.end
}

// MARK: - Pin Message to Thread Channel

func pinMessageToThreadChannel() {
  // snippet.messages.pinToThreadChannel
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      // Get the last message on the channel, which is the root message for the thread
      if let message = try await channel.getHistory(count: 1).messages.first {
        // Get the thread channel
        let threadChannel = try await message.getThread()
        // Get the last message on the thread channel
        if let threadMessage = try await threadChannel.getHistory(count: 1).messages.first {
          // Pin the message from the thread to the thread channel
          let updatedChannel = try await threadChannel.pinMessage(message: threadMessage)
          // Prints the updated channel object
          debugPrint("Updated channel object: \(updatedChannel)")
        } else {
          debugPrint("No messages found in the thread channel.")
        }
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Pin Thread Message to Parent Channel

func pinThreadMessageToParentChannel() {
  // snippet.messages.pinThreadMessageToParentChannel
  // Assuming you have a reference of type "ChatImpl" named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      // Get the last message on the channel, which is the root message for the thread
      if let message = try await channel.getHistory(count: 1).messages.first {
        // Get the thread channel
        let threadChannel = try await message.getThread()
        // Get the last message on the thread channel
        if let threadMessage = try await threadChannel.getHistory(count: 1).messages.first {
          // Pin the message to the parent channel
          let updatedChannel = try await threadMessage.pinToParentChannel()
          debugPrint("Message pinned successfully to the parent channel")
          debugPrint("Updated channel object: \(updatedChannel)")
        } else {
          debugPrint("No messages found in the thread channel")
        }
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Pin Message to Parent Channel via ThreadChannel

func pinMessageToParentChannel() {
  // snippet.messages.pinMessageToParentChannel
  // Assuming you have a reference of type "ChatImpl" named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      // Get the last message on the channel, which is the root message for the thread
      if let message = try await channel.getHistory(count: 1).messages.first {
        // Get the thread channel
        let threadChannel = try await message.getThread()
        // Get the last message on the thread channel
        if let threadMessage = try await threadChannel.getHistory(count: 1).messages.first {
          // Pin the message to the parent channel
          let updatedChannel = try await threadChannel.pinMessageToParentChannel(message: threadMessage)
          debugPrint("Message pinned successfully to the parent channel")
          debugPrint("Updated channel object: \(updatedChannel)")
        } else {
          debugPrint("No messages found in the thread channel")
        }
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Unpin Thread Message from Parent Channel

func unpinThreadMessageFromParentChannel() {
  // snippet.messages.unpinThreadMessageFromParentChannel
  // Assuming you have a reference of type "ChatImpl" named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      // Get the last message on the channel, which is the root message for the thread
      if let message = try await channel.getHistory(count: 1).messages.first {
        // Get the thread channel
        let threadChannel = try await message.getThread()
        // Get the last message on the thread channel
        if let threadMessage = try await threadChannel.getHistory(count: 1).messages.first {
          let updatedChannel = try await threadMessage.unpinFromParentChannel()
          debugPrint("Message unpinned successfully from the parent channel")
          debugPrint("Updated channel object: \(updatedChannel)")
        } else {
          debugPrint("No messages found in the thread channel")
        }
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Unpin Message from Parent Channel via ThreadChannel

func unpinMessageFromParentChannel() {
  // snippet.messages.unpinMessageFromParentChannel
  // Assuming you have a reference of type "ChatImpl" named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      // Get the last message on the channel, which is the root message for the thread
      if let message = try await channel.getHistory(count: 1).messages.first {
        // Get the thread channel
        let threadChannel = try await message.getThread()
        // Get the last message on the thread channel
        if let threadMessage = try await threadChannel.getHistory(count: 1).messages.first {
          let updatedChannel = try await threadChannel.unpinMessageFromParentChannel()
          debugPrint("Message unpinned successfully from the parent channel")
          debugPrint("Updated channel object: \(updatedChannel)")
        } else {
          debugPrint("No messages found in the thread channel")
        }
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Unpin Thread Message from Thread Channel

func unpinThreadMessageFromThreadChannel() {
  // snippet.messages.unpinThreadMessageFromThreadChannel
  // Assuming you have a reference of type "ChatImpl" named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      // Get the last message on the channel, which is the root message for the thread
      if let message = try await channel.getHistory(count: 1).messages.first {
        // Get the thread channel
        let threadChannel = try await message.getThread()
        // Get the last message on the thread channel
        if let threadMessage = try await threadChannel.getHistory(count: 1).messages.first {
          let updatedChannel = try await threadChannel.unpinMessage()
          debugPrint("Message unpinned successfully from the thread channel")
          debugPrint("Updated channel object: \(updatedChannel)")
        } else {
          debugPrint("No messages found in the thread channel.")
        }
      } else {
        debugPrint("Message not found")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get Unread Messages Count (Deprecated)

func getUnreadMessagesCountDeprecated() {
  // snippet.messages.getUnreadCountDeprecated
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    // Returns info on all messages you didn't read on all joined channels
    let unreadMessagesResult = try await chat.getUnreadMessagesCount()
    // Iterate over an array of `GetUnreadMessagesCount`, printing details about each channel
    // and its number of unread messages
    unreadMessagesResult.forEach { unreadCount in
      debugPrint("Channel: \(unreadCount.channel.id)")
      debugPrint("Unread messages count: \(unreadCount.count)")
    }
  }
  // snippet.end
}

// MARK: - Report Message

func reportMessage() {
  // snippet.messages.report
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      if let message = try await channel.getHistory(count: 1).messages.first {
        let timetoken = try await message.report(reason: "Offensive Content")
        debugPrint("Reported message successfully: \(timetoken)")
      } else {
        debugPrint("No messages found in the \"support\" channel")
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Get Message Reports History

func getMessageReportsHistory() {
  // snippet.messages.getReportsHistory
  // Define timetokens for the message history period
  let startTimetoken: Timetoken = 1725100800000 // July 1, 2024, 00:00:00 UTC
  let endTimetoken: Timetoken = 1726780799000 // July 21, 2024, 23:59:59 UTC

  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let historyResponse = try await channel.getMessageReportsHistory(
        startTimetoken: startTimetoken,
        endTimetoken: endTimetoken,
        count: 25
      )
      historyResponse.events.forEach { eventWrapper in
        print("Payload: \(eventWrapper.event.payload)")
      }
    }
  }
  // snippet.end
}

// MARK: - Stream Message Reports

func streamMessageReports() {
  // snippet.messages.streamReports
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      for await event in channel.streamMessageReports() {
        // Access the report details from the event's payload
        let reportPayload = event.event.payload
        let reportReason = reportPayload.reason
        // Print the notification
        if reportReason.lowercased() == "offensive" {
          print("Notification: An offensive message was reported on the 'support' channel by user \(event.event.userId). Reason: \(reportReason)")
        }
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Read Receipts (AsyncStream)

func streamReadReceiptsAsyncStream() {
  // snippet.messages.readReceipts.asyncStream
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      for await readReceipts in channel.streamReadReceipts() {
        // readReceipts is a [Timetoken: [String]] dictionary
        // mapping each last-read timetoken to the list of user IDs who read up to that point
        for (timetoken, userIds) in readReceipts {
          debugPrint("Timetoken \(timetoken) was last read by users: \(userIds)")
        }
      }
    } else {
      debugPrint("Channel not found")
    }
  }
  // snippet.end
}

// MARK: - Stream Read Receipts (Closure)

func streamReadReceiptsClosure() {
  // snippet.messages.readReceipts.closure
  // Assumes a "ChannelImpl" reference named "channel"

  // Important: Keep a strong reference to the returned "AutoCloseable" object as long as you want
  // to receive updates. If the "AutoCloseable" is deallocated, the stream will be cancelled,
  // and no further items will be produced. You can also stop receiving updates manually
  // by calling the "close()" method on the "AutoCloseable" object.
  autoCloseable = channel.streamReadReceipts { readReceipts in
    // readReceipts is a [Timetoken: [String]] dictionary
    for (timetoken, userIds) in readReceipts {
      print("Timetoken \(timetoken) was last read by users: \(userIds)")
    }
  }
  // snippet.end
}

// MARK: - Fetch Read Receipts

func fetchReadReceipts() {
  // snippet.messages.readReceipts.fetch
  // Assumes a "ChatImpl" reference named "chat"
  Task {
    if let channel = try await chat.getChannel(channelId: "support") {
      let result = try await channel.fetchReadReceipts()
      let receipts = result.receipts
      // Use for subsequent call: channel.fetchReadReceipts(page: nextPage)
      let nextPage = result.page

      receipts.forEach { receipt in
        print("User \(receipt.userId) has read up to timetoken: \(receipt.lastReadTimetoken)")
      }
    }
  }
  // snippet.end
}
