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
