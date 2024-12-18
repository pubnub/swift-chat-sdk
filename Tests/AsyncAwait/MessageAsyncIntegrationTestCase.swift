//
//  MessageAsyncIntegrationTestCase.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import XCTest
import PubNubSDK

@testable import PubNubSwiftChatSDK

class MessageAsyncIntegrationTests: BaseAsyncIntegrationTestCase {
  var channel: ChannelImpl!
  var testMessage: MessageImpl!

  override func customSetup() async throws {
    channel = try await chat.createChannel(id: randomString())
    let timetoken = try await channel.sendText(text: "text")
    try await Task.sleep(nanoseconds: 3000000000)
    testMessage = try await channel.getMessage(timetoken: timetoken)
  }
  
  override func customTearDown() async throws {
    _ = try? await testMessage?.delete()
    _ = try? await chat.deleteChannel(id: channel.id)
    
    testMessage = nil
    channel = nil
  }
  
  func testAsyncMessage_EditText() async throws {
    let currentMessageText = testMessage.text
    let newText = "NewTextValue"

    XCTAssertNotEqual(currentMessageText, newText)
    let editedMessage = try await testMessage.editText(newText: newText)
    XCTAssertEqual(editedMessage.text, newText)
  }

  func testAsyncMessage_Delete() async throws {
    let deletedMessage = try await testMessage.delete(soft: false, preserveFiles: false)
    XCTAssertNil(deletedMessage)
  }

  func testAsyncMessage_SoftDelete() async throws {
    let deletedMessage = try await testMessage.delete(soft: true, preserveFiles: false)
    let actions = try XCTUnwrap(deletedMessage?.actions)
    let deletedActions = try XCTUnwrap(actions[chat.deleteMessageActionName])

    XCTAssertNotNil(deletedMessage)
    XCTAssertEqual(deletedActions.count, 1)
    XCTAssertFalse(deletedActions.isEmpty)
  }

  func testAsyncMessage_GetThread() async throws {
    let threadChannel = try await testMessage.createThread()
    let text = "Text text text"

    try await threadChannel.sendText(text: text)

    let message = try await channel.getMessage(timetoken: testMessage.timetoken)
    let retrievedThreadChannel = try await message?.getThread()

    XCTAssertNotNil(retrievedThreadChannel)
    addTeardownBlock { [unowned self] in _ = try? await testMessage.removeThread() }
  }

  func testAsyncMessage_Forward() async throws {
    let anotherChannel = try await chat.createChannel(id: randomString())
    let forwardValue = try await testMessage.forward(channelId: anotherChannel.id)
    
    try await Task.sleep(nanoseconds: 3000000000)
    let message = try await anotherChannel.getMessage(timetoken: forwardValue)
    
    XCTAssertNotNil(message)
    XCTAssertEqual(message?.text, testMessage.text)
    XCTAssertEqual(message?.userId, testMessage.userId)
    addTeardownBlock { [unowned self] in _ = try? await chat.deleteChannel(id: anotherChannel.id) }
  }

  func testAsyncMessage_Pin() async throws {
    let resultingChannel = try await testMessage.pin()
    
    try await Task.sleep(nanoseconds: 3000000000)
    let message = try await resultingChannel.getPinnedMessage()

    XCTAssertNotNil(message)
    XCTAssertEqual(resultingChannel.id, testMessage.channelId)
  }

  func testAsyncMessage_Report() async throws {
    try await testMessage.report(reason: "ReportReason")
  }

  func testAsyncMessage_CreateThread() async throws {
    let threadChannel = try await testMessage.createThread()
    
    XCTAssertEqual(threadChannel.parentMessage.timetoken, testMessage.timetoken)
    XCTAssertEqual(threadChannel.parentChannelId, testMessage.channelId)

    try await Task.sleep(nanoseconds: 3000000000)
    try await threadChannel.sendText(text: "Text text text")
    try await Task.sleep(nanoseconds: 3000000000)

    let retrievedMessage = try await channel.getMessage(timetoken: testMessage.timetoken)
    XCTAssertTrue(try XCTUnwrap(retrievedMessage).hasThread)

    addTeardownBlock { [unowned self] in
      _ = try? await testMessage?.removeThread()
      _ = try? await retrievedMessage?.delete()
    }
  }

  func testAsyncMessage_RemoveThread() async throws {
    let threadChannel = try await testMessage.createThread()
    
    try await Task.sleep(nanoseconds: 1000000000)
    try await threadChannel.sendText(text: "Text text text")
    try await Task.sleep(nanoseconds: 3000000000)

    let message = try await channel.getMessage(timetoken: testMessage.timetoken)
    XCTAssertNotNil(message)
    
    try await Task.sleep(nanoseconds: 1000000000)
    try await message?.removeThread()
    
    try await Task.sleep(nanoseconds: 3000000000)
    let retrievedMessage = try await channel.getMessage(timetoken: testMessage.timetoken)

    XCTAssertNotNil(retrievedMessage)
    XCTAssertFalse(retrievedMessage?.hasThread ?? true)

    addTeardownBlock { [unowned self] in
      _ = try? await testMessage.removeThread()
      _ = try? await retrievedMessage?.delete()
    }
  }

  func testAsyncMessage_ToggleReaction() async throws {
    try await Task.sleep(nanoseconds: 3000000000)
    
    let updatedMessage = try await testMessage.toggleReaction(reaction: ":+1")
    let reaction = try XCTUnwrap(updatedMessage.reactions[":+1"]?.first)
    let userId = reaction.uuid

    XCTAssertEqual(userId, chat.currentUser.id)
  }
  
  func testAsyncMessage_Restore() async throws {
    let message = try await testMessage.delete(soft: true)
    let actions = try XCTUnwrap(message?.actions)
    let deletedActions = try XCTUnwrap(actions[chat.deleteMessageActionName])
    
    XCTAssertNotNil(message)
    XCTAssertEqual(deletedActions.count, 1)
    XCTAssertFalse(deletedActions.isEmpty)
    
    let restoredMessage = try await message?.restore()
    XCTAssertTrue(restoredMessage?.actions?.isEmpty ?? false)
  }

  func testAsyncMessage_StreamUpdates() async throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let timetoken = try await channel?.sendText(text: "Some text \(randomString())")
    let unwrappedTimetoken = try XCTUnwrap(timetoken)
    
    try await Task.sleep(nanoseconds: 3000000000)
    let message = try await channel.getMessage(timetoken: unwrappedTimetoken)
    let unwrappedMessage = try XCTUnwrap(message)

    let task = Task {
      for await receivedMessage in unwrappedMessage.streamUpdates() {
        XCTAssertTrue(receivedMessage.hasUserReaction(reaction: "myReaction"))
        XCTAssertEqual(receivedMessage.channelId, message?.channelId)
        XCTAssertEqual(receivedMessage.userId, message?.userId)
        expectation.fulfill()
      }
    }
    
    try await Task.sleep(nanoseconds: 3000000000)
    try await message?.toggleReaction(reaction: "myReaction")
    
    await fulfillment(
      of: [expectation],
      timeout: 6
    )
    
    addTeardownBlock {
      task.cancel()
      _ = try? await unwrappedMessage.delete()
    }
  }

  func testAsyncMessage_GlobalStreamUpdates() async throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let timetoken = try await channel?.sendText(text: "Some text \(randomString())")
    let unwrappedTimetoken = try XCTUnwrap(timetoken)

    try await Task.sleep(nanoseconds: 3000000000)
    let message = try await channel.getMessage(timetoken: unwrappedTimetoken)
    let unwrappedMessage = try XCTUnwrap(message)

    let task = Task {
      for await messages in MessageImpl.streamUpdatesOn(messages: [unwrappedMessage]) {
        XCTAssertTrue((try XCTUnwrap(messages.first)).hasUserReaction(reaction: "myReaction"))
        XCTAssertEqual((try XCTUnwrap(messages.first)).channelId, unwrappedMessage.channelId)
        XCTAssertEqual((try XCTUnwrap(messages.first)).userId, unwrappedMessage.userId)
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 3000000000)
    try await message?.toggleReaction(reaction: "myReaction")

    await fulfillment(
      of: [expectation],
      timeout: 6
    )
    
    addTeardownBlock {
      task.cancel()
      _ = try? await unwrappedMessage.delete()
    }
  }
}
