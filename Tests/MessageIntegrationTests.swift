//
//  MessageIntegrationTests.swift
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

final class MessageIntegrationTests: BaseClosureIntegrationTestCase {
  var channel: ChannelImpl!
  var testMessage: MessageImpl!

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
        shouldStore: true,
        completion: $0
      )
    }

    testMessage = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        channel.getMessage(
          timetoken: timetoken,
          completion: $0
        )
      }
    )
  }

  override func customTearDownWithError() throws {
    try awaitResult { testMessage.delete(completion: $0) }
    try awaitResult { chat.deleteChannel(id: channel.id, completion: $0) }

    testMessage = nil
    channel = nil
  }

  func testMessage_HasNoUserReaction() throws {
    let someMessage = MessageImpl(
      chat: chat,
      timetoken: 17_301_310_706_849_521,
      content: .init(text: "Text text"),
      channelId: randomString(),
      userId: randomString()
    )

    XCTAssertFalse(someMessage.hasUserReaction(reaction: "someReaction"))
  }

  func testMessage_EditText() throws {
    let currentMessageText = testMessage.text
    let newText = "NewTextValue"

    XCTAssertNotEqual(
      currentMessageText,
      newText
    )

    let editedMessage = try awaitResultValue(delay: 3) {
      testMessage.editText(
        newText: newText,
        completion: $0
      )
    }

    XCTAssertEqual(
      editedMessage.text,
      newText
    )
  }

  func testMessage_Delete() throws {
    let deleteMessageResult = try awaitResultValue(delay: 3) {
      testMessage.delete(
        soft: false,
        preserveFiles: false,
        completion: $0
      )
    }
    XCTAssertNil(deleteMessageResult)
  }

  func testMessage_SoftDelete() throws {
    let value = try awaitResultValue {
      testMessage.delete(
        soft: true,
        preserveFiles: false,
        completion: $0
      )
    }

    let actions = try XCTUnwrap(value?.actions)
    let deletedActions = try XCTUnwrap(actions[chat.deleteMessageActionName])

    XCTAssertNotNil(value)
    XCTAssertEqual(deletedActions.count, 1)
    XCTAssertFalse(deletedActions.isEmpty)
  }

  func testMessage_GetThread() throws {
    let threadChannel = try awaitResultValue {
      testMessage.createThread(
        completion: $0
      )
    }

    try awaitResultValue {
      threadChannel.sendText(
        text: "Text text text",
        completion: $0
      )
    }

    let message = try awaitResultValue {
      channel.getMessage(
        timetoken: testMessage.timetoken,
        completion: $0
      )
    }

    XCTAssertNotNil(try awaitResultValue {
      message?.getThread(completion: $0)
    })

    addTeardownBlock { [unowned self] in
      try awaitResult {
        testMessage.removeThread(
          completion: $0
        )
      }
    }
  }

  func testMessage_Forward() throws {
    let anotherChannel = try XCTUnwrap(
      awaitResultValue {
        chat.createChannel(
          id: randomString(),
          completion: $0
        )
      }
    )

    let forwardValue = try awaitResultValue {
      testMessage.forward(
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
    XCTAssertEqual(message?.text, testMessage.text)
    XCTAssertEqual(message?.userId, testMessage.userId)

    addTeardownBlock { [unowned self] in
      try awaitResultValue {
        chat.deleteChannel(
          id: anotherChannel.id,
          completion: $0
        )
      }
    }
  }

  func testMessage_Pin() throws {
    let resultingChannel = try awaitResultValue {
      testMessage.pin(
        completion: $0
      )
    }
    let message = try awaitResultValue(delay: 3) {
      resultingChannel.getPinnedMessage(
        completion: $0
      )
    }

    XCTAssertNotNil(message)
    XCTAssertEqual(resultingChannel.id, testMessage.channelId)
  }

  func testMessage_Report() throws {
    XCTAssertNotNil(try awaitResultValue {
      testMessage.report(
        reason: "ReportReason",
        completion: $0
      )
    })
  }

  func testMessage_CreateThread() throws {
    let threadChannel = try awaitResultValue {
      testMessage.createThread(completion: $0)
    }
    XCTAssertEqual(
      threadChannel.parentMessage.timetoken,
      testMessage.timetoken
    )
    XCTAssertEqual(
      threadChannel.parentChannelId,
      testMessage.channelId
    )

    try awaitResultValue(delay: 3) {
      threadChannel.sendText(
        text: "Text text text",
        meta: nil,
        shouldStore: true,
        usePost: false,
        ttl: nil,
        mentionedUsers: nil,
        referencedChannels: nil,
        textLinks: nil,
        quotedMessage: nil,
        files: nil,
        completion: $0
      )
    }

    let retrievedMessage = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        channel.getMessage(
          timetoken: testMessage.timetoken,
          completion: $0
        )
      }
    )

    XCTAssertTrue(
      retrievedMessage.hasThread
    )

    addTeardownBlock { [unowned self] in
      try awaitResult {
        testMessage.removeThread(
          completion: $0
        )
      }
      try awaitResult {
        retrievedMessage.delete(
          completion: $0
        )
      }
    }
  }

  func testMessage_CreateThreadWithParameters() throws {
    let threadChannel = try awaitResultValue {
      testMessage.createThread(
        text: "This is reply in a thread",
        completion: $0
      )
    }

    let threadChannelHistory = try awaitResultValue(delay: 4) {
      threadChannel.getHistory(
        completion: $0
      )
    }

    let retrievedThreadMessage = try XCTUnwrap(threadChannelHistory.messages.first)
    XCTAssertEqual(threadChannelHistory.messages.count, 1)
    XCTAssertEqual(retrievedThreadMessage.text, "This is reply in a thread")

    addTeardownBlock { [unowned self] in
      try awaitResult {
        retrievedThreadMessage.delete(
          completion: $0
        )
      }
      try awaitResult {
        testMessage.removeThread(
          completion: $0
        )
      }
    }
  }

  func testMessage_RemoveThread() throws {
    let threadChannel = try awaitResultValue {
      testMessage.createThread(
        completion: $0
      )
    }
    try awaitResultValue(delay: 1) {
      threadChannel.sendText(
        text: "Text text text",
        completion: $0
      )
    }
    let message = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        channel.getMessage(
          timetoken: testMessage.timetoken,
          completion: $0
        )
      }
    )
    try awaitResultValue(delay: 1) {
      message.removeThread(completion: $0)
    }

    let retrievedMessage = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        channel.getMessage(
          timetoken: testMessage.timetoken,
          completion: $0
        )
      }
    )

    XCTAssertFalse(
      retrievedMessage.hasThread
    )

    addTeardownBlock { [unowned self] in
      try awaitResult {
        testMessage.removeThread(
          completion: $0
        )
      }
      try awaitResult {
        retrievedMessage.delete(
          completion: $0
        )
      }
    }
  }

  func testMessage_ToggleReaction() throws {
    let result = try awaitResultValue(delay: 3) {
      testMessage.toggleReaction(
        reaction: ":+1",
        completion: $0
      )
    }

    let reaction = try XCTUnwrap(result.reactions[":+1"]?.first)
    let userId = reaction.uuid

    XCTAssertEqual(userId, chat.currentUser.id)
  }

  func testMessage_StreamUpdates() throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let timetoken = try awaitResultValue {
      channel?.sendText(
        text: "Some text \(randomString())",
        completion: $0
      )
    }
    let message = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        channel.getMessage(
          timetoken: timetoken,
          completion: $0
        )
      }
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

  func testMessage_GlobalStreamUpdates() throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let timetoken = try awaitResultValue {
      channel?.sendText(
        text: "Some text \(randomString())",
        completion: $0
      )
    }
    let message = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        channel.getMessage(
          timetoken: timetoken,
          completion: $0
        )
      }
    )

    let closeable = MessageImpl.streamUpdatesOn(messages: [message]) {
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

  func testMessage_Restore() throws {
    let message = try awaitResultValue {
      testMessage.delete(
        soft: true,
        completion: $0
      )
    }

    let actions = try XCTUnwrap(message?.actions)
    let deletedActions = try XCTUnwrap(actions[chat.deleteMessageActionName])

    XCTAssertNotNil(message)
    XCTAssertEqual(deletedActions.count, 1)
    XCTAssertFalse(deletedActions.isEmpty)

    let restoredMessage = try awaitResultValue {
      message?.restore(
        completion: $0
      )
    }

    XCTAssertTrue(restoredMessage.actions?.isEmpty ?? false)
  }

  // swiftlint:disable:next file_length
}
