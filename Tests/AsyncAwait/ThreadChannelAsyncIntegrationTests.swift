//
//  ThreadChannelAsyncIntegrationTests.swift
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

class ThreadChannelAsyncIntegrationTests: BaseAsyncIntegrationTestCase {
  var parentChannel: ChannelImpl!
  var threadChannel: ThreadChannelImpl!

  override func customSetup() async throws {
    parentChannel = try await chat.createChannel(id: randomString())

    let timetoken = try await parentChannel.sendText(text: "Message")
    try await Task.sleep(nanoseconds: 3_000_000_000)

    let testMessage = try await parentChannel.getMessage(timetoken: timetoken)
    let unwrappedTestMessage = try XCTUnwrap(testMessage)

    threadChannel = try await unwrappedTestMessage.createThread()

    try await threadChannel.sendText(text: "Reply in a thread")
  }

  override func customTearDown() async throws {
    _ = try? await parentChannel.delete()
    _ = try? await threadChannel.delete()
  }

  func testThreadChannelAsync_PinMessageToParentChannel() async throws {
    try await Task.sleep(nanoseconds: 3_000_000_000)

    let message = try await threadChannel.getHistory().messages.first
    let unwrappedMessage = try XCTUnwrap(message)

    let updatedChannel = try await threadChannel.pinMessageToParentChannel(message: unwrappedMessage)
    let pinnedMessage = try await updatedChannel.getPinnedMessage()

    XCTAssertNotNil(pinnedMessage)
  }

  // MARK: - Stream Namespace Tests

  func testThreadChannelAsync_Stream_Messages() async throws {
    let expectation = expectation(description: "Stream_Messages")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let task = Task {
      for await threadMessage in threadChannel.stream.messages() {
        XCTAssertEqual(threadMessage.text, "New thread reply")
        XCTAssertEqual(threadMessage.channelId, threadChannel.id)
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 2_000_000_000)
    try await threadChannel.sendText(text: "New thread reply")

    await fulfillment(of: [expectation], timeout: 6)
    addTeardownBlock { task.cancel() }
  }

  func testThreadChannelAsync_Stream_Updates() async throws {
    let expectation = expectation(description: "Stream_Updates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let task = Task {
      for await updatedThreadChannel in threadChannel.stream.updates() {
        XCTAssertEqual(updatedThreadChannel.name, "UpdatedThread")
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 3_000_000_000)
    _ = try await threadChannel.update(name: "UpdatedThread")

    await fulfillment(of: [expectation], timeout: 6)
    addTeardownBlock { task.cancel() }
  }
}
