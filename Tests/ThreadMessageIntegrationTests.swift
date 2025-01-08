//
//  ThreadMessageIntegrationTests.swift
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

class ThreadMessageIntegrationTests: BaseClosureIntegrationTestCase {
  var channel: ChannelImpl!
  var threadChannel: ThreadChannelImpl!
  var threadMessage: ThreadMessageImpl!
  var threadMessageTimetoken: Timetoken!

  override func customSetUpWitError() throws {
    channel = try XCTUnwrap(
      awaitResultValue {
        chat.createChannel(
          id: randomString(),
          completion: $0
        )
      }
    )

    let timetoken = try awaitResultValue {
      channel?.sendText(
        text: "text",
        completion: $0
      )
    }

    let testMessage = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        channel.getMessage(
          timetoken: timetoken,
          completion: $0
        )
      }
    )

    threadChannel = try XCTUnwrap(
      awaitResultValue {
        testMessage.createThread(
          completion: $0
        )
      }
    )

    threadMessageTimetoken = try awaitResultValue {
      threadChannel.sendText(
        text: "Some text",
        completion: $0
      )
    }

    threadMessage = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        threadChannel.getHistory(completion: $0)
      }.messages.first
    )
  }

  override func customTearDownWithError() throws {
    try awaitResult { threadMessage.delete(completion: $0) }
    try awaitResult { threadChannel.delete(completion: $0) }
    try awaitResult { chat.deleteChannel(id: channel.id, completion: $0) }

    channel = nil
    threadChannel = nil
    threadMessage = nil
    threadMessageTimetoken = nil
  }

  func testThreadMessage_HasNoUserReactions() throws {
    XCTAssertFalse(threadMessage.hasUserReaction(reaction: "someReaction"))
  }

  func testThreadMessage_EditText() throws {
    let currentMessageText = threadMessage.text
    let newText = "NewTextValue"

    XCTAssertNotEqual(
      currentMessageText,
      newText
    )

    let editedMessage = try awaitResultValue {
      threadMessage.editText(
        newText: newText,
        completion: $0
      )
    }

    XCTAssertEqual(
      editedMessage.text,
      newText
    )
  }

  func testThreadMessage_Delete() throws {
    XCTAssertNil(try awaitResultValue {
      threadMessage.delete(
        soft: false,
        preserveFiles: false,
        completion: $0
      )
    })
  }

  func testThreadMessage_SoftDelete() throws {
    let value = try awaitResultValue {
      threadMessage.delete(
        soft: true,
        preserveFiles: false,
        completion: $0
      )
    }

    let actions = try XCTUnwrap(value?.actions)
    let deletedActions = try XCTUnwrap(actions[chat.deleteMessageActionName])

    XCTAssertNotNil(value)
    XCTAssertFalse(deletedActions.isEmpty)
  }

  func testThreadMessage_GetThread() throws {
    let error = try awaitResultError(delay: 3) {
      threadMessage.getThread(
        completion: $0
      )
    }

    XCTAssertEqual((error as? ChatError)?.message, "This message is not a thread.")
  }

  func testThreadMessage_Forward() throws {
    let anotherChannel = try XCTUnwrap(
      awaitResultValue {
        chat.createChannel(
          id: randomString(),
          completion: $0
        )
      }
    )

    let forwardValue = try awaitResultValue {
      threadMessage.forward(
        channelId: anotherChannel.id,
        completion: $0
      )
    }
    let message = try awaitResultValue(delay: 3) {
      anotherChannel.getMessage(
        timetoken: forwardValue,
        completion: $0
      )
    }

    XCTAssertNotNil(message)
    XCTAssertEqual(message?.text, threadMessage.text)
    XCTAssertEqual(message?.userId, threadMessage.userId)

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: anotherChannel.id,
          completion: $0
        )
      }
    }
  }

  func testThreadMessage_Pin() throws {
    let resultingChannel = try awaitResultValue {
      threadMessage.pin(
        completion: $0
      )
    }
    let message = try awaitResultValue(delay: 3) {
      resultingChannel.getPinnedMessage(
        completion: $0
      )
    }

    XCTAssertNotNil(message)
    XCTAssertEqual(resultingChannel.id, threadMessage.channelId)
  }

  func testThreadMessage_Report() throws {
    XCTAssertNotNil(try awaitResultValue(delay: 3) {
      threadMessage.report(reason: "ReportReason", completion: $0)
    })
  }

  func testThreadMessage_CreateThread() throws {
    let error = try awaitResultError {
      threadMessage.createThread(
        completion: $0
      )
    }

    XCTAssertEqual((error as? ChatError)?.message, "Only one level of thread nesting is allowed.")
  }

  func testThreadMessage_RemoveThread() throws {
    let error = try awaitResultError(delay: 1) {
      threadMessage.removeThread(
        completion: $0
      )
    }

    XCTAssertEqual((error as? ChatError)?.message, "There is no thread to be deleted.")
  }

  func testThreadMessage_ToggleReaction() throws {
    let result = try awaitResultValue {
      threadMessage.toggleReaction(
        reaction: ":+1",
        completion: $0
      )
    }

    let reaction = try XCTUnwrap(result.reactions[":+1"]?.first)
    let userId = reaction.uuid

    XCTAssertEqual(
      userId,
      chat.currentUser.id
    )
  }

  func testThreadMessage_StreamUpdates() throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let message = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        threadChannel.getHistory(completion: $0)
      }.messages.first
    )

    let closeable = message.streamUpdates {
      XCTAssertTrue($0.hasUserReaction(reaction: "myReaction"))
      XCTAssertEqual($0.channelId, message.channelId)
      XCTAssertEqual($0.userId, message.userId)
      expectation.fulfill()
    }

    try awaitResultValue(delay: 3) {
      message.toggleReaction(
        reaction: "myReaction",
        completion: $0
      )
    }

    wait(
      for: [expectation],
      timeout: 6
    )
    addTeardownBlock { [unowned self] in
      closeable.close()
      try awaitResult { message.delete(completion: $0) }
    }
  }

  func testThreadMessage_GlobalStreamUpdates() throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let message = try XCTUnwrap(
      awaitResultValue(delay: 2) {
        threadChannel.getHistory(completion: $0)
      }.messages.first
    )

    let closeable = ThreadMessageImpl.streamUpdatesOn(messages: [message]) {
      let receivedMessage = $0[0]
      XCTAssertTrue(receivedMessage.hasUserReaction(reaction: "myReaction"))
      XCTAssertEqual(receivedMessage.channelId, message.channelId)
      XCTAssertEqual(receivedMessage.userId, message.userId)
      expectation.fulfill()
    }

    try awaitResultValue(delay: 3) {
      message.toggleReaction(
        reaction: "myReaction",
        completion: $0
      )
    }

    wait(
      for: [expectation],
      timeout: 6
    )
    addTeardownBlock { [unowned self] in
      closeable.close()
      try awaitResult { message.delete(completion: $0) }
    }
  }

  func testThreadMessage_PinMessageToParentChannel() throws {
    let resultingChannel = try awaitResultValue {
      threadMessage.pinToParentChannel(
        completion: $0
      )
    }
    let pinnedMessage = try awaitResultValue {
      resultingChannel.getPinnedMessage(
        completion: $0
      )
    }

    XCTAssertNotNil(pinnedMessage)
  }

  func testThreadMessage_UnpinMessageFromParentChannel() throws {
    try awaitResultValue {
      threadMessage.pinToParentChannel(
        completion: $0
      )
    }
    let updatedChannel = try awaitResultValue(delay: 2) {
      threadMessage.unpinFromParentChannel(
        completion: $0
      )
    }
    let pinnedMessage = try awaitResultValue(delay: 2) {
      updatedChannel.getPinnedMessage(
        completion: $0
      )
    }
    XCTAssertNil(pinnedMessage)
  }
}
