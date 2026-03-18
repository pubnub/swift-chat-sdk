//
//  ThreadChannelIntegrationTests.swift
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

class ThreadChannelIntegrationTests: BaseClosureIntegrationTestCase {
  var parentChannel: ChannelImpl!
  var threadChannel: ThreadChannelImpl!

  override func customSetUpWitError() throws {
    parentChannel = try XCTUnwrap(
      awaitResultValue {
        chat.createChannel(
          id: randomString(),
          completion: $0
        )
      }
    )

    let timetoken = try awaitResultValue {
      parentChannel?.sendText(
        text: "Message",
        completion: $0
      )
    }

    let testMessage = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        parentChannel.getMessage(
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

    try awaitResultValue {
      threadChannel.sendText(
        text: "Reply in a thread",
        completion: $0
      )
    }
  }

  override func customTearDownWithError() throws {
    try awaitResult { parentChannel.delete(completion: $0) }
    try awaitResult { threadChannel.delete(completion: $0) }
  }

  func testThreadChannel_Update() throws {
    let updatedThreadChannel = try awaitResultValue {
      threadChannel.update(
        name: "UpdatedName",
        custom: ["key": "value"],
        description: "UpdatedDescription",
        status: "UpdatedStatus",
        completion: $0
      )
    }

    XCTAssertEqual(updatedThreadChannel.id, threadChannel.id)
    XCTAssertEqual(updatedThreadChannel.name, "UpdatedName")
    XCTAssertEqual(updatedThreadChannel.channelDescription, "UpdatedDescription")
    XCTAssertEqual(updatedThreadChannel.status, "UpdatedStatus")
  }

  func testThreadChannel_PinMessage() throws {
    let message = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        threadChannel.getHistory(
          completion: $0
        )
      }.messages.first
    )

    let updatedThreadChannel = try awaitResultValue {
      threadChannel.pinMessage(
        message: message,
        completion: $0
      )
    }

    let pinnedMessage = try awaitResultValue {
      updatedThreadChannel.getPinnedMessage(
        completion: $0
      )
    }

    XCTAssertNotNil(pinnedMessage)
    XCTAssertEqual(pinnedMessage?.channelId, threadChannel.id)
  }

  func testThreadChannel_UnpinMessage() throws {
    let message = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        threadChannel.getHistory(
          completion: $0
        )
      }.messages.first
    )

    let channelWithPinnedMessage = try awaitResultValue {
      threadChannel.pinMessage(
        message: message,
        completion: $0
      )
    }

    let updatedThreadChannel = try awaitResultValue {
      channelWithPinnedMessage.unpinMessage(
        completion: $0
      )
    }

    let pinnedMessage = try awaitResultValue {
      updatedThreadChannel.getPinnedMessage(
        completion: $0
      )
    }

    XCTAssertNil(pinnedMessage)
  }

  func testThreadChannel_GetHistory() throws {
    let history = try awaitResultValue(delay: 3) {
      threadChannel.getHistory(
        completion: $0
      )
    }

    XCTAssertEqual(history.messages.count, 1)
    XCTAssertEqual(history.messages.first?.text, "Reply in a thread")
    XCTAssertEqual(history.messages.first?.channelId, threadChannel.id)
  }

  func testThreadChannel_GetMessage() throws {
    let historyMessage = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        threadChannel.getHistory(
          completion: $0
        )
      }.messages.first
    )

    let message = try awaitResultValue {
      threadChannel.getMessage(
        timetoken: historyMessage.timetoken,
        completion: $0
      )
    }

    XCTAssertNotNil(message)
    XCTAssertEqual(message?.text, "Reply in a thread")
    XCTAssertEqual(message?.channelId, threadChannel.id)
  }

  func testThreadChannel_GetPinnedMessage() throws {
    let message = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        threadChannel.getHistory(
          completion: $0
        )
      }.messages.first
    )

    let updatedChannel = try awaitResultValue {
      threadChannel.pinMessage(
        message: message,
        completion: $0
      )
    }

    let pinnedMessage = try awaitResultValue {
      updatedChannel.getPinnedMessage(
        completion: $0
      )
    }

    XCTAssertNotNil(pinnedMessage)
    XCTAssertEqual(pinnedMessage?.text, "Reply in a thread")
    XCTAssertEqual(pinnedMessage?.channelId, threadChannel.id)
  }

  func testThreadChannel_PinMessageToParentChannel() throws {
    let message = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        threadChannel.getHistory(
          completion: $0
        )
      }.messages.first
    )

    let updatedChannel = try awaitResultValue {
      threadChannel.pinMessageToParentChannel(
        message: message,
        completion: $0
      )
    }

    XCTAssertNotNil(
      try awaitResultValue(delay: 3) {
        updatedChannel.getPinnedMessage(
          completion: $0
        )
      }
    )
  }
}
