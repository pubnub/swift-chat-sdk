//
//  ThreadMessageAsyncIntegrationTests.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK
import XCTest

@testable import PubNubSwiftChatSDK

class ThreadMessageaAsyncIntegrationTests: BaseAsyncIntegrationTestCase {
  var channel: ChannelImpl!
  var threadChannel: ThreadChannelImpl!
  var threadMessage: ThreadMessageImpl!

  override func customSetup() async throws {
    channel = try await chat.createChannel(id: randomString())

    let timetoken = try await channel.sendText(text: "text")
    try await Task.sleep(nanoseconds: 3_000_000_000)
    let message = try await channel.getMessage(timetoken: timetoken)

    threadChannel = try await message?.createThread()

    try await threadChannel.sendText(text: "Some text")
    try await Task.sleep(nanoseconds: 3_000_000_000)

    threadMessage = try await threadChannel.getHistory().messages.first
  }

  override func customTearDown() async throws {
    _ = try? await threadMessage.delete()
    _ = try? await threadChannel.delete()
    _ = try? await chat.deleteChannel(id: channel.id)

    channel = nil
    threadChannel = nil
    threadMessage = nil
  }

  func testThreadMessageAsync_HasNoUserReactions() throws {
    XCTAssertFalse(threadMessage.hasUserReaction(reaction: "someReaction"))
  }

  func testThreadMessageAsync_EditText() async throws {
    let currentMessageText = threadMessage.text
    let newText = "NewTextValue"

    XCTAssertNotEqual(currentMessageText, newText)
    let editedMessage = try await threadMessage.editText(newText: newText)
    XCTAssertEqual(editedMessage.text, newText)
  }

  func testThreadMessageAsync_Delete() async throws {
    try await threadMessage.delete()
  }

  func testThreadMessageAsync_SoftDelete() async throws {
    let deletedMessage = try await threadMessage.delete(soft: true)
    let actions = try XCTUnwrap(deletedMessage?.actions)
    let deletedActions = try XCTUnwrap(actions[chat.deleteMessageActionName])

    XCTAssertNotNil(deletedMessage)
    XCTAssertFalse(deletedActions.isEmpty)
  }

  func testThreadMessageAsync_GetThread() async throws {
    let expectation = expectation(description: "ErrorExpectation")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    do {
      _ = try await threadMessage.getThread()
    } catch {
      XCTAssertEqual((error as? ChatError)?.message, "This message is not a thread.")
      expectation.fulfill()
    }

    await fulfillment(of: [expectation], timeout: 10)
  }

  func testThreadMessageAsync_Forward() async throws {
    let anotherChannel = try await chat.createChannel(id: randomString())
    let forwardValue = try await threadMessage.forward(channelId: anotherChannel.id)

    try await Task.sleep(nanoseconds: 3_000_000_000)
    let message = try await anotherChannel.getMessage(timetoken: forwardValue)

    XCTAssertNotNil(message)
    XCTAssertEqual(message?.text, threadMessage.text)
    XCTAssertEqual(message?.userId, threadMessage.userId)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: anotherChannel.id)
    }
  }

  func testThreadMessageAsync_Pin() async throws {
    let resultingChannel = try await threadMessage.pin()
    try await Task.sleep(nanoseconds: 3_000_000_000)
    let message = try await resultingChannel.getPinnedMessage()

    XCTAssertNotNil(message)
    XCTAssertEqual(resultingChannel.id, threadMessage.channelId)
  }

  func testThreadMessageAsync_Report() async throws {
    try await threadMessage.report(reason: "ReportReason")
  }

  func testThreadMessageAsync_CreateThread() async throws {
    let expectation = XCTestExpectation(description: "ErrorExpectation")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    do {
      _ = try await threadMessage.createThread()
    } catch {
      XCTAssertEqual((error as? ChatError)?.message, "Only one level of thread nesting is allowed.")
      expectation.fulfill()
    }
  }

  func testThreadMessageAsync_RemoveThread() async throws {
    let expectation = XCTestExpectation(description: "ErrorExpectation")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    try await Task.sleep(nanoseconds: 1_000_000_000)

    do {
      _ = try await threadMessage.removeThread()
    } catch {
      XCTAssertEqual((error as? ChatError)?.message, "There is no thread to be deleted.")
      expectation.fulfill()
    }
  }

  func testThreadMessageAsync_ToggleReaction() async throws {
    let updateMessage = try await threadMessage.toggleReaction(reaction: ":+1")
    let reaction = try XCTUnwrap(updateMessage.reactions[":+1"]?.first)
    let userId = reaction.uuid

    XCTAssertEqual(
      userId,
      chat.currentUser.id
    )
  }

  func testThreadMessageAsync_StreamUpdates() async throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    try await Task.sleep(nanoseconds: 3_000_000_000)

    let message = try await threadChannel.getHistory().messages.first
    let unwrappedMessage = try XCTUnwrap(message)

    let task = Task {
      for await receivedMessage in threadMessage.streamUpdates() {
        XCTAssertTrue(receivedMessage.hasUserReaction(reaction: "myReaction"))
        XCTAssertEqual(receivedMessage.channelId, unwrappedMessage.channelId)
        XCTAssertEqual(receivedMessage.userId, unwrappedMessage.userId)
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 3_000_000_000)
    try await unwrappedMessage.toggleReaction(reaction: "myReaction")

    await fulfillment(of: [expectation], timeout: 6)

    addTeardownBlock {
      task.cancel()
      _ = try? await unwrappedMessage.delete()
    }
  }

  func testThreadMessageAsync_GlobalStreamUpdates() async throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    try await Task.sleep(nanoseconds: 3_000_000_000)

    let message = try await threadChannel.getHistory().messages.first
    let unwrappedMessage = try XCTUnwrap(message)

    let task = Task {
      for await receivedMessages in ThreadMessageImpl.streamUpdatesOn(messages: [unwrappedMessage]) {
        let message = try XCTUnwrap(receivedMessages.first)
        XCTAssertTrue(message.hasUserReaction(reaction: "myReaction"))
        XCTAssertEqual(message.channelId, unwrappedMessage.channelId)
        XCTAssertEqual(message.userId, unwrappedMessage.userId)
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 3_000_000_000)
    try await unwrappedMessage.toggleReaction(reaction: "myReaction")

    await fulfillment(of: [expectation], timeout: 6)

    addTeardownBlock {
      task.cancel()
      _ = try? await unwrappedMessage.delete()
    }
  }

  func testThreadMessageAsync_PinMessageToParentChannel() async throws {
    let resultingChannel = try await threadMessage.pinToParentChannel()
    let pinnedMessage = try await resultingChannel.getPinnedMessage()

    XCTAssertNotNil(pinnedMessage)
  }

  func testThreadMessageAsync_UnpinMessageFromParentChannel() async throws {
    try await threadMessage.pinToParentChannel()

    try await Task.sleep(nanoseconds: 2_000_000_000)
    let updatedChannel = try await threadMessage.unpinFromParentChannel()

    try await Task.sleep(nanoseconds: 2_000_000_000)
    let pinnedMessage = try await updatedChannel.getPinnedMessage()

    XCTAssertNil(pinnedMessage)
  }
}
