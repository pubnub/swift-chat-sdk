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
}
