//
//  ChannelGroupAsyncIntegrationTests.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import XCTest

@testable import PubNubSwiftChatSDK

class ChannelGroupAsyncIntegrationTests: BaseAsyncIntegrationTestCase {
  var channelGroup: ChannelGroupImpl!
  var channel: ChannelImpl!
  var secondChannel: ChannelImpl!

  override func customSetup() async throws {
    channel = try await chat.createChannel(id: randomString())
    secondChannel = try await chat.createChannel(id: randomString())
    channelGroup = chat.getChannelGroup(id: randomString())
  }

  override func customTearDown() async throws {
    try await chat.removeChannelGroup(id: channelGroup.id)
    _ = try await chat.deleteChannel(id: channel.id)
    _ = try await chat.deleteChannel(id: secondChannel.id)
  }

  func testChannelGroup_AddChannels() async throws {
    try await channelGroup.add(channels: [channel, secondChannel])
    let responseValue = try await channelGroup.listChannels()

    XCTAssertEqual(responseValue.page?.totalCount, 2)
    XCTAssertEqual(Set(responseValue.channels.map { $0.id }), Set([channel.id, secondChannel.id]))
  }

  func testChannelGroup_AddChannelIdentifiers() async throws {
    try await channelGroup.addChannelIdentifiers([channel.id, secondChannel.id])
    let responseValue = try await channelGroup.listChannels()

    XCTAssertEqual(responseValue.page?.totalCount, 2)
    XCTAssertEqual(Set(responseValue.channels.map { $0.id }), Set([channel.id, secondChannel.id]))
  }

  func testChannelGroup_RemoveChannels() async throws {
    try await channelGroup.add(channels: [channel, secondChannel])
    try await channelGroup.remove(channels: [channel, secondChannel])

    let responseValue = try await channelGroup.listChannels()

    XCTAssertEqual(responseValue.page?.totalCount, 0)
    XCTAssertTrue(responseValue.channels.isEmpty)
  }

  func testChannelGroup_RemoveChannelIdentifiers() async throws {
    try await channelGroup.addChannelIdentifiers([channel.id, secondChannel.id])
    try await channelGroup.removeChannelIdentifiers([channel.id, secondChannel.id])

    let responseValue = try await channelGroup.listChannels()

    XCTAssertEqual(responseValue.page?.totalCount, 0)
    XCTAssertTrue(responseValue.channels.isEmpty)
  }

  func testChannelGroup_WhoIsPresent() async throws {
    try await channelGroup.add(channels: [channel, secondChannel])

    let connectStream = channelGroup.connect()
    let connectTask = Task {
      for await message in connectStream {
        debugPrint("Did receive message: \(message)")
      }
    }

    try await Task.sleep(nanoseconds: 3_000_000_000)
    let whoIsPresentValue = try await channelGroup.whoIsPresent()

    XCTAssertEqual(whoIsPresentValue.count, 2)
    XCTAssertEqual(whoIsPresentValue[channel.id], [chat.currentUser.id])
    XCTAssertEqual(whoIsPresentValue[secondChannel.id], [chat.currentUser.id])

    addTeardownBlock {
      connectTask.cancel()
    }
  }

  func testChannelGroup_StreamPresence() async throws {
    let expectation = expectation(description: "StreamPresence")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    try await channelGroup.add(channels: [channel, secondChannel])

    let connectStream = channelGroup.connect()
    let connectTask = Task {
      for await message in connectStream {
        debugPrint("Did receive message: \(message)")
      }
    }

    let presenceStream = channelGroup.streamPresence()
    let presenceTask = Task { [unowned self] in
      for await presenceData in presenceStream where presenceData.count == 2 {
        XCTAssertEqual(presenceData[channel.id], [chat.currentUser.id])
        XCTAssertEqual(presenceData[secondChannel.id], [chat.currentUser.id])
        expectation.fulfill()
        break
      }
    }

    addTeardownBlock {
      connectTask.cancel()
      presenceTask.cancel()
    }

    await fulfillment(of: [expectation], timeout: 6)
  }

  func testChannelGroup_Connect() async throws {
    let expectation = XCTestExpectation(description: "Connect")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    try await channelGroup.add(channels: [channel, secondChannel])

    let connectStream = channelGroup.connect()
    let connectTask = Task { [unowned self] in
      for await message in connectStream {
        XCTAssertEqual(message.text, "This is a text")
        XCTAssertEqual(message.channelId, channel.id)
        expectation.fulfill()
        break
      }
    }

    addTeardownBlock {
      connectTask.cancel()
    }

    try await Task.sleep(nanoseconds: 4_000_000_000)
    try await channel.sendText(text: "This is a text")

    await fulfillment(of: [expectation], timeout: 6)
  }
}
