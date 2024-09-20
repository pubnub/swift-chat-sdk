//
//  ThreadChannelTests.swift
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
import XCTest

class ThreadChannelIntegrationTests: PubNubSwiftChatSDKIntegrationTests {
  var parentChannel: ChannelImpl!
  var threadChannel: ThreadChannelImpl!

  override func customSetUpWitError() throws {
    parentChannel = try XCTUnwrap(
      try awaitResultValue {
        chat.createChannel(
          id: randomString(),
          completion: $0
        )
      }
    )
    let testMessage = try XCTUnwrap(
      try awaitResultValue {
        parentChannel.getMessage(
          timetoken: try awaitResultValue {
            parentChannel?.sendText(
              text: "Message",
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
      try awaitResultValue {
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
      try awaitResultValue {
        updatedChannel.getPinnedMessage(
          completion: $0
        )
      }
    )
  }
}
