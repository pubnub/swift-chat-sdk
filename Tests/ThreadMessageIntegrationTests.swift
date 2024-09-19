//
//  ThreadMessageTests.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import XCTest
import PubNubSwiftChatSDK
import PubNubSDK

class ThreadMessageIntegrationTests: PubNubSwiftChatSDKIntegrationTests {
  var channel: ChannelImpl!
  var threadChannel: ThreadChannelImpl!
  var threadMessage: ThreadMessageImpl!
  var threadMessageTimetoken: Timetoken!

  override func customSetUpWitError() throws {
    channel = try XCTUnwrap(
      try awaitResultValue {
        chat.createChannel(
          id: randomString(),
          completion: $0
        )
      }
    )
    let testMessage = try XCTUnwrap(
      try awaitResultValue {
        channel.getMessage(
          timetoken: try awaitResultValue {
            channel?.sendText(
              text: "text",
              completion: $0
            )
          },
          completion: $0
        )
      }
    )
    threadChannel = try XCTUnwrap(
      try awaitResultValue {
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
      try awaitResultValue(delay: 2) {
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

  func testHasUserReactions() throws {
    XCTAssertFalse(threadMessage.hasUserReaction(reaction: "someReaction"))
  }

  func testEditText() throws {
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

  func testDelete() throws {
    XCTAssertNil(try awaitResultValue {
      threadMessage.delete(
        soft: false,
        preserveFiles: false,
        completion: $0
      )
    })
  }

  func testSoftDelete() throws {
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

  func testGetThread() throws {
    let error = try awaitResultError {
      threadMessage.getThread(
        completion: $0
      )
    }

    XCTAssertEqual((error as? ChatError)?.message, "This message is not a thread.")
  }

  func testForward() throws {
    let anotherChannel = try XCTUnwrap(
      try awaitResultValue {
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
    let message = try awaitResultValue {
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

  func testPin() throws {
    let resultingChannel = try awaitResultValue {
      threadMessage.pin(
        completion: $0
      )
    }
    let message = try awaitResultValue(delay: 2) {
      resultingChannel.getPinnedMessage(
        completion: $0
      )
    }

    XCTAssertNotNil(message)
    XCTAssertEqual(resultingChannel.id, threadMessage.channelId)
  }

  func testReport() throws {
    XCTAssertNotNil(try awaitResultValue {
      threadMessage.report(reason: "ReportReason", completion: $0)
    })
  }

  func testCreateThread() throws {
    let error = try awaitResultError {
      threadMessage.createThread(
        completion: $0
      )
    }

    XCTAssertEqual((error as? ChatError)?.message, "Only one level of thread nesting is allowed.")
  }

  func testRemoveThread() throws {
    let error = try awaitResultError {
      threadMessage.removeThread(
        completion: $0
      )
    }

    XCTAssertEqual((error as? ChatError)?.message, "There is no thread to be deleted.")
  }

  func testToggleReaction() throws {
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

  func testStreamUpdates() throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let message = try XCTUnwrap(
      try awaitResultValue {
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

  func testGlobalStreamUpdates() throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let message = try XCTUnwrap(
      try awaitResultValue {
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

  func testPinMessageToParentChannel() throws {
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

  func testUnpinMessageFromParentChannel() throws {
    try awaitResultValue {
      threadMessage.pinToParentChannel(
        completion: $0
      )
    }
    let updatedChannel = try awaitResultValue {
      threadMessage.unpinFromParentChannel(
        completion: $0
      )
    }
    let pinnedMessage = try awaitResultValue {
      updatedChannel.getPinnedMessage(
        completion: $0
      )
    }
    XCTAssertNil(pinnedMessage)
  }
}
